import SwiftUI

struct ServicesView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ServicesViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Services")
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
        } else if viewModel.hasNoServices {
            emptyView
        } else {
            servicesList
        }
    }

    private var loadingView: some View {
        ContentUnavailableView {
            Label("Loading", systemImage: "square.stack.3d.up")
                .font(.coolifyMonoHeadline)
                .symbolEffect(.pulse)
        } description: {
            Text("Fetching services...")
                .font(.coolifyMonoSubheadline)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Services", systemImage: "square.stack.3d.up")
                .font(.coolifyMonoHeadline)
        } description: {
            Text("No services found in this instance")
                .font(.coolifyMonoSubheadline)
        }
    }

    private var servicesList: some View {
        List(viewModel.services) { service in
            serviceRow(for: service)
        }
        .listStyle(.insetGrouped)
    }

    private func serviceRow(for service: Service) -> some View {
        NavigationLink {
            ServiceDetailView(service: service, viewModel: viewModel)
                .navigationTransition(.zoom(sourceID: service.id, in: namespace))
        } label: {
            ServiceRowView(service: service)
        }
        .matchedTransitionSource(id: service.id, in: namespace)
        .swipeActions(edge: .trailing) {
            swipeAction(for: service)
        }
    }

    @ViewBuilder
    private func swipeAction(for service: Service) -> some View {
        if service.isRunning {
            stopButton(for: service)
        } else {
            startButton(for: service)
        }
    }

    private func stopButton(for service: Service) -> some View {
        Button {
            Task { await viewModel.stopService(service) }
        } label: {
            Label("Stop", systemImage: "stop.fill")
        }
        .tint(.coolifyError)
    }

    private func startButton(for service: Service) -> some View {
        Button {
            Task { await viewModel.startService(service) }
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
        await viewModel.loadServices()
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    ServicesView()
        .environment(appState)
}
