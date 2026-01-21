import SwiftUI

/// A card component for displaying servers with navigation to detail views
struct ServersSectionCard: View {
    let servers: [Server]
    var serverResources: [String: ServerResources]?
    let namespace: Namespace.ID

    var body: some View {
        ResourceSection(title: "Servers", count: servers.count) {
            if servers.isEmpty {
                Text("No servers")
                    .font(.monoSubheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(servers) { server in
                    NavigationLink {
                        ServerDetailView(server: server)
                            .navigationTransition(.zoom(sourceID: "server-\(server.id)", in: namespace))
                    } label: {
                        ServerCardRowView(
                            server: server,
                            resources: serverResources?[server.uuid]
                        )
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: "server-\(server.id)", in: namespace)
                }
            }
        }
    }
}

/// A row view for servers inside the card with clean vertical layout
private struct ServerCardRowView: View {
    let server: Server
    var resources: ServerResources?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.monoTitle3)
                .foregroundStyle(.serverColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(server.name)
                    .font(.monoSubheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                // Status + Resources
                HStack(spacing: 8) {
                    StatusBadge(status: server.statusText, color: server.statusColor)

                    if let resources = resources, hasResources(resources) {
                        resourceCountsView(resources)
                    }
                }

                // Host
                Text(server.ip)
                    .font(.monoCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.monoCaption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func hasResources(_ resources: ServerResources) -> Bool {
        !resources.applications.isEmpty || !resources.databases.isEmpty || !resources.services.isEmpty
    }

    @ViewBuilder
    private func resourceCountsView(_ resources: ServerResources) -> some View {
        HStack(spacing: 6) {
            if !resources.applications.isEmpty {
                Label("\(resources.applications.count)", systemImage: "app.badge")
                    .font(.monoCaption)
                    .foregroundStyle(.applicationColor)
            }
            if !resources.databases.isEmpty {
                Label("\(resources.databases.count)", systemImage: "cylinder")
                    .font(.monoCaption)
                    .foregroundStyle(.databaseColor)
            }
            if !resources.services.isEmpty {
                Label("\(resources.services.count)", systemImage: "square.stack.3d.up")
                    .font(.monoCaption)
                    .foregroundStyle(.serviceColor)
            }
        }
    }
}
