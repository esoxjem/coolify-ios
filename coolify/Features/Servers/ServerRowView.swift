import SwiftUI

struct ServerRowView: View {
    let server: Server
    var resources: ServerResources?
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.coolifyMonoTitle2)
                .foregroundStyle(.coolifyServer)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.coolifyServer.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.coolifyMonoHeadline)

                HStack(spacing: 8) {
                    StatusBadge(status: server.statusText, color: server.statusColor)

                    if let resources = resources {
                        resourceCountsView(resources)
                    }
                }

                Text(server.ip)
                    .font(.coolifyMonoCaption)
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
                    .font(.coolifyMonoCaption)
                    .foregroundStyle(.coolifySuccess)
            }
            if !resources.databases.isEmpty {
                Label("\(resources.databases.count)", systemImage: "cylinder")
                    .font(.coolifyMonoCaption)
                    .foregroundStyle(.coolifyDatabase)
            }
            if !resources.services.isEmpty {
                Label("\(resources.services.count)", systemImage: "square.stack.3d.up")
                    .font(.coolifyMonoCaption)
                    .foregroundStyle(.coolifyPurple)
            }
        }
    }
}
