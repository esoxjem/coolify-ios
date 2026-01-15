import SwiftUI

@MainActor
final class DeploymentsViewModel: ObservableObject {
    @Published var deployments: [Deployment] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

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

@MainActor
final class DeploymentDetailViewModel: ObservableObject {
    @Published var deployment: Deployment?
    @Published var isLoading: Bool = false
    @Published var error: String?

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
