import SwiftUI

struct DeploymentRowView: View {
    let deployment: Deployment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            statusIcon
            deploymentInfo
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    private var statusIcon: some View {
        Image(systemName: deployment.statusIcon)
            .font(.coolifyMonoTitle2)
            .foregroundStyle(statusColor)
            .frame(width: 44, height: 44)
            .background(statusColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .symbolEffect(.pulse, isActive: deployment.isInProgress)
    }

    private var deploymentInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deployment.displayName)
                .font(.coolifyMonoHeadline)
                .lineLimit(1)

            statusBadge

            metadataRow
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 8) {
            commitLabel
            dateLabel
        }
    }

    @ViewBuilder
    private var commitLabel: some View {
        if let commit = deployment.shortCommit {
            HStack(spacing: 4) {
                Image(systemName: "number")
                    .font(.coolifyMonoCaption2)
                Text(commit)
            }
            .font(.coolifyMonoCaption)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var dateLabel: some View {
        if let date = deployment.formattedDate {
            Text(date)
                .font(.coolifyMonoCaption)
                .foregroundStyle(.secondary)
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

    private var statusColor: Color {
        switch deployment.statusColor {
        case "green": return .coolifySuccess
        case "yellow": return .coolifyWarning
        case "red": return .coolifyError
        default: return .gray
        }
    }
}
