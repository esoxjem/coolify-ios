import SwiftUI

/// A card component for displaying applications with navigation to detail views
struct ApplicationsSectionCard: View {
    let applications: [ServerResource]

    var body: some View {
        ResourceSection(title: "Applications", count: applications.count) {
            ForEach(applications) { resource in
                NavigationLink {
                    ApplicationLoaderView(uuid: resource.uuid)
                } label: {
                    ServerResourceRowView(
                        resource: resource,
                        icon: "app.connected.to.app.below.fill",
                        accentColor: .coolifyApplication
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
