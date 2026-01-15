import SwiftUI

struct StatusBadge: View {
    let status: String
    let color: String

    var statusColor: Color {
        switch color {
        case "green": return .coolifySuccess
        case "yellow": return .coolifyWarning
        case "red": return .coolifyError
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }
}
