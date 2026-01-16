import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddInstance = false
    @State private var animateFeatures = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo and Title with Mesh Gradient
                VStack(spacing: 16) {
                    ZStack {
                        MeshGradient.coolifyOnboarding()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .blur(radius: 10)

                        Image(systemName: "cloud.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                            .symbolEffect(.breathe.pulse.byLayer, options: .repeating)
                    }

                    Text("Coolify")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Manage your self-hosted PaaS\nfrom anywhere")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "server.rack",
                        title: "Monitor Servers",
                        description: "View server status and resources",
                        animate: animateFeatures,
                        delay: 0.0
                    )

                    FeatureRow(
                        icon: "app.badge",
                        title: "Manage Applications",
                        description: "Start, stop, and deploy apps",
                        animate: animateFeatures,
                        delay: 0.1
                    )

                    FeatureRow(
                        icon: "cylinder",
                        title: "Database Overview",
                        description: "Monitor your databases",
                        animate: animateFeatures,
                        delay: 0.2
                    )

                    FeatureRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Track Deployments",
                        description: "View deployment status and logs",
                        animate: animateFeatures,
                        delay: 0.3
                    )
                }
                .padding(.horizontal)

                Spacer()

                // Get Started Button
                Button {
                    showAddInstance = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            LinearGradient.coolifyButton
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
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
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    var animate: Bool = false
    var delay: Double = 0

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.coolifyPurple)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.coolifyPurple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                appeared = true
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    OnboardingView()
        .environment(appState)
}
