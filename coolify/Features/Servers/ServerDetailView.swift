import SwiftUI

struct ServerDetailView: View {
    @Environment(AppState.self) private var appState
    let server: Server
    @State private var viewModel = ServerDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                serverInfoCard
                resourcesSection
            }
            .padding()
        }
        .navigationTitle("Server Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await viewModel.validateServer() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isValidating)
            }
        }
        .alert("Validation", isPresented: $viewModel.showValidationResult) {
            Button("OK") {}
        } message: {
            Text(viewModel.validationMessage)
        }
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance, serverUuid: server.uuid)
                await viewModel.loadResources()
            }
        }
    }

    private var serverInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "server.rack")
                    .font(.coolifyMonoLargeTitle)
                    .foregroundStyle(.coolifyServer)
                    .symbolEffect(.bounce, options: .nonRepeating)

                VStack(alignment: .leading, spacing: 4) {
                    Text(server.name)
                        .font(.coolifyMonoTitle2)
                        .fontWeight(.bold)

                    Text(server.ip)
                        .font(.coolifyMonoSubheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusBadge(status: server.statusText, color: server.statusColor)
            }

            Divider()

            VStack(spacing: 12) {
                DetailRow(label: "User", value: server.user)
                DetailRow(label: "Port", value: "\(server.port)")

                if server.proxy?.redirectEnabled == true {
                    DetailRow(label: "Proxy Redirect", value: "Enabled")
                }

                if server.isCoolifyHost == true {
                    DetailRow(label: "Coolify Host", value: "Yes")
                }

                if server.settings?.isBuildServer == true {
                    DetailRow(label: "Build Server", value: "Yes")
                }
            }
        }
        .padding()
        .background { MeshGradient.coolifyServer() }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.coolifyServer.opacity(0.3), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var resourcesSection: some View {
        if viewModel.isLoading {
            ProgressView {
                Text("Loading resources...")
                    .font(.coolifyMonoSubheadline)
            }
            .padding()
        } else if let error = viewModel.error {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.coolifyMonoLargeTitle)
                    .foregroundStyle(.coolifyWarning)
                Text("Failed to load resources")
                    .font(.coolifyMonoHeadline)
                Text(error)
                    .font(.coolifyMonoCaption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await viewModel.loadResources() }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        } else {
            let hasApps = !(viewModel.resources?.applications ?? []).isEmpty
            let hasDatabases = !(viewModel.resources?.databases ?? []).isEmpty
            let hasServices = !(viewModel.resources?.services ?? []).isEmpty

            if !hasApps && !hasDatabases && !hasServices {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.coolifyMonoLargeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Resources")
                        .font(.coolifyMonoHeadline)
                    Text("This server has no applications, databases, or services deployed.")
                        .font(.coolifyMonoCaption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                if let apps = viewModel.resources?.applications, !apps.isEmpty {
                    ApplicationsSectionCard(applications: apps)
                }

                if let databases = viewModel.resources?.databases, !databases.isEmpty {
                    DatabasesSectionCard(databases: databases)
                }

                if let services = viewModel.resources?.services, !services.isEmpty {
                    ServicesSectionCard(services: services)
                }
            }
        }
    }
}

// MARK: - Resource Loader Views

/// Loads an application by UUID and displays its detail view
struct ApplicationLoaderView: View {
    @Environment(AppState.self) private var appState
    let uuid: String
    @State private var application: Application?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let application {
                ApplicationDetailView(application: application)
            } else if let error {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
            }
        }
        .task {
            await loadApplication()
        }
    }

    private func loadApplication() async {
        guard let instance = appState.currentInstance else { return }
        let client = CoolifyAPIClient(instance: instance)
        do {
            application = try await client.getApplication(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

/// Loads a database by UUID and displays its detail view
struct DatabaseLoaderView: View {
    @Environment(AppState.self) private var appState
    let uuid: String
    @State private var database: Database?
    @State private var viewModel = DatabasesViewModel()
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let database {
                DatabaseDetailView(database: database, viewModel: viewModel)
            } else if let error {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
            }
        }
        .task {
            await loadDatabase()
        }
    }

    private func loadDatabase() async {
        guard let instance = appState.currentInstance else { return }
        viewModel.setInstance(instance)
        let client = CoolifyAPIClient(instance: instance)
        do {
            database = try await client.getDatabase(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

/// Loads a service by UUID and displays its detail view
struct ServiceLoaderView: View {
    @Environment(AppState.self) private var appState
    let uuid: String
    @State private var service: Service?
    @State private var viewModel = ServicesViewModel()
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let service {
                ServiceDetailView(service: service, viewModel: viewModel)
            } else if let error {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
            }
        }
        .task {
            await loadService()
        }
    }

    private func loadService() async {
        guard let instance = appState.currentInstance else { return }
        viewModel.setInstance(instance)
        let client = CoolifyAPIClient(instance: instance)
        do {
            service = try await client.getService(uuid: uuid)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview("Section Cards") {
    @Previewable @State var appState = AppState()
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ServerDetailView(server: Server(
                    uuid: "test-uuid",
                    name: "Production Server",
                    description: nil,
                    ip: "192.168.1.100",
                    user: "root",
                    port: 22,
                    proxy: nil,
                    settings: nil,
                    isCoolifyHost: true,
                    isReachable: true,
                    isUsable: true
                ))
                .environment(appState)

                ApplicationsSectionCard(applications: [
                    ServerResource(
                        id: 1,
                        uuid: "app-uuid-1",
                        name: "esoxjem/website:main",
                        status: "running:healthy",
                        type: "application",
                        createdAt: nil,
                        updatedAt: nil
                    ),
                    ServerResource(
                        id: 2,
                        uuid: "app-uuid-2",
                        name: "esoxjem/api:main",
                        status: "running:unknown",
                        type: "application",
                        createdAt: nil,
                        updatedAt: nil
                    )
                ])

                DatabasesSectionCard(databases: [
                    ServerResource(
                        id: 3,
                        uuid: "db-uuid-1",
                        name: "postgres-main",
                        status: "running:healthy",
                        type: "database",
                        createdAt: nil,
                        updatedAt: nil
                    ),
                    ServerResource(
                        id: 4,
                        uuid: "db-uuid-2",
                        name: "redis-cache",
                        status: "running:healthy",
                        type: "database",
                        createdAt: nil,
                        updatedAt: nil
                    )
                ])

                ServicesSectionCard(services: [
                    ServerResource(
                        id: 5,
                        uuid: "svc-uuid-1",
                        name: "uptime-kuma-h8wskgg4g4c",
                        status: "running:healthy",
                        type: "service",
                        createdAt: nil,
                        updatedAt: nil
                    ),
                    ServerResource(
                        id: 6,
                        uuid: "svc-uuid-2",
                        name: "plausible-analytics",
                        status: "stopped",
                        type: "service",
                        createdAt: nil,
                        updatedAt: nil
                    )
                ])
            }
            .padding()
        }
    }
}
