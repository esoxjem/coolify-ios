import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                .tag(0)

            ServersView()
                .tabItem {
                    Label("Servers", systemImage: "server.rack")
                }
                .tag(1)

            ApplicationsView()
                .tabItem {
                    Label("Apps", systemImage: "app.badge")
                }
                .tag(2)

            DeploymentsView()
                .tabItem {
                    Label("Deploys", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
