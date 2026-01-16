import SwiftUI

/// A card component for displaying databases with navigation to detail views
struct DatabasesSectionCard: View {
    let databases: [ServerResource]

    var body: some View {
        ResourceSection(title: "Databases", count: databases.count) {
            ForEach(databases) { resource in
                NavigationLink {
                    DatabaseLoaderView(uuid: resource.uuid)
                } label: {
                    ServerResourceRowView(
                        resource: resource,
                        icon: "cylinder",
                        accentColor: .coolifyDatabase
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
