import SwiftUI

@MainActor
final class ServersViewModel: ObservableObject {
    @Published var servers: [Server] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var client: CoolifyAPIClient?

    func setInstance(_ instance: CoolifyInstance) {
        self.client = CoolifyAPIClient(instance: instance)
    }

    func loadServers() async {
        guard let client = client else { return }

        isLoading = true
        error = nil

        do {
            servers = try await client.getServers()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadServers()
    }
}

@MainActor
final class ServerDetailViewModel: ObservableObject {
    @Published var resources: ServerResources?
    @Published var isLoading: Bool = false
    @Published var isValidating: Bool = false
    @Published var showValidationResult: Bool = false
    @Published var validationMessage: String = ""
    @Published var error: String?

    private var client: CoolifyAPIClient?
    private var serverUuid: String?

    func setInstance(_ instance: CoolifyInstance, serverUuid: String) {
        self.client = CoolifyAPIClient(instance: instance)
        self.serverUuid = serverUuid
    }

    func loadResources() async {
        guard let client = client, let uuid = serverUuid else { return }

        isLoading = true
        error = nil

        do {
            resources = try await client.getServerResources(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func validateServer() async {
        guard let client = client, let uuid = serverUuid else { return }

        isValidating = true

        do {
            let success = try await client.validateServer(uuid: uuid)
            validationMessage = success ? "Server is reachable and working correctly." : "Server validation failed."
        } catch {
            validationMessage = "Validation failed: \(error.localizedDescription)"
        }

        isValidating = false
        showValidationResult = true
    }
}
