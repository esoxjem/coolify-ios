import SwiftUI

struct ServerRowView: View {
    let server: Server
    var resources: ServerResources?
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.monoTitle2)
                .foregroundStyle(.serverColor)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.serverColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.monoHeadline)

                HStack(spacing: 8) {
                    StatusBadge(status: server.statusText, color: server.statusColor)

                    if let resources = resources {
                        resourceCountsView(resources)
                    }
                }

                Text(server.ip)
                    .font(.monoCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private func resourceCountsView(_ resources: ServerResources) -> some View {
        HStack(spacing: 8) {
            if !resources.applications.isEmpty {
                Label("\(resources.applications.count)", systemImage: "app.badge")
                    .font(.monoCaption)
                    .foregroundStyle(.statusSuccess)
            }
            if !resources.databases.isEmpty {
                Label("\(resources.databases.count)", systemImage: "cylinder")
                    .font(.monoCaption)
                    .foregroundStyle(.databaseColor)
            }
            if !resources.services.isEmpty {
                Label("\(resources.services.count)", systemImage: "square.stack.3d.up")
                    .font(.monoCaption)
                    .foregroundStyle(.brandPurple)
            }
        }
    }
}
