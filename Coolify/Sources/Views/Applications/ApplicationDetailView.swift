import SwiftUI

struct ApplicationDetailView: View {
    @Environment(AppState.self) private var appState
    let application: Application
    @State private var viewModel = ApplicationDetailViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ApplicationHeaderView(
                application: viewModel.application ?? application,
                viewModel: viewModel
            )

            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("Overview").tag(0)
                Text("Logs").tag(1)
                Text("Env Vars").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // Tab Content
            TabView(selection: $selectedTab) {
                ApplicationOverviewTab(application: viewModel.application ?? application)
                    .tag(0)

                ApplicationLogsTab(viewModel: viewModel)
                    .tag(1)

                ApplicationEnvVarsTab(viewModel: viewModel)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(application.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance, applicationUuid: application.uuid)
                await viewModel.loadApplication()
            }
        }
    }
}

struct ApplicationHeaderView: View {
    let application: Application
    var viewModel: ApplicationDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let status = application.status {
                        StatusBadge(
                            status: status.capitalized,
                            color: application.statusColor
                        )
                    }

                    if let url = application.displayURL {
                        Link(destination: URL(string: url) ?? URL(string: "https://example.com")!) {
                            HStack(spacing: 4) {
                                Text(url)
                                    .lineLimit(1)
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.caption)
                        }
                    }
                }

                Spacer()

                // Action Buttons
                HStack(spacing: 12) {
                    ActionButton(
                        icon: application.isRunning ? "stop.fill" : "play.fill",
                        color: application.isRunning ? .coolifyError : .coolifySuccess,
                        isLoading: viewModel.isPerformingAction
                    ) {
                        Task {
                            if application.isRunning {
                                await viewModel.stopApplication()
                            } else {
                                await viewModel.startApplication()
                            }
                        }
                    }

                    ActionButton(
                        icon: "arrow.clockwise",
                        color: .coolifyWarning,
                        isLoading: viewModel.isPerformingAction
                    ) {
                        Task {
                            await viewModel.restartApplication()
                        }
                    }

                    ActionButton(
                        icon: "paperplane.fill",
                        color: .coolifyPurple,
                        isLoading: viewModel.isPerformingAction
                    ) {
                        Task {
                            await viewModel.deployApplication()
                        }
                    }
                }
            }
        }
        .padding()
        .background {
            MeshGradient.coolifyApplication()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.coolifySuccess.opacity(0.3), lineWidth: 1)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .cornerRadius(10)
            }
        }
        .disabled(isLoading)
    }
}

struct ApplicationOverviewTab: View {
    let application: Application

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Git Info
                if application.gitRepository != nil {
                    InfoCard(title: "Repository") {
                        if let repo = application.gitRepository {
                            InfoRow(label: "Repository", value: repo)
                        }
                        if let branch = application.gitBranch {
                            InfoRow(label: "Branch", value: branch)
                        }
                        if let commit = application.gitCommitSha {
                            InfoRow(label: "Commit", value: String(commit.prefix(7)))
                        }
                    }
                }

                // Build Info
                InfoCard(title: "Build Configuration") {
                    if let buildPack = application.buildPack {
                        InfoRow(label: "Build Pack", value: buildPack)
                    }
                    if let baseDir = application.baseDirectory {
                        InfoRow(label: "Base Directory", value: baseDir)
                    }
                    if let publishDir = application.publishDirectory {
                        InfoRow(label: "Publish Directory", value: publishDir)
                    }
                }

                // Resources
                InfoCard(title: "Resources") {
                    if let memory = application.limitMemory {
                        InfoRow(label: "Memory Limit", value: memory)
                    }
                    if let cpus = application.limitCpus {
                        InfoRow(label: "CPU Limit", value: cpus)
                    }
                    if let ports = application.portsExposes {
                        InfoRow(label: "Exposed Ports", value: ports)
                    }
                }

                // Health Check
                if application.healthCheckEnabled == true {
                    InfoCard(title: "Health Check") {
                        InfoRow(label: "Enabled", value: "Yes")
                        if let path = application.healthCheckPath {
                            InfoRow(label: "Path", value: path)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .font(.subheadline)
    }
}

struct ApplicationLogsTab: View {
    var viewModel: ApplicationDetailViewModel
    @State private var lineCount: Int = 100

    var body: some View {
        VStack(spacing: 0) {
            // Controls
            HStack {
                Picker("Lines", selection: $lineCount) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("500").tag(500)
                }
                .pickerStyle(.segmented)

                Button {
                    Task {
                        await viewModel.loadLogs(lines: lineCount)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding()

            // Logs
            if viewModel.isLoadingLogs {
                Spacer()
                ProgressView("Loading logs...")
                Spacer()
            } else if viewModel.logs.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Logs",
                    systemImage: "doc.text",
                    description: Text("No logs available")
                )
                Spacer()
            } else {
                ScrollView {
                    Text(viewModel.logs)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                }
                .background(Color(.systemBackground))
            }
        }
        .task {
            await viewModel.loadLogs(lines: lineCount)
        }
    }
}

struct ApplicationEnvVarsTab: View {
    var viewModel: ApplicationDetailViewModel
    @State private var showAddEnvVar = false
    @State private var newKey = ""
    @State private var newValue = ""

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoadingEnvVars {
                Spacer()
                ProgressView("Loading environment variables...")
                Spacer()
            } else if viewModel.envVars.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Environment Variables",
                    systemImage: "list.bullet.rectangle",
                    description: Text("No environment variables configured")
                )
                Spacer()
            } else {
                List {
                    ForEach(viewModel.envVars) { envVar in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(envVar.key)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(envVar.value ?? "••••••••")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddEnvVar = true
                } label: {
                    Image(systemName: "plus")
                }
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
                    TextField("Key", text: $key)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    TextField("Value", text: $value)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Add Variable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await viewModel.addEnvVar(key: key, value: value)
                            isPresented = false
                        }
                    }
                    .disabled(key.isEmpty)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    NavigationStack {
        ApplicationDetailView(application: Application(
            id: 1,
            uuid: "test-uuid",
            name: "My App",
            description: nil,
            fqdn: "https://myapp.example.com",
            status: "running",
            repositoryProjectId: nil,
            gitRepository: "https://github.com/user/repo",
            gitBranch: "main",
            gitCommitSha: "abc123def456",
            buildPack: "nixpacks",
            dockerComposeLocation: nil,
            dockerfile: nil,
            dockerfileLocation: nil,
            dockerRegistryImageName: nil,
            dockerRegistryImageTag: nil,
            portsExposes: "3000",
            portsMappings: nil,
            baseDirectory: "/",
            publishDirectory: nil,
            healthCheckEnabled: true,
            healthCheckPath: "/health",
            limitMemory: "512M",
            limitCpus: "1",
            createdAt: nil,
            updatedAt: nil
        ))
        .environment(appState)
    }
}
