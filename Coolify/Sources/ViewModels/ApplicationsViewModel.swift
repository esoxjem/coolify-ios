import SwiftUI

@MainActor
final class ApplicationsViewModel: ObservableObject {
    @Published var applications: [Application] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var client: CoolifyAPIClient?

    func setInstance(_ instance: CoolifyInstance) {
        self.client = CoolifyAPIClient(instance: instance)
    }

    func loadApplications() async {
        guard let client = client else { return }

        isLoading = true
        error = nil

        do {
            applications = try await client.getApplications()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func startApplication(_ app: Application) async {
        guard let client = client else { return }

        do {
            _ = try await client.startApplication(uuid: app.uuid)
            await loadApplications()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func stopApplication(_ app: Application) async {
        guard let client = client else { return }

        do {
            try await client.stopApplication(uuid: app.uuid)
            await loadApplications()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func restartApplication(_ app: Application) async {
        guard let client = client else { return }

        do {
            _ = try await client.restartApplication(uuid: app.uuid)
            await loadApplications()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func refresh() async {
        await loadApplications()
    }
}

@MainActor
final class ApplicationDetailViewModel: ObservableObject {
    @Published var application: Application?
    @Published var logs: String = ""
    @Published var envVars: [EnvironmentVariable] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingLogs: Bool = false
    @Published var isLoadingEnvVars: Bool = false
    @Published var isPerformingAction: Bool = false
    @Published var error: String?

    private var client: CoolifyAPIClient?
    private var applicationUuid: String?

    func setInstance(_ instance: CoolifyInstance, applicationUuid: String) {
        self.client = CoolifyAPIClient(instance: instance)
        self.applicationUuid = applicationUuid
    }

    func loadApplication() async {
        guard let client = client, let uuid = applicationUuid else { return }

        isLoading = true

        do {
            application = try await client.getApplication(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadLogs(lines: Int = 100) async {
        guard let client = client, let uuid = applicationUuid else { return }

        isLoadingLogs = true

        do {
            logs = try await client.getApplicationLogs(uuid: uuid, lines: lines)
        } catch {
            self.error = error.localizedDescription
        }

        isLoadingLogs = false
    }

    func loadEnvVars() async {
        guard let client = client, let uuid = applicationUuid else { return }

        isLoadingEnvVars = true

        do {
            envVars = try await client.getApplicationEnvs(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }

        isLoadingEnvVars = false
    }

    func startApplication() async {
        guard let client = client, let uuid = applicationUuid else { return }

        isPerformingAction = true

        do {
            _ = try await client.startApplication(uuid: uuid)
            await loadApplication()
        } catch {
            self.error = error.localizedDescription
        }

        isPerformingAction = false
    }

    func stopApplication() async {
        guard let client = client, let uuid = applicationUuid else { return }

        isPerformingAction = true

        do {
            try await client.stopApplication(uuid: uuid)
            await loadApplication()
        } catch {
            self.error = error.localizedDescription
        }

        isPerformingAction = false
    }

    func restartApplication() async {
        guard let client = client, let uuid = applicationUuid else { return }

        isPerformingAction = true

        do {
            _ = try await client.restartApplication(uuid: uuid)
            await loadApplication()
        } catch {
            self.error = error.localizedDescription
        }

        isPerformingAction = false
    }

    func deployApplication() async {
        guard let client = client, let uuid = applicationUuid else { return }

        isPerformingAction = true

        do {
            _ = try await client.startApplication(uuid: uuid)
            await loadApplication()
        } catch {
            self.error = error.localizedDescription
        }

        isPerformingAction = false
    }

    func addEnvVar(key: String, value: String) async {
        guard let client = client, let uuid = applicationUuid else { return }

        do {
            try await client.createApplicationEnv(uuid: uuid, key: key, value: value)
            await loadEnvVars()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
