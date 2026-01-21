import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    var animate: Bool = false
    var delay: Double = 0

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 16) {
            iconView
            labelsView
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                appeared = true
            }
        }
    }

    private var iconView: some View {
        Image(systemName: icon)
            .font(.monoTitle2)
            .foregroundStyle(.white)
            .symbolEffect(.bounce, value: appeared)
            .frame(width: 44, height: 44)
            .background(Color.dark300)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var labelsView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.monoSubheadline)
                .fontWeight(.semibold)

            Text(description)
                .font(.monoCaption)
                .foregroundStyle(.secondary)
        }
    }
}
