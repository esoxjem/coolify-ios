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
                            .font(.monoHeadline)
                            .symbolEffect(.pulse)
                    } description: {
                        Text("Fetching servers...")
                            .font(.monoSubheadline)
                    }
                } else if viewModel.servers.isEmpty {
                    ContentUnavailableView {
                        Label("No Servers", systemImage: "server.rack")
                            .font(.monoHeadline)
                    } description: {
                        Text("No servers found in this instance")
                            .font(.monoSubheadline)
                    }
                } else {
                    serverList
                }
            }
            .navigationTitle("Servers")
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Error", isPresented: errorBinding) {
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

    private var serverList: some View {
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

    private var errorBinding: Binding<Bool> {
        .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    ServersView()
        .environment(appState)
}
