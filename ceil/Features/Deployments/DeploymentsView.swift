import SwiftUI

struct DeploymentsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DeploymentsViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Deployments")
                .refreshable { await viewModel.refresh() }
                .alert("Error", isPresented: errorBinding) {
                    dismissButton
                } message: {
                    errorMessage
                }
        }
        .task { await initialLoad() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.shouldShowLoading {
            loadingView
        } else if viewModel.hasDeployments {
            deploymentsList
        } else {
            emptyView
        }
    }

    private var loadingView: some View {
        ContentUnavailableView {
            Label("Loading", systemImage: "arrow.triangle.2.circlepath")
                .font(.monoHeadline)
                .symbolEffect(.rotate)
        } description: {
            Text("Fetching deployments...")
                .font(.monoSubheadline)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Deployments", systemImage: "arrow.triangle.2.circlepath")
                .font(.monoHeadline)
        } description: {
            Text("No deployment history found")
                .font(.monoSubheadline)
        }
    }

    private var deploymentsList: some View {
        List(viewModel.deployments) { deployment in
            deploymentNavigationLink(for: deployment)
        }
        .listStyle(.insetGrouped)
    }

    private func deploymentNavigationLink(for deployment: Deployment) -> some View {
        NavigationLink {
            DeploymentDetailView(deployment: deployment)
                .navigationTransition(.zoom(sourceID: deployment.id, in: namespace))
        } label: {
            DeploymentRowView(deployment: deployment)
        }
        .matchedTransitionSource(id: deployment.id, in: namespace)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.hasError },
            set: { if !$0 { viewModel.clearError() } }
        )
    }

    private var dismissButton: some View {
        Button("OK") { viewModel.clearError() }
    }

    private var errorMessage: some View {
        Text(viewModel.error ?? "")
    }

    private func initialLoad() async {
        guard let instance = appState.currentInstance else { return }
        viewModel.setInstance(instance)
        await viewModel.loadDeployments()
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    DeploymentsView()
        .environment(appState)
}
