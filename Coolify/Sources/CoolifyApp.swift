import SwiftUI

@main
struct CoolifyApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
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

#Preview {
    @Previewable @State var appState = AppState()
    ContentView()
        .environment(appState)
}
