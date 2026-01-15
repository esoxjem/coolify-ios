import SwiftUI

struct AddInstanceView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var baseURL: String = ""
    @State private var apiToken: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var showTokenHelp: Bool = false

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !baseURL.trimmingCharacters(in: .whitespaces).isEmpty &&
        !apiToken.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Instance Name", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()

                    TextField("Coolify URL", text: $baseURL)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    SecureField("API Token", text: $apiToken)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("Instance Details")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your Coolify instance URL (e.g., https://coolify.example.com)")

                        Button {
                            showTokenHelp = true
                        } label: {
                            Label("How to get an API token?", systemImage: "questionmark.circle")
                                .font(.footnote)
                        }
                    }
                }

                if let error = validationError {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                        }
                    }
                }

                Section {
                    Button {
                        Task {
                            await validateAndSave()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isValidating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .padding(.trailing, 8)
                                Text("Validating...")
                            } else {
                                Text("Connect")
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid || isValidating)
                }
            }
            .navigationTitle("Add Instance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showTokenHelp) {
                TokenHelpView()
            }
        }
    }

    private func validateAndSave() async {
        isValidating = true
        validationError = nil

        let instance = CoolifyInstance(
            name: name.trimmingCharacters(in: .whitespaces),
            baseURL: baseURL.trimmingCharacters(in: .whitespaces),
            apiToken: apiToken.trimmingCharacters(in: .whitespaces)
        )

        let client = CoolifyAPIClient(instance: instance)

        do {
            _ = try await client.validateConnection()
            await MainActor.run {
                appState.addInstance(instance)
                dismiss()
            }
        } catch let error as APIError {
            await MainActor.run {
                validationError = error.errorDescription
                isValidating = false
            }
        } catch {
            await MainActor.run {
                validationError = error.localizedDescription
                isValidating = false
            }
        }
    }
}

struct TokenHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to get an API Token")
                        .font(.title2)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 16) {
                        StepView(
                            number: 1,
                            title: "Open Coolify Dashboard",
                            description: "Log in to your Coolify instance in a web browser"
                        )

                        StepView(
                            number: 2,
                            title: "Go to Settings",
                            description: "Click on your profile or settings icon"
                        )

                        StepView(
                            number: 3,
                            title: "Navigate to API Tokens",
                            description: "Find 'Keys & Tokens' or 'API tokens' section"
                        )

                        StepView(
                            number: 4,
                            title: "Create New Token",
                            description: "Click 'Create New Token' and give it a name"
                        )

                        StepView(
                            number: 5,
                            title: "Copy the Token",
                            description: "Copy the generated token immediately - it won't be shown again!"
                        )
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Token Permissions")
                            .font(.headline)

                        Text("For full functionality, use a token with read and write permissions. Read-only tokens can view resources but cannot start/stop applications.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StepView: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())

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
}

#Preview {
    AddInstanceView()
        .environmentObject(AppState())
}
