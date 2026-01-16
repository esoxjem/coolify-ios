import SwiftUI

struct TokenHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to get an API Token")
                        .font(.title2)
                        .fontWeight(.bold)

                    stepsSection
                    Divider()
                    permissionsSection
                }
                .padding()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            StepView(number: 1, title: "Open Coolify Dashboard", description: "Log in to your Coolify instance in a web browser")
            StepView(number: 2, title: "Go to Settings", description: "Click on your profile or settings icon")
            StepView(number: 3, title: "Navigate to API Tokens", description: "Find 'Keys & Tokens' or 'API tokens' section")
            StepView(number: 4, title: "Create New Token", description: "Click 'Create New Token' and give it a name")
            StepView(number: 5, title: "Copy the Token", description: "Copy the generated token immediately - it won't be shown again!")
        }
    }

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Token Permissions")
                .font(.headline)

            Text("For full functionality, use a token with read and write permissions. Read-only tokens can view resources but cannot start/stop applications.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct StepView: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            numberBadge
            labelsView
        }
    }

    private var numberBadge: some View {
        Text("\(number)")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(Color.coolifyPurple)
            .clipShape(Circle())
    }

    private var labelsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
