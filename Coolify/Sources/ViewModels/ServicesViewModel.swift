import SwiftUI
import Observation

@Observable
@MainActor
final class ServicesViewModel {
    var services: [Service] = []
    var isLoading: Bool = false
    var error: String?

    private var client: CoolifyAPIClient?

    func setInstance(_ instance: CoolifyInstance) {
        self.client = CoolifyAPIClient(instance: instance)
    }

    func loadServices() async {
        guard let client = client else { return }

        isLoading = true
        error = nil

        do {
            services = try await client.getServices()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func startService(_ service: Service) async {
        guard let client = client else { return }

        do {
            try await client.startService(uuid: service.uuid)
            await loadServices()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func stopService(_ service: Service) async {
        guard let client = client else { return }

        do {
            try await client.stopService(uuid: service.uuid)
            await loadServices()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func restartService(_ service: Service) async {
        guard let client = client else { return }

        do {
            try await client.restartService(uuid: service.uuid)
            await loadServices()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func refresh() async {
        await loadServices()
    }
}
