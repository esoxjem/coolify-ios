import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code, let message):
            return message ?? "HTTP Error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please check your API token."
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        }
    }
}

struct DeployResponse: Codable {
    let message: String?
    let deploymentUuid: String?

    enum CodingKeys: String, CodingKey {
        case message
        case deploymentUuid = "deployment_uuid"
    }
}

actor CeilAPIClient {
    private let instance: CeilInstance
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Mutable demo state for simulating actions (start/stop/restart)
    private var demoApplications: [Application]?
    private var demoDatabases: [Database]?
    private var demoServices: [Service]?

    init(instance: CeilInstance) {
        self.instance = instance

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()

        // Initialize mutable demo state if in demo mode
        if instance.isDemo {
            self.demoApplications = DemoData.applications
            self.demoDatabases = DemoData.databases
            self.demoServices = DemoData.services
        }
    }

    /// Helper to simulate network delay for demo mode
    private func simulateDelay() async {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...500_000_000))
    }

    // MARK: - Network Layer

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        #if DEBUG
        let requestId = NetworkLogger.shared.logRequest(request)
        let startTime = CFAbsoluteTimeGetCurrent()
        #endif

        do {
            let result = try await session.data(for: request)
            #if DEBUG
            NetworkLogger.shared.logResponse(data: result.0, response: result.1, error: nil,
                duration: CFAbsoluteTimeGetCurrent() - startTime, id: requestId)
            #endif
            return result
        } catch {
            #if DEBUG
            NetworkLogger.shared.logResponse(data: nil, response: nil, error: error,
                duration: CFAbsoluteTimeGetCurrent() - startTime, id: requestId)
            #endif
            throw error
        }
    }

    private func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil, queryItems: [URLQueryItem]? = nil) async throws -> T {
        guard var urlComponents = URLComponents(string: "\(instance.apiBaseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(instance.apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            request.httpBody = body
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await performRequest(request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            let message = String(data: data, encoding: .utf8)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func requestVoid(endpoint: String, method: String = "GET", body: Data? = nil) async throws {
        guard let url = URL(string: "\(instance.apiBaseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(instance.apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await performRequest(request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            let message = String(data: data, encoding: .utf8)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    func healthCheck() async throws -> Bool {
        if instance.isDemo {
            await simulateDelay()
            return true
        }

        guard let url = URL(string: "\(instance.baseURL)/api/health") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        let (_, response): (Data, URLResponse)
        do {
            (_, response) = try await performRequest(request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return httpResponse.statusCode == 200
    }

    func validateConnection() async throws -> Bool {
        if instance.isDemo {
            await simulateDelay()
            return true
        }
        let _: [Server] = try await request(endpoint: "/servers")
        return true
    }

    func getServers() async throws -> [Server] {
        if instance.isDemo {
            await simulateDelay()
            return DemoData.servers
        }
        return try await request(endpoint: "/servers")
    }

    func getServer(uuid: String) async throws -> Server {
        if instance.isDemo {
            await simulateDelay()
            guard let server = DemoData.servers.first(where: { $0.uuid == uuid }) else {
                throw APIError.notFound
            }
            return server
        }
        return try await request(endpoint: "/servers/\(uuid)")
    }

    func getServerResources(uuid: String) async throws -> ServerResources {
        if instance.isDemo {
            await simulateDelay()
            return DemoData.serverResources(for: uuid)
        }
        let resources: [ServerResource] = try await request(endpoint: "/servers/\(uuid)/resources")
        return ServerResources(resources: resources)
    }

    func validateServer(uuid: String) async throws -> Bool {
        if instance.isDemo {
            await simulateDelay()
            return true
        }
        try await requestVoid(endpoint: "/servers/\(uuid)/validate")
        return true
    }

    func getApplications() async throws -> [Application] {
        if instance.isDemo {
            await simulateDelay()
            return demoApplications ?? DemoData.applications
        }
        return try await request(endpoint: "/applications")
    }

    func getApplication(uuid: String) async throws -> Application {
        if instance.isDemo {
            await simulateDelay()
            let apps = demoApplications ?? DemoData.applications
            guard let app = apps.first(where: { $0.uuid == uuid }) else {
                throw APIError.notFound
            }
            return app
        }
        return try await request(endpoint: "/applications/\(uuid)")
    }

    func startApplication(uuid: String) async throws -> DeployResponse {
        if instance.isDemo {
            await simulateDelay()
            // Update demo state to running
            if var apps = demoApplications, let index = apps.firstIndex(where: { $0.uuid == uuid }) {
                let app = apps[index]
                apps[index] = Application(
                    uuid: app.uuid, name: app.name, description: app.description, fqdn: app.fqdn,
                    status: "running", repositoryProjectId: app.repositoryProjectId,
                    gitRepository: app.gitRepository, gitBranch: app.gitBranch, gitCommitSha: app.gitCommitSha,
                    buildPack: app.buildPack, dockerComposeLocation: app.dockerComposeLocation,
                    dockerfile: app.dockerfile, dockerfileLocation: app.dockerfileLocation,
                    dockerRegistryImageName: app.dockerRegistryImageName, dockerRegistryImageTag: app.dockerRegistryImageTag,
                    portsExposes: app.portsExposes, portsMappings: app.portsMappings,
                    baseDirectory: app.baseDirectory, publishDirectory: app.publishDirectory,
                    healthCheckEnabled: app.healthCheckEnabled, healthCheckPath: app.healthCheckPath,
                    limitMemory: app.limitMemory, limitCpus: app.limitCpus,
                    createdAt: app.createdAt, updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                demoApplications = apps
            }
            return DeployResponse(message: "Application started", deploymentUuid: "demo-deploy-\(UUID().uuidString.prefix(8))")
        }
        return try await request(endpoint: "/applications/\(uuid)/start", method: "GET")
    }

    func stopApplication(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            // Update demo state to stopped
            if var apps = demoApplications, let index = apps.firstIndex(where: { $0.uuid == uuid }) {
                let app = apps[index]
                apps[index] = Application(
                    uuid: app.uuid, name: app.name, description: app.description, fqdn: app.fqdn,
                    status: "stopped", repositoryProjectId: app.repositoryProjectId,
                    gitRepository: app.gitRepository, gitBranch: app.gitBranch, gitCommitSha: app.gitCommitSha,
                    buildPack: app.buildPack, dockerComposeLocation: app.dockerComposeLocation,
                    dockerfile: app.dockerfile, dockerfileLocation: app.dockerfileLocation,
                    dockerRegistryImageName: app.dockerRegistryImageName, dockerRegistryImageTag: app.dockerRegistryImageTag,
                    portsExposes: app.portsExposes, portsMappings: app.portsMappings,
                    baseDirectory: app.baseDirectory, publishDirectory: app.publishDirectory,
                    healthCheckEnabled: app.healthCheckEnabled, healthCheckPath: app.healthCheckPath,
                    limitMemory: app.limitMemory, limitCpus: app.limitCpus,
                    createdAt: app.createdAt, updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                demoApplications = apps
            }
            return
        }
        try await requestVoid(endpoint: "/applications/\(uuid)/stop", method: "GET")
    }

    func restartApplication(uuid: String) async throws -> DeployResponse {
        if instance.isDemo {
            await simulateDelay()
            return DeployResponse(message: "Application restarting", deploymentUuid: "demo-deploy-\(UUID().uuidString.prefix(8))")
        }
        return try await request(endpoint: "/applications/\(uuid)/restart", method: "GET")
    }

    func getApplicationLogs(uuid: String, lines: Int = 100) async throws -> String {
        if instance.isDemo {
            await simulateDelay()
            return DemoData.sampleApplicationLogs
        }
        let response: ApplicationLogs = try await request(
            endpoint: "/applications/\(uuid)/logs",
            queryItems: [URLQueryItem(name: "lines", value: String(lines))]
        )
        return response.logs ?? ""
    }

    func getApplicationEnvs(uuid: String) async throws -> [EnvironmentVariable] {
        if instance.isDemo {
            await simulateDelay()
            return DemoData.environmentVariables
        }
        return try await request(endpoint: "/applications/\(uuid)/envs")
    }

    func createApplicationEnv(uuid: String, key: String, value: String, isPreview: Bool = false) async throws {
        if instance.isDemo {
            await simulateDelay()
            return
        }
        let body: [String: Any] = ["key": key, "value": value, "is_preview": isPreview]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await requestVoid(endpoint: "/applications/\(uuid)/envs", method: "POST", body: data)
    }

    func deleteApplicationEnv(uuid: String, envUuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            return
        }
        try await requestVoid(endpoint: "/applications/\(uuid)/envs/\(envUuid)", method: "DELETE")
    }

    func getDatabases() async throws -> [Database] {
        if instance.isDemo {
            await simulateDelay()
            return demoDatabases ?? DemoData.databases
        }
        return try await request(endpoint: "/databases")
    }

    func getDatabase(uuid: String) async throws -> Database {
        if instance.isDemo {
            await simulateDelay()
            let dbs = demoDatabases ?? DemoData.databases
            guard let db = dbs.first(where: { $0.uuid == uuid }) else {
                throw APIError.notFound
            }
            return db
        }
        return try await request(endpoint: "/databases/\(uuid)")
    }

    func startDatabase(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            if var dbs = demoDatabases, let index = dbs.firstIndex(where: { $0.uuid == uuid }) {
                let db = dbs[index]
                dbs[index] = Database(
                    uuid: db.uuid, name: db.name, description: db.description, type: db.type,
                    status: "running", image: db.image, isPublic: db.isPublic, publicPort: db.publicPort,
                    internalDbUrl: db.internalDbUrl, externalDbUrl: db.externalDbUrl,
                    limitMemory: db.limitMemory, limitCpus: db.limitCpus,
                    createdAt: db.createdAt, updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                demoDatabases = dbs
            }
            return
        }
        try await requestVoid(endpoint: "/databases/\(uuid)/start", method: "GET")
    }

    func stopDatabase(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            if var dbs = demoDatabases, let index = dbs.firstIndex(where: { $0.uuid == uuid }) {
                let db = dbs[index]
                dbs[index] = Database(
                    uuid: db.uuid, name: db.name, description: db.description, type: db.type,
                    status: "stopped", image: db.image, isPublic: db.isPublic, publicPort: db.publicPort,
                    internalDbUrl: db.internalDbUrl, externalDbUrl: db.externalDbUrl,
                    limitMemory: db.limitMemory, limitCpus: db.limitCpus,
                    createdAt: db.createdAt, updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                demoDatabases = dbs
            }
            return
        }
        try await requestVoid(endpoint: "/databases/\(uuid)/stop", method: "GET")
    }

    func restartDatabase(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            return
        }
        try await requestVoid(endpoint: "/databases/\(uuid)/restart", method: "GET")
    }

    func getServices() async throws -> [Service] {
        if instance.isDemo {
            await simulateDelay()
            return demoServices ?? DemoData.services
        }
        return try await request(endpoint: "/services")
    }

    func getService(uuid: String) async throws -> Service {
        if instance.isDemo {
            await simulateDelay()
            let services = demoServices ?? DemoData.services
            guard let service = services.first(where: { $0.uuid == uuid }) else {
                throw APIError.notFound
            }
            return service
        }
        return try await request(endpoint: "/services/\(uuid)")
    }

    func startService(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            if var services = demoServices, let index = services.firstIndex(where: { $0.uuid == uuid }) {
                let svc = services[index]
                services[index] = Service(
                    uuid: svc.uuid, name: svc.name, description: svc.description,
                    status: "running", fqdn: svc.fqdn, dockerComposeRaw: svc.dockerComposeRaw,
                    connectToDockerNetwork: svc.connectToDockerNetwork,
                    isContainerLabelEscapeEnabled: svc.isContainerLabelEscapeEnabled,
                    createdAt: svc.createdAt, updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                demoServices = services
            }
            return
        }
        try await requestVoid(endpoint: "/services/\(uuid)/start", method: "GET")
    }

    func stopService(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            if var services = demoServices, let index = services.firstIndex(where: { $0.uuid == uuid }) {
                let svc = services[index]
                services[index] = Service(
                    uuid: svc.uuid, name: svc.name, description: svc.description,
                    status: "stopped", fqdn: svc.fqdn, dockerComposeRaw: svc.dockerComposeRaw,
                    connectToDockerNetwork: svc.connectToDockerNetwork,
                    isContainerLabelEscapeEnabled: svc.isContainerLabelEscapeEnabled,
                    createdAt: svc.createdAt, updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                demoServices = services
            }
            return
        }
        try await requestVoid(endpoint: "/services/\(uuid)/stop", method: "GET")
    }

    func restartService(uuid: String) async throws {
        if instance.isDemo {
            await simulateDelay()
            return
        }
        try await requestVoid(endpoint: "/services/\(uuid)/restart", method: "GET")
    }

    func getDeployments() async throws -> [Deployment] {
        if instance.isDemo {
            await simulateDelay()
            return DemoData.deployments
        }
        return try await request(endpoint: "/deployments")
    }

    func getDeployment(uuid: String) async throws -> Deployment {
        if instance.isDemo {
            await simulateDelay()
            guard let deployment = DemoData.deployments.first(where: { $0.deploymentUuid == uuid }) else {
                throw APIError.notFound
            }
            return deployment
        }
        return try await request(endpoint: "/deployments/\(uuid)")
    }

    func getApplicationDeployments(uuid: String, skip: Int = 0, take: Int = 50) async throws -> [Deployment] {
        if instance.isDemo {
            await simulateDelay()
            // Find the app name from uuid
            let apps = demoApplications ?? DemoData.applications
            let appName = apps.first(where: { $0.uuid == uuid })?.name
            // Filter deployments for this app
            let filtered = DemoData.deployments.filter { $0.applicationName == appName }
            let start = min(skip, filtered.count)
            let end = min(skip + take, filtered.count)
            return Array(filtered[start..<end])
        }
        struct DeploymentsResponse: Codable {
            let count: Int
            let deployments: [Deployment]
        }
        let response: DeploymentsResponse = try await request(
            endpoint: "/deployments/applications/\(uuid)",
            queryItems: [
                URLQueryItem(name: "skip", value: String(skip)),
                URLQueryItem(name: "take", value: String(take))
            ]
        )
        return response.deployments
    }

    func deploy(uuid: String? = nil, tag: String? = nil) async throws -> DeployResponse {
        if instance.isDemo {
            await simulateDelay()
            return DeployResponse(message: "Deployment queued", deploymentUuid: "demo-deploy-\(UUID().uuidString.prefix(8))")
        }
        var queryItems: [URLQueryItem] = []
        if let uuid = uuid {
            queryItems.append(URLQueryItem(name: "uuid", value: uuid))
        }
        if let tag = tag {
            queryItems.append(URLQueryItem(name: "tag", value: tag))
        }
        return try await request(endpoint: "/deploy", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    func getProjects() async throws -> [Project] {
        if instance.isDemo {
            await simulateDelay()
            return []  // Projects not critical for demo
        }
        return try await request(endpoint: "/projects")
    }

    func getProject(uuid: String) async throws -> Project {
        if instance.isDemo {
            await simulateDelay()
            throw APIError.notFound
        }
        return try await request(endpoint: "/projects/\(uuid)")
    }

    func getTeams() async throws -> [Team] {
        if instance.isDemo {
            await simulateDelay()
            return []  // Teams not critical for demo
        }
        return try await request(endpoint: "/teams")
    }

    func getCurrentTeam() async throws -> Team {
        if instance.isDemo {
            await simulateDelay()
            throw APIError.notFound
        }
        return try await request(endpoint: "/teams/current")
    }

    func getTeamMembers(teamId: Int) async throws -> [TeamMember] {
        if instance.isDemo {
            await simulateDelay()
            return []
        }
        return try await request(endpoint: "/teams/\(teamId)/members")
    }

    func getVersion() async throws -> String {
        if instance.isDemo {
            await simulateDelay()
            return "4.0.0-demo"
        }
        struct VersionResponse: Codable {
            let version: String
        }
        let response: VersionResponse = try await request(endpoint: "/version")
        return response.version
    }
}
