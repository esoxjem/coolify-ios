import SwiftUI

struct ApplicationRowView: View {
    let application: Application
    let showStatus: Bool

    var body: some View {
        ResourceRowView(
            icon: "app.connected.to.app.below.fill",
            title: application.name,
            accentColor: .coolifyApplication,
            status: showStatus ? application.status?.capitalized : nil,
            statusColor: showStatus ? application.statusColor : nil
        )
    }
}
