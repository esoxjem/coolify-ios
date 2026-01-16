import SwiftUI

struct DeploymentsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DeploymentsViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.deployments.isEmpty {
                    ContentUnavailableView {
                        Label("Loading", systemImage: "arrow.triangle.2.circlepath")
                            .symbolEffect(.rotate)
                    } description: {
                        Text("Fetching deployments...")
                    }
                } else if viewModel.deployments.isEmpty {
                    ContentUnavailableView(
                        "No Deployments",
                        systemImage: "arrow.triangle.2.circlepath",
                        description: Text("No active deployments found")
                    )
                } else {
                    List(viewModel.deployments) { deployment in
                        NavigationLink {
                            DeploymentDetailView(deployment: deployment)
                                .navigationTransition(.zoom(sourceID: deployment.id, in: namespace))
                        } label: {
                            DeploymentRowView(deployment: deployment)
                        }
                        .matchedTransitionSource(id: deployment.id, in: namespace)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Deployments")
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance)
                await viewModel.loadDeployments()
            }
        }
    }
}

struct DeploymentRowView: View {
    let deployment: Deployment

    var statusColor: Color {
        switch deployment.statusColor {
        case "green": return .green
        case "yellow": return .yellow
        case "red": return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: deployment.statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)
                .frame(width: 44, height: 44)
                .background(statusColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .symbolEffect(.pulse, isActive: deployment.isInProgress)

            VStack(alignment: .leading, spacing: 4) {
                Text(deployment.applicationName ?? "Unknown App")
                    .font(.headline)

                HStack(spacing: 8) {
                    if let commit = deployment.shortCommit {
                        HStack(spacing: 4) {
                            Image(systemName: "number")
                                .font(.caption2)
                            Text(commit)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    if let date = deployment.formattedDate {
                        Text(date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let status = deployment.status {
                StatusBadge(
                    status: status.replacingOccurrences(of: "_", with: " ").capitalized,
                    color: deployment.statusColor
                )
            }
        }
        .padding(.vertical, 4)
    }
}

struct DeploymentDetailView: View {
    @Environment(AppState.self) private var appState
    let deployment: Deployment
    @State private var viewModel = DeploymentDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with Mesh Gradient
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(deployment.applicationName ?? "Deployment")
                                .font(.title2)
                                .fontWeight(.bold)

                            if let status = deployment.status {
                                StatusBadge(
                                    status: status.replacingOccurrences(of: "_", with: " ").capitalized,
                                    color: deployment.statusColor
                                )
                            }
                        }

                        Spacer()

                        if deployment.isInProgress {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
                .padding()
                .background {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ],
                        colors: [
                            .blue.opacity(0.1), .cyan.opacity(0.1), .blue.opacity(0.1),
                            .cyan.opacity(0.05), .blue.opacity(0.1), .cyan.opacity(0.05),
                            .blue.opacity(0.1), .cyan.opacity(0.1), .blue.opacity(0.1)
                        ]
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Details
                InfoCard(title: "Details") {
                    if let commit = deployment.commit {
                        InfoRow(label: "Commit", value: commit)
                    }
                    if let server = deployment.serverName {
                        InfoRow(label: "Server", value: server)
                    }
                    if let date = deployment.formattedDate {
                        InfoRow(label: "Started", value: date)
                    }
                    if deployment.isWebhook == true {
                        InfoRow(label: "Triggered by", value: "Webhook")
                    } else if deployment.isApi == true {
                        InfoRow(label: "Triggered by", value: "API")
                    }
                }

                // Logs
                if let logs = viewModel.deployment?.logs ?? deployment.logs, !logs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Logs")
                                .font(.headline)
                            Spacer()
                            Button {
                                Task {
                                    await viewModel.refresh()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .symbolEffect(.rotate, isActive: viewModel.isLoading)
                            }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(logs)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        .frame(maxHeight: 400)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
        .navigationTitle("Deployment")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance, deploymentUuid: deployment.deploymentUuid)
                await viewModel.loadDeployment()
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    DeploymentsView()
        .environment(appState)
}
