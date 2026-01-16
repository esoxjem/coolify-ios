import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case servers
    case apps
    case databases
    case services
    case deployments
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .servers: "Servers"
        case .apps: "Apps"
        case .databases: "Databases"
        case .services: "Services"
        case .deployments: "Deployments"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .servers: "server.rack"
        case .apps: "app.badge"
        case .databases: "cylinder"
        case .services: "square.stack.3d.up"
        case .deployments: "arrow.triangle.2.circlepath"
        case .settings: "gear"
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppTab = .dashboard
    @State private var tabViewCustomization = TabViewCustomization()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.dashboard.title, systemImage: AppTab.dashboard.icon, value: .dashboard) {
                DashboardView()
            }
            .customizationID(AppTab.dashboard.id)

            TabSection("Resources") {
                Tab(AppTab.servers.title, systemImage: AppTab.servers.icon, value: .servers) {
                    ServersView()
                }
                .customizationID(AppTab.servers.id)

                Tab(AppTab.apps.title, systemImage: AppTab.apps.icon, value: .apps) {
                    ApplicationsView()
                }
                .customizationID(AppTab.apps.id)

                Tab(AppTab.databases.title, systemImage: AppTab.databases.icon, value: .databases) {
                    DatabasesView()
                }
                .customizationID(AppTab.databases.id)

                Tab(AppTab.services.title, systemImage: AppTab.services.icon, value: .services) {
                    ServicesView()
                }
                .customizationID(AppTab.services.id)
            }
            .customizationID("resources-section")

            Tab(AppTab.deployments.title, systemImage: AppTab.deployments.icon, value: .deployments) {
                DeploymentsView()
            }
            .customizationID(AppTab.deployments.id)

            Tab(AppTab.settings.title, systemImage: AppTab.settings.icon, value: .settings) {
                SettingsView()
            }
            .customizationID(AppTab.settings.id)
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)
        .tint(.coolifyPurple)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    MainTabView()
        .environment(appState)
}
