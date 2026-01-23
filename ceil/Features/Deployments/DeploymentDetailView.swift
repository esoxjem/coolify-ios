import SwiftUI

struct DeploymentDetailView: View {
    @Environment(AppState.self) private var appState
    let deployment: Deployment
    @State private var viewModel = DeploymentDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                detailsCard
                logsSection
            }
            .padding()
        }
        .navigationTitle("Deployment")
        .navigationBarTitleDisplayMode(.inline)
        .task { await initialLoad() }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerContent
        }
        .padding()
        .background { MeshGradient.deploymentGradient() }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay { headerBorder }
    }

    private var headerContent: some View {
        HStack {
            titleAndStatus
            Spacer()
            progressIndicator
        }
    }

    private var titleAndStatus: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deployment.displayName)
                .font(.monoTitle2)
                .fontWeight(.bold)
            statusBadge
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if deployment.status != nil {
            StatusBadge(
                status: deployment.displayStatus,
                color: deployment.statusColor
            )
        }
    }

    @ViewBuilder
    private var progressIndicator: some View {
        if deployment.isInProgress {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }

    private var headerBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(.deploymentColor.opacity(0.3), lineWidth: 1)
    }

    private var detailsCard: some View {
        InfoCard(title: "Details") {
            commitRow
            serverRow
            startedRow
            triggerRow
        }
    }

    @ViewBuilder
    private var commitRow: some View {
        if let commit = deployment.commit {
            InfoRow(label: "Commit", value: commit)
        }
    }

    @ViewBuilder
    private var serverRow: some View {
        if let server = deployment.serverName {
            InfoRow(label: "Server", value: server)
        }
    }

    @ViewBuilder
    private var startedRow: some View {
        if let date = deployment.formattedDate {
            InfoRow(label: "Started", value: date)
        }
    }

    @ViewBuilder
    private var triggerRow: some View {
        if let trigger = deployment.triggerSource {
            InfoRow(label: "Triggered by", value: trigger)
        }
    }

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Logs")
                .font(.monoHeadline)

            LogsView(
                logs: currentLogs,
                isLoading: viewModel.isLoading,
                onRefresh: { await viewModel.refresh() }
            )
            .frame(height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var currentLogs: String {
        viewModel.deployment?.logs ?? deployment.logs ?? ""
    }

    private func initialLoad() async {
        guard let instance = appState.currentInstance else { return }
        viewModel.setInstance(instance, deploymentUuid: deployment.deploymentUuid)
        await viewModel.loadDeployment()
    }
}
