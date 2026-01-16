import SwiftUI
import Observation

@Observable
@MainActor
final class DashboardViewModel {
    var serverCount: Int = 0
    var applicationCount: Int = 0
    var databaseCount: Int = 0
    var serviceCount: Int = 0
    var recentDeployments: [Deployment] = []
    var runningApps: [Application] = []
    var applications: [Application] = []
    var databases: [Database] = []
    var services: [Service] = []
    var servers: [Server] = []
    var serverResources: [String: ServerResources] = [:]
    var isLoading: Bool = false
    var error: String?

    private var client: CoolifyAPIClient?

    func setInstance(_ instance: CoolifyInstance) {
        client = CoolifyAPIClient(instance: instance)
    }

    func loadAll() async {
        guard let client = client else { return }

        isLoading = true
        error = nil

        do {
            async let serversTask = client.getServers()
            async let appsTask = client.getApplications()
            async let databasesTask = client.getDatabases()
            async let servicesTask = client.getServices()
            async let deploymentsTask = client.getDeployments()

            let (servers, apps, databases, services, deployments) = try await (
                serversTask, appsTask, databasesTask, servicesTask, deploymentsTask
            )

            self.servers = servers
            self.applications = apps
            self.databases = databases
            self.services = services
            serverCount = servers.count
            applicationCount = apps.count
            databaseCount = databases.count
            serviceCount = services.count
            recentDeployments = deployments
            runningApps = apps.filter { $0.isRunning }

            await fetchServerResources(servers: servers, client: client)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    private func fetchServerResources(servers: [Server], client: CoolifyAPIClient) async {
        await withTaskGroup(of: (String, ServerResources).self) { group in
            for server in servers {
                group.addTask {
                    do {
                        let resources = try await client.getServerResources(uuid: server.uuid)
                        return (server.uuid, resources)
                    } catch {
                        return (server.uuid, ServerResources(resources: []))
                    }
                }
            }
            for await (uuid, resources) in group {
                serverResources[uuid] = resources
            }
        }
    }

    func refresh() async {
        await loadAll()
    }
}
