import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case deployments

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .deployments: "arrow.triangle.2.circlepath"
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .dashboard) {
                DashboardView()
            } label: {
                Image(systemName: AppTab.dashboard.icon)
            }

            Tab(value: .deployments) {
                DeploymentsView()
            } label: {
                Image(systemName: AppTab.deployments.icon)
            }
        }
        .tint(.white)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    MainTabView()
        .environment(appState)
}
