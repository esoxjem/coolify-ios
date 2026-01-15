import SwiftUI

struct DeploymentsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DeploymentsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.deployments.isEmpty {
                    ProgressView("Loading deployments...")
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
                        } label: {
                            DeploymentRowView(deployment: deployment)
                        }
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
                .foregroundColor(statusColor)
                .frame(width: 44, height: 44)
                .background(statusColor.opacity(0.1))
                .cornerRadius(10)
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
                        .foregroundColor(.secondary)
                    }

                    if let date = deployment.formattedDate {
                        Text(date)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
    @EnvironmentObject var appState: AppState
    let deployment: Deployment
    @StateObject private var viewModel = DeploymentDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
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
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

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
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
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
    DeploymentsView()
        .environmentObject(AppState())
}
