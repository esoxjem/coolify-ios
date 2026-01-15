import SwiftUI

struct ServersView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ServersViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.servers.isEmpty {
                    ProgressView("Loading servers...")
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
                        } label: {
                            ServerRowView(server: server)
                        }
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)

                Text(server.ip)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            StatusBadge(status: server.statusText, color: server.statusColor)
        }
        .padding(.vertical, 4)
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
        .cornerRadius(8)
    }
}

#Preview {
    ServersView()
        .environmentObject(AppState())
}
