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
                    .font(.largeTitle)
                    .foregroundStyle(.coolifyServer)
                    .symbolEffect(.bounce, options: .nonRepeating)

                VStack(alignment: .leading, spacing: 4) {
                    Text(server.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(server.ip)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusBadge(status: server.statusText, color: server.statusColor)
            }

            Divider()

            VStack(spacing: 12) {
                DetailRow(label: "User", value: server.user)
                DetailRow(label: "Port", value: "\(server.port)")

                if let proxyType = server.proxyType {
                    DetailRow(label: "Proxy", value: proxyType)
                }

                if server.isBuildServer == true {
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
            ProgressView("Loading resources...")
                .padding()
        } else {
            if let apps = viewModel.resources?.applications, !apps.isEmpty {
                ResourceSection(title: "Applications", count: apps.count) {
                    ForEach(apps) { app in
                        NavigationLink {
                            ApplicationDetailView(application: app)
                        } label: {
                            ApplicationRowView(application: app, showStatus: true)
                        }
                    }
                }
            }

            if let databases = viewModel.resources?.databases, !databases.isEmpty {
                ResourceSection(title: "Databases", count: databases.count) {
                    ForEach(databases) { db in
                        DatabaseRowView(database: db)
                    }
                }
            }

            if let services = viewModel.resources?.services, !services.isEmpty {
                ResourceSection(title: "Services", count: services.count) {
                    ForEach(services) { service in
                        ServiceRowView(service: service)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    NavigationStack {
        ServerDetailView(server: Server(
            id: 1,
            uuid: "test-uuid",
            name: "Production Server",
            description: nil,
            ip: "192.168.1.100",
            user: "root",
            port: 22,
            proxyType: "traefik",
            validationLogs: nil,
            logDrainNotificationSent: nil,
            swarmCluster: nil,
            settings: nil,
            isBuildServer: false,
            isReachable: true,
            isUsable: true
        ))
        .environment(appState)
    }
}
