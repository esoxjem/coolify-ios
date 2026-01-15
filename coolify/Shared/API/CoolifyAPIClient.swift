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

actor CoolifyAPIClient {
    private let instance: CoolifyInstance
    private let session: URLSession
    private let decoder: JSONDecoder

    init(instance: CoolifyInstance) {
        self.instance = instance

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
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
            (data, response) = try await session.data(for: request)
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

        let (data, response) = try await session.data(for: request)

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
        guard let url = URL(string: "\(instance.baseURL)/api/health") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return httpResponse.statusCode == 200
    }

    func validateConnection() async throws -> Bool {
        let _: [Server] = try await request(endpoint: "/servers")
        return true
    }

    func getServers() async throws -> [Server] {
        try await request(endpoint: "/servers")
    }

    func getServer(uuid: String) async throws -> Server {
        try await request(endpoint: "/servers/\(uuid)")
    }

    func getServerResources(uuid: String) async throws -> ServerResources {
        try await request(endpoint: "/servers/\(uuid)/resources")
    }

    func validateServer(uuid: String) async throws -> Bool {
        try await requestVoid(endpoint: "/servers/\(uuid)/validate")
        return true
    }

    func getApplications() async throws -> [Application] {
        try await request(endpoint: "/applications")
    }

    func getApplication(uuid: String) async throws -> Application {
        try await request(endpoint: "/applications/\(uuid)")
    }

    func startApplication(uuid: String) async throws -> DeployResponse {
        try await request(endpoint: "/applications/\(uuid)/start", method: "GET")
    }

    func stopApplication(uuid: String) async throws {
        try await requestVoid(endpoint: "/applications/\(uuid)/stop", method: "GET")
    }

    func restartApplication(uuid: String) async throws -> DeployResponse {
        try await request(endpoint: "/applications/\(uuid)/restart", method: "GET")
    }

    func getApplicationLogs(uuid: String, lines: Int = 100) async throws -> String {
        let response: ApplicationLogs = try await request(
            endpoint: "/applications/\(uuid)/logs",
            queryItems: [URLQueryItem(name: "lines", value: String(lines))]
        )
        return response.logs ?? ""
    }

    func getApplicationEnvs(uuid: String) async throws -> [EnvironmentVariable] {
        try await request(endpoint: "/applications/\(uuid)/envs")
    }

    func createApplicationEnv(uuid: String, key: String, value: String, isPreview: Bool = false) async throws {
        let body: [String: Any] = ["key": key, "value": value, "is_preview": isPreview]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await requestVoid(endpoint: "/applications/\(uuid)/envs", method: "POST", body: data)
    }

    func deleteApplicationEnv(uuid: String, envUuid: String) async throws {
        try await requestVoid(endpoint: "/applications/\(uuid)/envs/\(envUuid)", method: "DELETE")
    }

    func getDatabases() async throws -> [Database] {
        try await request(endpoint: "/databases")
    }

    func getDatabase(uuid: String) async throws -> Database {
        try await request(endpoint: "/databases/\(uuid)")
    }

    func startDatabase(uuid: String) async throws {
        try await requestVoid(endpoint: "/databases/\(uuid)/start", method: "GET")
    }

    func stopDatabase(uuid: String) async throws {
        try await requestVoid(endpoint: "/databases/\(uuid)/stop", method: "GET")
    }

    func restartDatabase(uuid: String) async throws {
        try await requestVoid(endpoint: "/databases/\(uuid)/restart", method: "GET")
    }

    func getServices() async throws -> [Service] {
        try await request(endpoint: "/services")
    }

    func getService(uuid: String) async throws -> Service {
        try await request(endpoint: "/services/\(uuid)")
    }

    func startService(uuid: String) async throws {
        try await requestVoid(endpoint: "/services/\(uuid)/start", method: "GET")
    }

    func stopService(uuid: String) async throws {
        try await requestVoid(endpoint: "/services/\(uuid)/stop", method: "GET")
    }

    func restartService(uuid: String) async throws {
        try await requestVoid(endpoint: "/services/\(uuid)/restart", method: "GET")
    }

    func getDeployments() async throws -> [Deployment] {
        try await request(endpoint: "/deployments")
    }

    func getDeployment(uuid: String) async throws -> Deployment {
        try await request(endpoint: "/deployments/\(uuid)")
    }

    func deploy(uuid: String? = nil, tag: String? = nil) async throws -> DeployResponse {
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
        try await request(endpoint: "/projects")
    }

    func getProject(uuid: String) async throws -> Project {
        try await request(endpoint: "/projects/\(uuid)")
    }

    func getTeams() async throws -> [Team] {
        try await request(endpoint: "/teams")
    }

    func getCurrentTeam() async throws -> Team {
        try await request(endpoint: "/teams/current")
    }

    func getTeamMembers(teamId: Int) async throws -> [TeamMember] {
        try await request(endpoint: "/teams/\(teamId)/members")
    }

    func getVersion() async throws -> String {
        struct VersionResponse: Codable {
            let version: String
        }
        let response: VersionResponse = try await request(endpoint: "/version")
        return response.version
    }
}
