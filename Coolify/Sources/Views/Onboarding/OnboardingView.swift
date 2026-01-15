import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddInstance = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)

                    Text("Coolify")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Manage your self-hosted PaaS\nfrom anywhere")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "server.rack",
                        title: "Monitor Servers",
                        description: "View server status and resources"
                    )

                    FeatureRow(
                        icon: "app.badge",
                        title: "Manage Applications",
                        description: "Start, stop, and deploy apps"
                    )

                    FeatureRow(
                        icon: "cylinder",
                        title: "Database Overview",
                        description: "Monitor your databases"
                    )

                    FeatureRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Track Deployments",
                        description: "View deployment status and logs"
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
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .sheet(isPresented: $showAddInstance) {
                AddInstanceView()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
