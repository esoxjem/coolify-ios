import SwiftUI
import Observation

@Observable
@MainActor
final class DeploymentsViewModel {
    var deployments: [Deployment] = []
    var isLoading: Bool = false
    var error: String?

    private var client: CoolifyAPIClient?

    func setInstance(_ instance: CoolifyInstance) {
        self.client = CoolifyAPIClient(instance: instance)
    }

    func loadDeployments() async {
        guard let client = client else { return }

        isLoading = true
        error = nil

        do {
            deployments = try await client.getDeployments()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadDeployments()
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

    func setInstance(_ instance: CoolifyInstance, deploymentUuid: String) {
        self.client = CoolifyAPIClient(instance: instance)
        self.deploymentUuid = deploymentUuid
    }

    func loadDeployment() async {
        guard let client = client, let uuid = deploymentUuid else { return }

        isLoading = true

        do {
            deployment = try await client.getDeployment(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadDeployment()
    }
}
