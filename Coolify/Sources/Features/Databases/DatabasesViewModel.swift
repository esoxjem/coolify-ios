import SwiftUI
import Observation

@Observable
@MainActor
final class DatabasesViewModel {
    var databases: [Database] = []
    var isLoading: Bool = false
    var error: String?

    private var client: CoolifyAPIClient?

    var hasError: Bool {
        error != nil
    }

    var isEmpty: Bool {
        databases.isEmpty
    }

    var isLoadingInitialData: Bool {
        isLoading && isEmpty
    }

    func setInstance(_ instance: CoolifyInstance) {
        client = CoolifyAPIClient(instance: instance)
    }

    func loadDatabases() async {
        guard let client = client else { return }
        isLoading = true
        error = nil
        await fetchDatabases(using: client)
        isLoading = false
    }

    func startDatabase(_ db: Database) async {
        await performAction { client in
            try await client.startDatabase(uuid: db.uuid)
        }
    }

    func stopDatabase(_ db: Database) async {
        await performAction { client in
            try await client.stopDatabase(uuid: db.uuid)
        }
    }

    func restartDatabase(_ db: Database) async {
        await performAction { client in
            try await client.restartDatabase(uuid: db.uuid)
        }
    }

    func refresh() async {
        await loadDatabases()
    }

    func clearError() {
        error = nil
    }

    private func fetchDatabases(using client: CoolifyAPIClient) async {
        do {
            databases = try await client.getDatabases()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func performAction(_ action: (CoolifyAPIClient) async throws -> Void) async {
        guard let client = client else { return }
        do {
            try await action(client)
            await loadDatabases()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
