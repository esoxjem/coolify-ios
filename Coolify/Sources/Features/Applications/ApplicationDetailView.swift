import SwiftUI

struct ApplicationDetailView: View {
    @Environment(AppState.self) private var appState
    let application: Application
    @State private var viewModel = ApplicationDetailViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            tabPicker
            tabContent
        }
        .navigationTitle(application.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
        .task {
            await initializeViewModel()
        }
    }

    private var headerSection: some View {
        ApplicationHeaderView(
            application: currentApplication,
            viewModel: viewModel
        )
    }

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            Text("Overview").tag(0)
            Text("Logs").tag(1)
            Text("Env Vars").tag(2)
        }
        .pickerStyle(.segmented)
        .padding()
    }

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            ApplicationOverviewTab(application: currentApplication)
                .tag(0)
            ApplicationLogsTab(viewModel: viewModel)
                .tag(1)
            ApplicationEnvVarsTab(viewModel: viewModel)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var currentApplication: Application {
        viewModel.application ?? application
    }

    private var errorBinding: Binding<Bool> {
        .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )
    }

    private func initializeViewModel() async {
        if let instance = appState.currentInstance {
            viewModel.setInstance(instance, applicationUuid: application.uuid)
            await viewModel.loadApplication()
        }
    }
}

struct ApplicationOverviewTab: View {
    let application: Application

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                repositoryCard
                buildConfigCard
                resourcesCard
                healthCheckCard
            }
            .padding()
        }
    }

    @ViewBuilder
    private var repositoryCard: some View {
        if application.gitRepository != nil {
            InfoCard(title: "Repository") {
                repositoryInfoRows
            }
        }
    }

    @ViewBuilder
    private var repositoryInfoRows: some View {
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

    private var buildConfigCard: some View {
        InfoCard(title: "Build Configuration") {
            buildConfigInfoRows
        }
    }

    @ViewBuilder
    private var buildConfigInfoRows: some View {
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

    private var resourcesCard: some View {
        InfoCard(title: "Resources") {
            resourcesInfoRows
        }
    }

    @ViewBuilder
    private var resourcesInfoRows: some View {
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

    @ViewBuilder
    private var healthCheckCard: some View {
        if application.healthCheckEnabled == true {
            InfoCard(title: "Health Check") {
                healthCheckInfoRows
            }
        }
    }

    @ViewBuilder
    private var healthCheckInfoRows: some View {
        InfoRow(label: "Enabled", value: "Yes")
        if let path = application.healthCheckPath {
            InfoRow(label: "Path", value: path)
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
