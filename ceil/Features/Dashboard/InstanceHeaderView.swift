import SwiftUI

struct InstanceHeaderView: View {
    let instance: CeilInstance
    @State private var isConnected = true

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instance.name)
                        .font(.monoTitle3)
                        .fontWeight(.semibold)

                    Text(instance.baseURL)
                        .font(.monoCaption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.statusSuccess)
                    .font(.monoTitle2)
                    .symbolEffect(.pulse, options: .repeating, value: isConnected)
            }
        }
        .padding()
        .background {
            MeshGradient.headerGradient()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.brandPurple.opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal)
    }
}
