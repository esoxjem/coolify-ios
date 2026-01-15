import SwiftUI

struct ApplicationsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ApplicationsViewModel()
    @State private var searchText = ""

    var filteredApplications: [Application] {
        if searchText.isEmpty {
            return viewModel.applications
        }
        return viewModel.applications.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.gitRepository?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.applications.isEmpty {
                    ProgressView("Loading applications...")
                } else if viewModel.applications.isEmpty {
                    ContentUnavailableView(
                        "No Applications",
                        systemImage: "app.badge",
                        description: Text("No applications found in this instance")
                    )
                } else {
                    List(filteredApplications) { app in
                        NavigationLink {
                            ApplicationDetailView(application: app)
                        } label: {
                            ApplicationRowView(application: app, showStatus: true)
                        }
                        .swipeActions(edge: .trailing) {
                            if app.isRunning {
                                Button {
                                    Task {
                                        await viewModel.stopApplication(app)
                                    }
                                } label: {
                                    Label("Stop", systemImage: "stop.fill")
                                }
                                .tint(.red)
                            } else {
                                Button {
                                    Task {
                                        await viewModel.startApplication(app)
                                    }
                                } label: {
                                    Label("Start", systemImage: "play.fill")
                                }
                                .tint(.green)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                Task {
                                    await viewModel.restartApplication(app)
                                }
                            } label: {
                                Label("Restart", systemImage: "arrow.clockwise")
                            }
                            .tint(.orange)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Search applications")
                }
            }
            .navigationTitle("Applications")
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
                await viewModel.loadApplications()
            }
        }
    }
}

struct ApplicationRowView: View {
    let application: Application
    let showStatus: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app.badge")
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(application.name)
                    .font(.headline)

                if let repo = application.gitRepository {
                    Text(repo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else if let fqdn = application.displayURL {
                    Text(fqdn)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if showStatus, let status = application.status {
                StatusBadge(
                    status: status.capitalized,
                    color: application.statusColor
                )
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ApplicationsView()
        .environmentObject(AppState())
}
