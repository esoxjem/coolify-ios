import SwiftUI

struct ApplicationsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ApplicationsViewModel()
    @State private var searchText = ""
    @Namespace private var namespace

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
                    ContentUnavailableView {
                        Label("Loading", systemImage: "app.badge")
                            .symbolEffect(.pulse)
                    } description: {
                        Text("Fetching applications...")
                    }
                } else if viewModel.applications.isEmpty {
                    ContentUnavailableView(
                        "No Applications",
                        systemImage: "app.badge",
                        description: Text("No applications found in this instance")
                    )
                } else if filteredApplications.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredApplications) { app in
                        NavigationLink {
                            ApplicationDetailView(application: app)
                                .navigationTransition(.zoom(sourceID: app.id, in: namespace))
                        } label: {
                            ApplicationRowView(application: app, showStatus: true)
                        }
                        .matchedTransitionSource(id: app.id, in: namespace)
                        .swipeActions(edge: .trailing) {
                            if app.isRunning {
                                Button {
                                    Task {
                                        await viewModel.stopApplication(app)
                                    }
                                } label: {
                                    Label("Stop", systemImage: "stop.fill")
                                }
                                .tint(.coolifyError)
                            } else {
                                Button {
                                    Task {
                                        await viewModel.startApplication(app)
                                    }
                                } label: {
                                    Label("Start", systemImage: "play.fill")
                                }
                                .tint(.coolifySuccess)
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
                            .tint(.coolifyWarning)
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
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app.badge")
                .font(.title2)
                .foregroundStyle(.coolifySuccess)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.coolifySuccess.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(application.name)
                    .font(.headline)

                if let repo = application.gitRepository {
                    Text(repo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if let fqdn = application.displayURL {
                    Text(fqdn)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        .onAppear { appeared = true }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    ApplicationsView()
        .environment(appState)
}
