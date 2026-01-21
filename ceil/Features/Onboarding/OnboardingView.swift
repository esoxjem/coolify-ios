import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddInstance = false
    @State private var animateFeatures = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                heroSection
                Spacer()
                featuresSection
                Spacer()
                getStartedButton
            }
            .sheet(isPresented: $showAddInstance) {
                AddInstanceView()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateFeatures = true
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .brandPurple.opacity(0.5), radius: 20, x: 0, y: 10)

            Text("Ciel")
                .font(.monoLargeTitle)
                .fontWeight(.bold)

            Text("Manage your self-hosted\nCoolify servers with ease")
                .font(.monoSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "server.rack", title: "Monitor Servers", description: "View server status and resources", animate: animateFeatures, delay: 0.0)
            FeatureRow(icon: "app.badge", title: "Manage Applications", description: "Start, stop, and deploy apps", animate: animateFeatures, delay: 0.1)
            FeatureRow(icon: "cylinder", title: "Database Overview", description: "Monitor your databases", animate: animateFeatures, delay: 0.2)
            FeatureRow(icon: "arrow.triangle.2.circlepath", title: "Track Deployments", description: "View deployment status and logs", animate: animateFeatures, delay: 0.3)
        }
        .padding(.horizontal)
    }

    private var getStartedButton: some View {
        VStack(spacing: 16) {
            Button {
                showAddInstance = true
            } label: {
                Text("Get Started")
                    .font(.monoHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background { LinearGradient.buttonGradient }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                appState.enterDemoMode()
            } label: {
                Text("Try Demo")
                    .font(.monoSubheadline)
                    .foregroundStyle(.brandPurple)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    OnboardingView()
        .environment(appState)
}
