import SwiftUI

struct ServerRowView: View {
    let server: Server
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.title2)
                .foregroundStyle(.coolifyServer)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.coolifyServer.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)

                Text(server.ip)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(status: server.statusText, color: server.statusColor)
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }
}
