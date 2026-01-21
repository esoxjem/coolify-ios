import SwiftUI

/// A row view for displaying a server resource (application, database, or service)
struct ServerResourceRowView: View {
    let resource: ServerResource
    let icon: String
    let accentColor: Color

    var body: some View {
        ResourceRowView(
            icon: icon,
            title: resource.name,
            accentColor: accentColor,
            status: resource.displayStatus,
            statusColor: resource.statusColor
        )
    }
}
