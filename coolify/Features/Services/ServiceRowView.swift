import SwiftUI

struct ServiceRowView: View {
    let service: Service
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            iconView
            labelsView
            Spacer()
            statusView
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }

    private var iconView: some View {
        Image(systemName: "square.stack.3d.up")
            .font(.coolifyMonoTitle2)
            .foregroundStyle(.white)
            .symbolEffect(.bounce, value: appeared)
            .frame(width: 44, height: 44)
            .background(iconBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var iconBackground: some View {
        Color.coolifyDark300
    }

    private var labelsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            nameLabel
            urlLabel
        }
    }

    private var nameLabel: some View {
        Text(service.name)
            .font(.coolifyMonoHeadline)
    }

    @ViewBuilder
    private var urlLabel: some View {
        if let url = service.displayURL {
            Text(url)
                .font(.coolifyMonoCaption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if let status = service.capitalizedStatus {
            StatusBadge(
                status: status,
                color: service.statusColor
            )
        }
    }
}

#Preview {
    ServiceRowView(service: Service(
        uuid: "test-uuid",
        name: "Test Service",
        description: "A test service",
        status: "running",
        fqdn: "https://example.com",
        dockerComposeRaw: nil,
        connectToDockerNetwork: nil,
        isContainerLabelEscapeEnabled: nil,
        createdAt: nil,
        updatedAt: nil
    ))
    .padding()
}
