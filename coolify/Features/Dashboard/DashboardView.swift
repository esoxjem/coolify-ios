import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DashboardViewModel()
    @State private var databasesViewModel = DatabasesViewModel()
    @State private var servicesViewModel = ServicesViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let instance = appState.currentInstance {
                        InstanceHeaderView(instance: instance)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        ServersSectionCard(
                            servers: Array(viewModel.servers.prefix(5)),
                            serverResources: viewModel.serverResources,
                            namespace: namespace
                        )
                        .padding(.horizontal)

                        if !viewModel.applications.isEmpty {
                            ResourceSection(title: "Applications", count: viewModel.applications.count) {
                                ForEach(viewModel.applications.prefix(5)) { application in
                                    NavigationLink {
                                        ApplicationDetailView(application: application)
                                            .navigationTransition(.zoom(sourceID: "application-\(application.id)", in: namespace))
                                    } label: {
                                        ResourceRowView(
                                            icon: "app.connected.to.app.below.fill",
                                            title: application.name,
                                            accentColor: .coolifyApplication,
                                            status: application.status?.capitalized,
                                            statusColor: application.statusColor
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .matchedTransitionSource(id: "application-\(application.id)", in: namespace)
                                }
                            }
                            .padding(.horizontal)
                        }

                        if !viewModel.databases.isEmpty {
                            databasesSection
                        }

                        if !viewModel.services.isEmpty {
                            servicesSection
                        }

                        // Hide recent deployments and running apps in demo mode
                        // to simplify the demo experience
                        if !(appState.currentInstance?.isDemo ?? false) {
                            if !viewModel.recentDeployments.isEmpty {
                                recentDeploymentsSection
                            }

                            if !viewModel.runningApps.isEmpty {
                                runningAppsSection
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .contentMargins(.bottom, 20)
            .navigationTitle("Coolify")
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
            .alert("Error", isPresented: errorBinding) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .tint(.white)
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance)
                databasesViewModel.setInstance(instance)
                servicesViewModel.setInstance(instance)
                await viewModel.loadAll()
            }
        }
        .onChange(of: appState.currentInstance) { _, newInstance in
            if let instance = newInstance {
                viewModel.setInstance(instance)
                databasesViewModel.setInstance(instance)
                servicesViewModel.setInstance(instance)
                Task {
                    await viewModel.loadAll()
                }
            }
        }
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
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            ForEach(viewModel.recentDeployments.prefix(5)) { deployment in
                NavigationLink {
                    DeploymentDetailView(deployment: deployment)
                        .navigationTransition(.zoom(sourceID: "deployment-\(deployment.id)", in: namespace))
                } label: {
                    DeploymentRowView(deployment: deployment)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: "deployment-\(deployment.id)", in: namespace)
                .padding(.horizontal)
            }
        }
        .matchedTransitionSource(id: "deployments", in: namespace)
    }

    private var runningAppsSection: some View {
        ResourceSection(title: "Running Applications", count: viewModel.runningApps.count) {
            ForEach(viewModel.runningApps.prefix(5)) { app in
                NavigationLink {
                    ApplicationDetailView(application: app)
                        .navigationTransition(.zoom(sourceID: "app-\(app.id)", in: namespace))
                } label: {
                    ResourceRowView(
                        icon: "app.connected.to.app.below.fill",
                        title: app.name,
                        accentColor: .coolifyApplication,
                        status: app.status?.capitalized,
                        statusColor: app.statusColor
                    )
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: "app-\(app.id)", in: namespace)
            }
        }
        .padding(.horizontal)
    }

    private var databasesSection: some View {
        ResourceSection(title: "Databases", count: viewModel.databases.count) {
            ForEach(viewModel.databases.prefix(5)) { database in
                NavigationLink {
                    DatabaseDetailView(database: database, viewModel: databasesViewModel)
                        .navigationTransition(.zoom(sourceID: "database-\(database.id)", in: namespace))
                } label: {
                    ResourceRowView(
                        icon: database.databaseIcon,
                        title: database.name,
                        accentColor: .coolifyDatabase,
                        status: database.status?.capitalized,
                        statusColor: database.statusColor
                    )
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: "database-\(database.id)", in: namespace)
            }
        }
        .padding(.horizontal)
    }

    private var servicesSection: some View {
        ResourceSection(title: "Services", count: viewModel.services.count) {
            ForEach(viewModel.services.prefix(5)) { service in
                NavigationLink {
                    ServiceDetailView(service: service, viewModel: servicesViewModel)
                        .navigationTransition(.zoom(sourceID: "service-\(service.id)", in: namespace))
                } label: {
                    ResourceRowView(
                        icon: "square.stack.3d.up",
                        title: service.name,
                        accentColor: .coolifyService,
                        status: service.status?.capitalized,
                        statusColor: service.statusColor
                    )
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: "service-\(service.id)", in: namespace)
            }
        }
        .padding(.horizontal)
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
