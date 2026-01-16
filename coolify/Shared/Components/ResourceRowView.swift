import SwiftUI

struct ResourceRowView: View {
    let icon: String
    let title: String
    let accentColor: Color
    let status: String?
    let statusColor: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.coolifyMonoTitle3)
                .foregroundStyle(accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.coolifyMonoSubheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if let status = status, let statusColor = statusColor {
                    StatusBadge(status: status, color: statusColor)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.coolifyMonoCaption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
