import SwiftUI

struct ApplicationEnvVarsTab: View {
    var viewModel: ApplicationDetailViewModel
    @State private var showAddEnvVar = false

    var body: some View {
        VStack(spacing: 0) {
            envVarsContent
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                addButton
            }
        }
        .sheet(isPresented: $showAddEnvVar) {
            AddEnvVarSheet(
                viewModel: viewModel,
                isPresented: $showAddEnvVar
            )
        }
        .task {
            await viewModel.loadEnvVars()
        }
    }

    private var addButton: some View {
        Button {
            showAddEnvVar = true
        } label: {
            Image(systemName: "plus")
        }
    }

    @ViewBuilder
    private var envVarsContent: some View {
        if viewModel.isLoadingEnvVars {
            loadingView
        } else if viewModel.envVars.isEmpty {
            emptyView
        } else {
            envVarsList
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading environment variables...")
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            ContentUnavailableView(
                "No Environment Variables",
                systemImage: "list.bullet.rectangle",
                description: Text("No environment variables configured")
            )
            Spacer()
        }
    }

    private var envVarsList: some View {
        List {
            ForEach(viewModel.envVars) { envVar in
                EnvVarRow(envVar: envVar)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct EnvVarRow: View {
    let envVar: EnvironmentVariable

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(envVar.key)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(envVar.value ?? "--------")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct AddEnvVarSheet: View {
    var viewModel: ApplicationDetailViewModel
    @Binding var isPresented: Bool
    @State private var key = ""
    @State private var value = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    keyField
                    valueField
                }
            }
            .navigationTitle("Add Variable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    addButton
                }
            }
        }
    }

    private var keyField: some View {
        TextField("Key", text: $key)
            .autocapitalization(.none)
            .autocorrectionDisabled()
    }

    private var valueField: some View {
        TextField("Value", text: $value)
            .autocapitalization(.none)
            .autocorrectionDisabled()
    }

    private var cancelButton: some View {
        Button("Cancel") {
            isPresented = false
        }
    }

    private var addButton: some View {
        Button("Add") {
            Task {
                await viewModel.addEnvVar(key: key, value: value)
                isPresented = false
            }
        }
        .disabled(key.isEmpty)
    }
}
