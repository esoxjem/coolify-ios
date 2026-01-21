import SwiftUI

struct StatusBadge: View {
    let status: String
    let color: String

    var statusColor: Color {
        switch color {
        case "green": return .statusSuccess
        case "yellow": return .statusWarning
        case "red": return .statusError
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status)
                .font(.monoCaption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
        .fixedSize()
    }
}
