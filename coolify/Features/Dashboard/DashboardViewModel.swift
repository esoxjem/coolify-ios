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

            serverCount = servers.count
            applicationCount = apps.count
            databaseCount = databases.count
            serviceCount = services.count
            recentDeployments = deployments
            runningApps = apps.filter { $0.isRunning }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadAll()
    }
}
