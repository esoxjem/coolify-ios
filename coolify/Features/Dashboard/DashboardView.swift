import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DashboardViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let instance = appState.currentInstance {
                        InstanceHeaderView(instance: instance)
                    }

                    statsGrid

                    if !viewModel.recentDeployments.isEmpty {
                        recentDeploymentsSection
                    }

                    if !viewModel.runningApps.isEmpty {
                        runningAppsSection
                    }
                }
                .padding(.vertical)
            }
            .contentMargins(.bottom, 20)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading && viewModel.serverCount == 0 {
                    loadingView
                }
            }
            .alert("Error", isPresented: errorBinding) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .tint(.coolifyPurple)
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance)
                await viewModel.loadAll()
            }
        }
        .onChange(of: appState.currentInstance) { _, newInstance in
            if let instance = newInstance {
                viewModel.setInstance(instance)
                Task {
                    await viewModel.loadAll()
                }
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Servers", value: "\(viewModel.serverCount)", icon: "server.rack", color: .coolifyServer, isLoading: viewModel.isLoading)
                .matchedTransitionSource(id: "servers", in: namespace)

            StatCard(title: "Applications", value: "\(viewModel.applicationCount)", icon: "app.badge", color: .coolifySuccess, isLoading: viewModel.isLoading)
                .matchedTransitionSource(id: "apps", in: namespace)

            StatCard(title: "Databases", value: "\(viewModel.databaseCount)", icon: "cylinder", color: .coolifyDatabase, isLoading: viewModel.isLoading)
                .matchedTransitionSource(id: "databases", in: namespace)

            StatCard(title: "Services", value: "\(viewModel.serviceCount)", icon: "square.stack.3d.up", color: .coolifyPurple, isLoading: viewModel.isLoading)
                .matchedTransitionSource(id: "services", in: namespace)
        }
        .padding(.horizontal)
    }

    private var recentDeploymentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Deployments")
                    .font(.coolifyMonoHeadline)
                Spacer()
                NavigationLink {
                    DeploymentsView()
                        .navigationTransition(.zoom(sourceID: "deployments", in: namespace))
                } label: {
                    Text("See All")
                        .font(.coolifyMonoSubheadline)
                        .foregroundStyle(.coolifyPurple)
                }
            }
            .padding(.horizontal)

            ForEach(viewModel.recentDeployments.prefix(5)) { deployment in
                DeploymentRowView(deployment: deployment)
                    .padding(.horizontal)
            }
        }
        .matchedTransitionSource(id: "deployments", in: namespace)
    }

    private var runningAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Running Applications")
                    .font(.coolifyMonoHeadline)
                Spacer()
                NavigationLink {
                    ApplicationsView()
                        .navigationTransition(.zoom(sourceID: "running-apps", in: namespace))
                } label: {
                    Text("See All")
                        .font(.coolifyMonoSubheadline)
                        .foregroundStyle(.coolifyPurple)
                }
            }
            .padding(.horizontal)

            ForEach(viewModel.runningApps.prefix(5)) { app in
                ApplicationRowView(application: app, showStatus: true)
                    .padding(.horizontal)
            }
        }
        .matchedTransitionSource(id: "running-apps", in: namespace)
    }

    private var loadingView: some View {
        ContentUnavailableView {
            Label("Loading", systemImage: "arrow.trianglehead.2.clockwise")
                .font(.coolifyMonoHeadline)
                .symbolEffect(.rotate)
        } description: {
            Text("Fetching your resources...")
                .font(.coolifyMonoSubheadline)
        }
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
    DashboardView()
        .environment(appState)
}
