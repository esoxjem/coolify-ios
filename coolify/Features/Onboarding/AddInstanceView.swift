import SwiftUI

struct AddInstanceView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let instanceToEdit: CoolifyInstance?

    @State private var name: String = ""
    @State private var baseURL: String = ""
    @State private var apiToken: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var showTokenHelp: Bool = false

    private var isEditMode: Bool { instanceToEdit != nil }

    init(instanceToEdit: CoolifyInstance? = nil) {
        self.instanceToEdit = instanceToEdit
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !baseURL.trimmingCharacters(in: .whitespaces).isEmpty &&
        !apiToken.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                instanceDetailsSection
                errorSection
                connectSection
            }
            .navigationTitle(isEditMode ? "Edit Instance" : "Add Instance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showTokenHelp) {
                TokenHelpView()
            }
            .onAppear {
                if let instance = instanceToEdit {
                    name = instance.name
                    baseURL = instance.baseURL
                    apiToken = instance.apiToken
                }
            }
        }
    }

    private var instanceDetailsSection: some View {
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
                        .font(.coolifyMonoFootnote)
                }
            }
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if let error = validationError {
            Section {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.coolifyError)
                    Text(error)
                        .foregroundColor(.coolifyError)
                }
            }
        }
    }

    private var connectSection: some View {
        Section {
            Button {
                Task { await validateAndSave() }
            } label: {
                HStack {
                    Spacer()
                    if isValidating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.trailing, 8)
                        Text("Validating...")
                    } else {
                        Text(isEditMode ? "Save Changes" : "Connect")
                    }
                    Spacer()
                }
            }
            .disabled(!isFormValid || isValidating)
        }
    }

    private func validateAndSave() async {
        isValidating = true
        validationError = nil

        // Preserve the original instance ID when editing, create new ID for new instances
        let instanceId = instanceToEdit?.id ?? UUID()

        let instance = CoolifyInstance(
            id: instanceId,
            name: name.trimmingCharacters(in: .whitespaces),
            baseURL: baseURL.trimmingCharacters(in: .whitespaces),
            apiToken: apiToken.trimmingCharacters(in: .whitespaces)
        )

        let client = CoolifyAPIClient(instance: instance)

        do {
            _ = try await client.validateConnection()
            await MainActor.run {
                if isEditMode {
                    appState.updateInstance(instance)
                } else {
                    appState.addInstance(instance)
                }
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

#Preview {
    @Previewable @State var appState = AppState()
    AddInstanceView()
        .environment(appState)
}
