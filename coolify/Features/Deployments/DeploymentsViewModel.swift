import SwiftUI
import Observation

@Observable
@MainActor
final class DeploymentsViewModel {
    var deployments: [Deployment] = []
    var isLoading: Bool = false
    var error: String?

    private var client: CoolifyAPIClient?

    var shouldShowLoading: Bool {
        isLoading && deployments.isEmpty
    }

    var hasDeployments: Bool {
        !deployments.isEmpty
    }

    var hasError: Bool {
        error != nil
    }

    func setInstance(_ instance: CoolifyInstance) {
        self.client = CoolifyAPIClient(instance: instance)
    }

    func loadDeployments() async {
        guard let client = client else { return }
        beginLoading()
        await fetchDeployments(using: client)
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

    private func fetchDeployments(using client: CoolifyAPIClient) async {
        do {
            deployments = try await client.getDeployments()
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

    private var client: CoolifyAPIClient?
    private var deploymentUuid: String?

    var currentLogs: String? {
        deployment?.logs
    }

    var hasLogs: Bool {
        guard let logs = currentLogs else { return false }
        return !logs.isEmpty
    }

    func setInstance(_ instance: CoolifyInstance, deploymentUuid: String) {
        self.client = CoolifyAPIClient(instance: instance)
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

    private func fetchDeployment(using client: CoolifyAPIClient, uuid: String) async {
        do {
            deployment = try await client.getDeployment(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
