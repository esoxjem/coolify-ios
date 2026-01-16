import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DashboardViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Instance Info with Mesh Gradient
                    if let instance = appState.currentInstance {
                        InstanceHeaderView(instance: instance)
                    }

                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Servers",
                            value: "\(viewModel.serverCount)",
                            icon: "server.rack",
                            color: .coolifyServer,
                            isLoading: viewModel.isLoading
                        )
                        .matchedTransitionSource(id: "servers", in: namespace)

                        StatCard(
                            title: "Applications",
                            value: "\(viewModel.applicationCount)",
                            icon: "app.badge",
                            color: .coolifySuccess,
                            isLoading: viewModel.isLoading
                        )
                        .matchedTransitionSource(id: "apps", in: namespace)

                        StatCard(
                            title: "Databases",
                            value: "\(viewModel.databaseCount)",
                            icon: "cylinder",
                            color: .coolifyDatabase,
                            isLoading: viewModel.isLoading
                        )
                        .matchedTransitionSource(id: "databases", in: namespace)

                        StatCard(
                            title: "Services",
                            value: "\(viewModel.serviceCount)",
                            icon: "square.stack.3d.up",
                            color: .coolifyPurple,
                            isLoading: viewModel.isLoading
                        )
                        .matchedTransitionSource(id: "services", in: namespace)
                    }
                    .padding(.horizontal)

                    // Recent Deployments
                    if !viewModel.recentDeployments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Deployments")
                                    .font(.headline)
                                Spacer()
                                NavigationLink {
                                    DeploymentsView()
                                        .navigationTransition(.zoom(sourceID: "deployments", in: namespace))
                                } label: {
                                    Text("See All")
                                        .font(.subheadline)
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

                    // Running Applications
                    if !viewModel.runningApps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Running Applications")
                                    .font(.headline)
                                Spacer()
                                NavigationLink {
                                    ApplicationsView()
                                        .navigationTransition(.zoom(sourceID: "running-apps", in: namespace))
                                } label: {
                                    Text("See All")
                                        .font(.subheadline)
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
                }
                .padding(.vertical)
            }
            .contentMargins(.bottom, 20)
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading && viewModel.serverCount == 0 {
                    ContentUnavailableView {
                        Label("Loading", systemImage: "arrow.trianglehead.2.clockwise")
                            .symbolEffect(.rotate)
                    } description: {
                        Text("Fetching your resources...")
                    }
                }
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
}

struct InstanceHeaderView: View {
    let instance: CoolifyInstance
    @State private var isConnected = true

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instance.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(instance.baseURL)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.coolifySuccess)
                    .font(.title2)
                    .symbolEffect(.pulse, options: .repeating, value: isConnected)
            }
        }
        .padding()
        .background {
            MeshGradient.coolifyHeader()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.coolifyPurple.opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .symbolEffect(.bounce, value: appeared)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: value)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.background.secondary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        }
        .onAppear {
            appeared = true
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    DashboardView()
        .environment(appState)
}
