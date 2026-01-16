import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.coolifyMonoTitle2)
                    .foregroundStyle(color)
                    .symbolEffect(.bounce, value: appeared)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.coolifyMonoTitle)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: value)

                Text(title)
                    .font(.coolifyMonoCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.background.secondary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        }
        .onAppear {
            appeared = true
        }
    }
}
