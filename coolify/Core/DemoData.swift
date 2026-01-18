import Foundation

/// Static mock data for demo mode
/// Used when the current instance is marked as demo to provide App Store reviewers
/// with a realistic preview of the app's functionality without requiring a real Coolify server.
///
/// Note: This enum is nonisolated to allow access from the CoolifyAPIClient actor.
/// All properties are static and immutable, so thread safety is guaranteed.
nonisolated(unsafe) enum DemoData {

    // MARK: - Servers

    static let servers: [Server] = [
        Server(
            uuid: "demo-server-1",
            name: "Production Server",
            description: "Main production server running all services",
            ip: "192.168.1.100",
            user: "coolify",
            port: 22,
            proxy: ServerProxy(redirectEnabled: true),
            settings: ServerSettings(
                id: 1,
                serverId: 1,
                concurrentBuilds: 2,
                dynamicTimeout: 30,
                forceDisabled: false,
                isBuildServer: false,
                isCloudflareTunnel: false,
                isJumpServer: false,
                isSwarmManager: false,
                isSwarmWorker: false,
                isReachable: true,
                isUsable: true,
                isSentinelEnabled: true,
                isMetricsEnabled: true,
                isTerminalEnabled: true
            ),
            isCoolifyHost: true,
            isReachable: true,
            isUsable: true
        ),
        Server(
            uuid: "demo-server-2",
            name: "Staging Server",
            description: "Staging environment for testing",
            ip: "192.168.1.101",
            user: "coolify",
            port: 22,
            proxy: ServerProxy(redirectEnabled: true),
            settings: ServerSettings(
                id: 2,
                serverId: 2,
                concurrentBuilds: 1,
                dynamicTimeout: 30,
                forceDisabled: false,
                isBuildServer: true,
                isCloudflareTunnel: false,
                isJumpServer: false,
                isSwarmManager: false,
                isSwarmWorker: false,
                isReachable: true,
                isUsable: true,
                isSentinelEnabled: false,
                isMetricsEnabled: true,
                isTerminalEnabled: true
            ),
            isCoolifyHost: false,
            isReachable: true,
            isUsable: true
        )
    ]

    // MARK: - Applications

    static var applications: [Application] = [
        Application(
            uuid: "demo-app-1",
            name: "Frontend App",
            description: "React-based frontend application",
            fqdn: "https://app.demo.coolify.io",
            status: "running",
            repositoryProjectId: 12345,
            gitRepository: "github.com/demo/frontend-app",
            gitBranch: "main",
            gitCommitSha: "a1b2c3d4e5f6789012345678901234567890abcd",
            buildPack: "nixpacks",
            dockerComposeLocation: nil,
            dockerfile: nil,
            dockerfileLocation: nil,
            dockerRegistryImageName: nil,
            dockerRegistryImageTag: nil,
            portsExposes: "3000",
            portsMappings: nil,
            baseDirectory: "/",
            publishDirectory: nil,
            healthCheckEnabled: true,
            healthCheckPath: "/health",
            limitMemory: "512M",
            limitCpus: "1",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 30)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600))
        ),
        Application(
            uuid: "demo-app-2",
            name: "API Backend",
            description: "Node.js REST API service",
            fqdn: "https://api.demo.coolify.io",
            status: "running",
            repositoryProjectId: 12346,
            gitRepository: "github.com/demo/api-backend",
            gitBranch: "main",
            gitCommitSha: "b2c3d4e5f6789012345678901234567890abcde",
            buildPack: "dockerfile",
            dockerComposeLocation: nil,
            dockerfile: "Dockerfile",
            dockerfileLocation: "/Dockerfile",
            dockerRegistryImageName: nil,
            dockerRegistryImageTag: nil,
            portsExposes: "8080",
            portsMappings: nil,
            baseDirectory: "/",
            publishDirectory: nil,
            healthCheckEnabled: true,
            healthCheckPath: "/api/health",
            limitMemory: "1G",
            limitCpus: "2",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 45)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200))
        ),
        Application(
            uuid: "demo-app-3",
            name: "Admin Dashboard",
            description: "Internal admin panel",
            fqdn: "https://admin.demo.coolify.io",
            status: "running",
            repositoryProjectId: 12347,
            gitRepository: "github.com/demo/admin-dashboard",
            gitBranch: "develop",
            gitCommitSha: "c3d4e5f6789012345678901234567890abcdef",
            buildPack: "static",
            dockerComposeLocation: nil,
            dockerfile: nil,
            dockerfileLocation: nil,
            dockerRegistryImageName: nil,
            dockerRegistryImageTag: nil,
            portsExposes: "80",
            portsMappings: nil,
            baseDirectory: "/",
            publishDirectory: "/dist",
            healthCheckEnabled: false,
            healthCheckPath: nil,
            limitMemory: "256M",
            limitCpus: "0.5",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 60)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400))
        ),
        Application(
            uuid: "demo-app-4",
            name: "Worker Service",
            description: "Background job processor",
            fqdn: nil,
            status: "stopped",
            repositoryProjectId: 12348,
            gitRepository: "github.com/demo/worker-service",
            gitBranch: "main",
            gitCommitSha: "d4e5f6789012345678901234567890abcdef01",
            buildPack: "dockerfile",
            dockerComposeLocation: nil,
            dockerfile: "Dockerfile.worker",
            dockerfileLocation: "/Dockerfile.worker",
            dockerRegistryImageName: nil,
            dockerRegistryImageTag: nil,
            portsExposes: nil,
            portsMappings: nil,
            baseDirectory: "/",
            publishDirectory: nil,
            healthCheckEnabled: false,
            healthCheckPath: nil,
            limitMemory: "2G",
            limitCpus: "2",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 15)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 3))
        )
    ]

    // MARK: - Databases

    static var databases: [Database] = [
        Database(
            uuid: "demo-db-1",
            name: "PostgreSQL Main",
            description: "Primary PostgreSQL database",
            type: "postgresql",
            status: "running",
            image: "postgres:16",
            isPublic: false,
            publicPort: nil,
            internalDbUrl: "postgresql://user:pass@postgres:5432/main",
            externalDbUrl: nil,
            limitMemory: "2G",
            limitCpus: "2",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 90)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600))
        ),
        Database(
            uuid: "demo-db-2",
            name: "Redis Cache",
            description: "In-memory cache store",
            type: "redis",
            status: "running",
            image: "redis:7-alpine",
            isPublic: false,
            publicPort: nil,
            internalDbUrl: "redis://redis:6379",
            externalDbUrl: nil,
            limitMemory: "512M",
            limitCpus: "1",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 60)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800))
        ),
        Database(
            uuid: "demo-db-3",
            name: "MySQL Legacy",
            description: "Legacy MySQL database for migrations",
            type: "mysql",
            status: "stopped",
            image: "mysql:8",
            isPublic: false,
            publicPort: nil,
            internalDbUrl: "mysql://user:pass@mysql:3306/legacy",
            externalDbUrl: nil,
            limitMemory: "1G",
            limitCpus: "1",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 120)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 7))
        )
    ]

    // MARK: - Services

    static var services: [Service] = [
        Service(
            uuid: "demo-service-1",
            name: "Plausible Analytics",
            description: "Privacy-friendly analytics platform",
            status: "running",
            fqdn: "https://analytics.demo.coolify.io",
            dockerComposeRaw: nil,
            connectToDockerNetwork: true,
            isContainerLabelEscapeEnabled: false,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 45)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200))
        ),
        Service(
            uuid: "demo-service-2",
            name: "Uptime Kuma",
            description: "Self-hosted monitoring tool",
            status: "running",
            fqdn: "https://status.demo.coolify.io",
            dockerComposeRaw: nil,
            connectToDockerNetwork: true,
            isContainerLabelEscapeEnabled: false,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 30)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600))
        )
    ]

    // MARK: - Deployments

    static var deployments: [Deployment] = [
        Deployment(
            deploymentUuid: "demo-deploy-1",
            applicationName: "Frontend App",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "a1b2c3d",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://app.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3500))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-2",
            applicationName: "API Backend",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "b2c3d4e",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://api.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7100))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-3",
            applicationName: "Frontend App",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "c3d4e5f",
            status: "in_progress",
            isWebhook: false,
            isApi: true,
            deploymentUrl: nil,
            logs: "Starting deployment...\nPulling latest changes...",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-300)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-60))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-4",
            applicationName: "Admin Dashboard",
            serverName: "Production Server",
            forceRebuild: true,
            commit: "d4e5f67",
            status: "failed",
            isWebhook: true,
            isApi: false,
            deploymentUrl: nil,
            logs: "Build failed: npm ERR! code ELIFECYCLE",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86300))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-5",
            applicationName: "API Backend",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "e5f6789",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://api.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 2)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 2 + 200))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-6",
            applicationName: "Frontend App",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "f678901",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://app.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 3)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 3 + 180))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-7",
            applicationName: "Worker Service",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "0123456",
            status: "finished",
            isWebhook: false,
            isApi: true,
            deploymentUrl: nil,
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 4)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 4 + 300))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-8",
            applicationName: "API Backend",
            serverName: "Staging Server",
            forceRebuild: false,
            commit: "1234567",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://api-staging.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 5)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 5 + 250))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-9",
            applicationName: "Frontend App",
            serverName: "Staging Server",
            forceRebuild: false,
            commit: "2345678",
            status: "cancelled",
            isWebhook: true,
            isApi: false,
            deploymentUrl: nil,
            logs: "Deployment cancelled by user",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 6)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 6 + 60))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-10",
            applicationName: "Admin Dashboard",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "3456789",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://admin.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 7)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 7 + 200))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-11",
            applicationName: "Frontend App",
            serverName: "Production Server",
            forceRebuild: true,
            commit: "4567890",
            status: "finished",
            isWebhook: false,
            isApi: true,
            deploymentUrl: "https://app.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 10)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 10 + 400))
        ),
        Deployment(
            deploymentUuid: "demo-deploy-12",
            applicationName: "API Backend",
            serverName: "Production Server",
            forceRebuild: false,
            commit: "5678901",
            status: "finished",
            isWebhook: true,
            isApi: false,
            deploymentUrl: "https://api.demo.coolify.io",
            logs: DemoData.sampleDeploymentLogs,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 14)),
            updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 14 + 350))
        )
    ]

    // MARK: - Server Resources

    static func serverResources(for serverUuid: String) -> ServerResources {
        let resources: [ServerResource]
        switch serverUuid {
        case "demo-server-1":
            resources = [
                ServerResource(id: 1, uuid: "demo-app-1", name: "Frontend App", status: "running:healthy", type: "application",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 2, uuid: "demo-app-2", name: "API Backend", status: "running:healthy", type: "application",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 3, uuid: "demo-app-3", name: "Admin Dashboard", status: "running", type: "application",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 4, uuid: "demo-db-1", name: "PostgreSQL Main", status: "running", type: "database",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 5, uuid: "demo-db-2", name: "Redis Cache", status: "running", type: "database",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 6, uuid: "demo-service-1", name: "Plausible Analytics", status: "running", type: "service",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 7, uuid: "demo-service-2", name: "Uptime Kuma", status: "running", type: "service",
                             createdAt: nil, updatedAt: nil)
            ]
        case "demo-server-2":
            resources = [
                ServerResource(id: 8, uuid: "demo-app-4", name: "Worker Service", status: "stopped", type: "application",
                             createdAt: nil, updatedAt: nil),
                ServerResource(id: 9, uuid: "demo-db-3", name: "MySQL Legacy", status: "stopped", type: "database",
                             createdAt: nil, updatedAt: nil)
            ]
        default:
            resources = []
        }
        return ServerResources(resources: resources)
    }

    // MARK: - Environment Variables

    static let environmentVariables: [EnvironmentVariable] = [
        EnvironmentVariable(id: 1, uuid: "env-1", key: "NODE_ENV", value: "production", isPreview: false, isLiteral: true, isMultiline: false, isShownOnce: false, isBuildTime: false),
        EnvironmentVariable(id: 2, uuid: "env-2", key: "DATABASE_URL", value: "postgresql://***", isPreview: false, isLiteral: true, isMultiline: false, isShownOnce: true, isBuildTime: false),
        EnvironmentVariable(id: 3, uuid: "env-3", key: "REDIS_URL", value: "redis://redis:6379", isPreview: false, isLiteral: true, isMultiline: false, isShownOnce: false, isBuildTime: false),
        EnvironmentVariable(id: 4, uuid: "env-4", key: "API_SECRET", value: "***", isPreview: false, isLiteral: true, isMultiline: false, isShownOnce: true, isBuildTime: false),
        EnvironmentVariable(id: 5, uuid: "env-5", key: "LOG_LEVEL", value: "info", isPreview: false, isLiteral: true, isMultiline: false, isShownOnce: false, isBuildTime: false)
    ]

    // MARK: - Sample Logs

    static let sampleApplicationLogs = """
[2024-01-15 10:23:45] INFO  Server started on port 3000
[2024-01-15 10:23:46] INFO  Connected to database
[2024-01-15 10:23:46] INFO  Redis connection established
[2024-01-15 10:24:01] INFO  Healthcheck passed
[2024-01-15 10:25:00] INFO  Processing incoming request: GET /api/users
[2024-01-15 10:25:01] INFO  Request completed in 45ms
[2024-01-15 10:26:30] INFO  Processing incoming request: POST /api/data
[2024-01-15 10:26:31] INFO  Request completed in 120ms
[2024-01-15 10:27:00] INFO  Scheduled job started: cleanup
[2024-01-15 10:27:05] INFO  Scheduled job completed: cleanup
"""

    static let sampleDeploymentLogs = """
=== Deployment Started ===
Pulling latest changes from repository...
Commit: a1b2c3d - feat: add new feature
Building application...
Step 1/8 : FROM node:20-alpine
Step 2/8 : WORKDIR /app
Step 3/8 : COPY package*.json ./
Step 4/8 : RUN npm ci --only=production
Step 5/8 : COPY . .
Step 6/8 : RUN npm run build
Step 7/8 : EXPOSE 3000
Step 8/8 : CMD ["npm", "start"]
Successfully built image
Pushing to registry...
Deploying to server...
Health check passed
=== Deployment Completed Successfully ===
"""
}
