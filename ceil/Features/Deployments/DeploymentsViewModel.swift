import SwiftUI
import Observation

@Observable
@MainActor
final class DeploymentsViewModel {
    var deployments: [Deployment] = []
    var isLoading: Bool = false
    var error: String?

    private var client: CeilAPIClient?

    var shouldShowLoading: Bool {
        isLoading && deployments.isEmpty
    }

    var hasDeployments: Bool {
        !deployments.isEmpty
    }

    var hasError: Bool {
        error != nil
    }

    func setInstance(_ instance: CeilInstance) {
        self.client = CeilAPIClient(instance: instance)
    }

    func loadDeployments() async {
        guard let client = client else { return }
        beginLoading()
        await fetchAllDeployments(using: client)
        endLoading()
    }

    func refresh() async {
        await loadDeployments()
    }

    func clearError() {
        error = nil
    }

    private func beginLoading() {
        isLoading = true
        error = nil
    }

    private func endLoading() {
        isLoading = false
    }

    private func fetchAllDeployments(using client: CeilAPIClient) async {
        do {
            let applications = try await client.getApplications()

            var allDeployments: [Deployment] = []

            await withTaskGroup(of: [Deployment].self) { group in
                for app in applications {
                    group.addTask {
                        (try? await client.getApplicationDeployments(uuid: app.uuid)) ?? []
                    }
                }

                for await appDeployments in group {
                    allDeployments.append(contentsOf: appDeployments)
                }
            }

            // Sort by creation date, most recent first
            deployments = allDeployments.sorted { first, second in
                guard let firstDate = first.createdAt, let secondDate = second.createdAt else {
                    return first.createdAt != nil
                }
                return firstDate > secondDate
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}

@Observable
@MainActor
final class DeploymentDetailViewModel {
    var deployment: Deployment?
    var isLoading: Bool = false
    var error: String?

    private var client: CeilAPIClient?
    private var deploymentUuid: String?

    var currentLogs: String? {
        deployment?.logs
    }

    var hasLogs: Bool {
        guard let logs = currentLogs else { return false }
        return !logs.isEmpty
    }

    func setInstance(_ instance: CeilInstance, deploymentUuid: String) {
        self.client = CeilAPIClient(instance: instance)
        self.deploymentUuid = deploymentUuid
    }

    func loadDeployment() async {
        guard let client = client, let uuid = deploymentUuid else { return }
        beginLoading()
        await fetchDeployment(using: client, uuid: uuid)
        endLoading()
    }

    func refresh() async {
        await loadDeployment()
    }

    private func beginLoading() {
        isLoading = true
    }

    private func endLoading() {
        isLoading = false
    }

    private func fetchDeployment(using client: CeilAPIClient, uuid: String) async {
        do {
            deployment = try await client.getDeployment(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
