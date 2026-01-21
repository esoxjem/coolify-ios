import SwiftUI
import Observation

@Observable
@MainActor
final class ServicesViewModel {
    var services: [Service] = []
    var isLoading: Bool = false
    var error: String?

    private var client: CeilAPIClient?

    var hasError: Bool {
        error != nil
    }

    var isLoadingInitialData: Bool {
        isLoading && services.isEmpty
    }

    var hasNoServices: Bool {
        services.isEmpty
    }

    func setInstance(_ instance: CeilInstance) {
        client = CeilAPIClient(instance: instance)
    }

    func loadServices() async {
        guard let client = client else { return }
        beginLoading()
        await fetchServices(using: client)
        endLoading()
    }

    func startService(_ service: Service) async {
        guard let client = client else { return }
        await performAction { try await client.startService(uuid: service.uuid) }
    }

    func stopService(_ service: Service) async {
        guard let client = client else { return }
        await performAction { try await client.stopService(uuid: service.uuid) }
    }

    func restartService(_ service: Service) async {
        guard let client = client else { return }
        await performAction { try await client.restartService(uuid: service.uuid) }
    }

    func refresh() async {
        await loadServices()
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

    private func fetchServices(using client: CeilAPIClient) async {
        do {
            services = try await client.getServices()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func performAction(_ action: () async throws -> Void) async {
        do {
            try await action()
            await loadServices()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
