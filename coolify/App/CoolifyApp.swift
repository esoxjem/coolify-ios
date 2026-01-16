import SwiftUI
import UIKit

@main
struct CoolifyApp: App {
    @State private var appState = AppState()

    init() {
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.smooth, value: appState.isAuthenticated)
    }
}

private func configureNavigationBarAppearance() {
    let monoLargeTitle = UIFont.monospacedSystemFont(ofSize: 34, weight: .bold)
    let monoTitle = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)

    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.largeTitleTextAttributes = [.font: monoLargeTitle]
    appearance.titleTextAttributes = [.font: monoTitle]

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
}

#Preview {
    @Previewable @State var appState = AppState()
    ContentView()
        .environment(appState)
}
