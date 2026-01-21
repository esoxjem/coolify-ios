import SwiftUI

/// A persistent banner displayed when the app is in demo mode
/// Shows "Demo Mode" label with an "Exit" button to return to onboarding
struct DemoBannerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.white)

            Text("Demo Mode")
                .font(.monoSubheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)

            Spacer()

            Button {
                appState.exitDemoMode()
            } label: {
                Text("Exit")
                    .font(.monoCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.brandPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(LinearGradient.buttonGradient)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    VStack {
        DemoBannerView()
        Spacer()
    }
    .environment(appState)
}
