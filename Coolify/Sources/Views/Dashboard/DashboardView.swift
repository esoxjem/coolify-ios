import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Instance Info
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
                            color: .blue
                        )

                        StatCard(
                            title: "Applications",
                            value: "\(viewModel.applicationCount)",
                            icon: "app.badge",
                            color: .green
                        )

                        StatCard(
                            title: "Databases",
                            value: "\(viewModel.databaseCount)",
                            icon: "cylinder",
                            color: .orange
                        )

                        StatCard(
                            title: "Services",
                            value: "\(viewModel.serviceCount)",
                            icon: "square.stack.3d.up",
                            color: .purple
                        )
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
                                } label: {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(viewModel.recentDeployments.prefix(5)) { deployment in
                                DeploymentRowView(deployment: deployment)
                                    .padding(.horizontal)
                            }
                        }
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
                                } label: {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(viewModel.runningApps.prefix(5)) { app in
                                ApplicationRowView(application: app, showStatus: true)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading && viewModel.serverCount == 0 {
                    ProgressView("Loading...")
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

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instance.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(instance.baseURL)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}
