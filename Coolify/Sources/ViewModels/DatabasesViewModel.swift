import SwiftUI

@MainActor
final class DatabasesViewModel: ObservableObject {
    @Published var databases: [Database] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var client: CoolifyAPIClient?

    func setInstance(_ instance: CoolifyInstance) {
        self.client = CoolifyAPIClient(instance: instance)
    }

    func loadDatabases() async {
        guard let client = client else { return }

        isLoading = true
        error = nil

        do {
            databases = try await client.getDatabases()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func startDatabase(_ db: Database) async {
        guard let client = client else { return }

        do {
            try await client.startDatabase(uuid: db.uuid)
            await loadDatabases()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func stopDatabase(_ db: Database) async {
        guard let client = client else { return }

        do {
            try await client.stopDatabase(uuid: db.uuid)
            await loadDatabases()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func restartDatabase(_ db: Database) async {
        guard let client = client else { return }

        do {
            try await client.restartDatabase(uuid: db.uuid)
            await loadDatabases()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func refresh() async {
        await loadDatabases()
    }
}
