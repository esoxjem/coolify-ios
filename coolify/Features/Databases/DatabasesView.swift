import SwiftUI

struct DatabasesView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DatabasesViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Databases")
                .refreshable { await viewModel.refresh() }
                .alert("Error", isPresented: errorBinding) {
                    Button("OK") { viewModel.clearError() }
                } message: {
                    Text(viewModel.error ?? "")
                }
        }
        .task { await loadInitialData() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingInitialData {
            loadingView
        } else if viewModel.isEmpty {
            emptyView
        } else {
            databaseList
        }
    }

    private var loadingView: some View {
        ContentUnavailableView {
            Label("Loading", systemImage: "cylinder")
                .font(.coolifyMonoHeadline)
                .symbolEffect(.pulse)
        } description: {
            Text("Fetching databases...")
                .font(.coolifyMonoSubheadline)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Databases", systemImage: "cylinder")
                .font(.coolifyMonoHeadline)
        } description: {
            Text("No databases found in this instance")
                .font(.coolifyMonoSubheadline)
        }
    }

    private var databaseList: some View {
        List(viewModel.databases) { db in
            databaseNavigationLink(for: db)
        }
        .listStyle(.insetGrouped)
    }

    private func databaseNavigationLink(for db: Database) -> some View {
        NavigationLink {
            DatabaseDetailView(database: db, viewModel: viewModel)
                .navigationTransition(.zoom(sourceID: db.id, in: namespace))
        } label: {
            DatabaseRowView(database: db)
        }
        .matchedTransitionSource(id: db.id, in: namespace)
        .swipeActions(edge: .trailing) {
            swipeActionButton(for: db)
        }
    }

    @ViewBuilder
    private func swipeActionButton(for db: Database) -> some View {
        if db.isRunning {
            stopButton(for: db)
        } else {
            startButton(for: db)
        }
    }

    private func stopButton(for db: Database) -> some View {
        Button {
            Task { await viewModel.stopDatabase(db) }
        } label: {
            Label("Stop", systemImage: "stop.fill")
        }
        .tint(.coolifyError)
    }

    private func startButton(for db: Database) -> some View {
        Button {
            Task { await viewModel.startDatabase(db) }
        } label: {
            Label("Start", systemImage: "play.fill")
        }
        .tint(.coolifySuccess)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.hasError },
            set: { if !$0 { viewModel.clearError() } }
        )
    }

    private func loadInitialData() async {
        guard let instance = appState.currentInstance else { return }
        viewModel.setInstance(instance)
        await viewModel.loadDatabases()
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    DatabasesView()
        .environment(appState)
}
