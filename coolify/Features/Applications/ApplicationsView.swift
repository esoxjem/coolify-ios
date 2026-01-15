import SwiftUI

struct ApplicationsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ApplicationsViewModel()
    @State private var searchText = ""
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Applications")
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
            await initializeViewModel()
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoadingInitially {
            loadingView
        } else if viewModel.applications.isEmpty {
            emptyView
        } else if filteredApplications.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            applicationsList
        }
    }

    private var loadingView: some View {
        ContentUnavailableView {
            Label("Loading", systemImage: "app.badge")
                .symbolEffect(.pulse)
        } description: {
            Text("Fetching applications...")
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Applications",
            systemImage: "app.badge",
            description: Text("No applications found in this instance")
        )
    }

    private var applicationsList: some View {
        List(filteredApplications) { app in
            applicationRow(for: app)
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search applications")
    }

    private func applicationRow(for app: Application) -> some View {
        NavigationLink {
            ApplicationDetailView(application: app)
                .navigationTransition(.zoom(sourceID: app.id, in: namespace))
        } label: {
            ApplicationRowView(application: app, showStatus: true)
        }
        .matchedTransitionSource(id: app.id, in: namespace)
        .swipeActions(edge: .trailing) {
            trailingSwipeActions(for: app)
        }
        .swipeActions(edge: .leading) {
            leadingSwipeActions(for: app)
        }
    }

    @ViewBuilder
    private func trailingSwipeActions(for app: Application) -> some View {
        if app.isRunning {
            Button {
                Task { await viewModel.stopApplication(app) }
            } label: {
                Label("Stop", systemImage: "stop.fill")
            }
            .tint(.coolifyError)
        } else {
            Button {
                Task { await viewModel.startApplication(app) }
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .tint(.coolifySuccess)
        }
    }

    private func leadingSwipeActions(for app: Application) -> some View {
        Button {
            Task { await viewModel.restartApplication(app) }
        } label: {
            Label("Restart", systemImage: "arrow.clockwise")
        }
        .tint(.coolifyWarning)
    }

    private var filteredApplications: [Application] {
        if searchText.isEmpty {
            return viewModel.applications
        }
        return viewModel.applications.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.gitRepository?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private var isLoadingInitially: Bool {
        viewModel.isLoading && viewModel.applications.isEmpty
    }

    private var errorBinding: Binding<Bool> {
        .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )
    }

    private func initializeViewModel() async {
        if let instance = appState.currentInstance {
            viewModel.setInstance(instance)
            await viewModel.loadApplications()
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    ApplicationsView()
        .environment(appState)
}
