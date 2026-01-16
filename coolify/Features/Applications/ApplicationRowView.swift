import SwiftUI

struct ApplicationRowView: View {
    let application: Application
    let showStatus: Bool
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            iconView
            contentView
            Spacer()
            statusView
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }

    private var iconView: some View {
        Image(systemName: "app.badge")
            .font(.coolifyMonoTitle2)
            .foregroundStyle(.coolifySuccess)
            .symbolEffect(.bounce, value: appeared)
            .frame(width: 44, height: 44)
            .background(Color.coolifySuccess.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(application.name)
                .font(.coolifyMonoHeadline)
            subtitleText
        }
    }

    @ViewBuilder
    private var subtitleText: some View {
        if let repo = application.gitRepository {
            Text(repo)
                .font(.coolifyMonoCaption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        } else if let fqdn = application.displayURL {
            Text(fqdn)
                .font(.coolifyMonoCaption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if showStatus, let status = application.status {
            StatusBadge(
                status: status.capitalized,
                color: application.statusColor
            )
        }
    }
}
