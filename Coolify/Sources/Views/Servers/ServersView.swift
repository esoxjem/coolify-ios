import SwiftUI

struct ServersView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ServersViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.servers.isEmpty {
                    ContentUnavailableView {
                        Label("Loading", systemImage: "server.rack")
                            .symbolEffect(.pulse)
                    } description: {
                        Text("Fetching servers...")
                    }
                } else if viewModel.servers.isEmpty {
                    ContentUnavailableView(
                        "No Servers",
                        systemImage: "server.rack",
                        description: Text("No servers found in this instance")
                    )
                } else {
                    List(viewModel.servers) { server in
                        NavigationLink {
                            ServerDetailView(server: server)
                                .navigationTransition(.zoom(sourceID: server.id, in: namespace))
                        } label: {
                            ServerRowView(server: server)
                        }
                        .matchedTransitionSource(id: server.id, in: namespace)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Servers")
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance)
                await viewModel.loadServers()
            }
        }
    }
}

struct ServerRowView: View {
    let server: Server
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.title2)
                .foregroundStyle(.blue)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)

                Text(server.ip)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(status: server.statusText, color: server.statusColor)
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }
}

struct StatusBadge: View {
    let status: String
    let color: String

    var statusColor: Color {
        switch color {
        case "green": return .green
        case "yellow": return .yellow
        case "red": return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    ServersView()
        .environment(appState)
}
