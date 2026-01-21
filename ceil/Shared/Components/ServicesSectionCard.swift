import SwiftUI

/// A card component for displaying services with navigation to detail views
struct ServicesSectionCard: View {
    let services: [ServerResource]

    var body: some View {
        ResourceSection(title: "Services", count: services.count) {
            ForEach(services) { resource in
                NavigationLink {
                    ServiceLoaderView(uuid: resource.uuid)
                } label: {
                    ServerResourceRowView(
                        resource: resource,
                        icon: "square.stack.3d.up",
                        accentColor: .serviceColor
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
