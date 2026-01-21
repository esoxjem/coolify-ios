import SwiftUI

struct ResourceSection<Content: View>: View {
    let title: String
    let count: Int
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.monoHeadline)
                Spacer()
                Text("\(count)")
                    .font(.monoSubheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                content()
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
