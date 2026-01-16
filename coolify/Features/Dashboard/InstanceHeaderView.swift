import SwiftUI

struct InstanceHeaderView: View {
    let instance: CoolifyInstance
    @State private var isConnected = true

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instance.name)
                        .font(.coolifyMonoTitle3)
                        .fontWeight(.semibold)

                    Text(instance.baseURL)
                        .font(.coolifyMonoCaption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.coolifySuccess)
                    .font(.coolifyMonoTitle2)
                    .symbolEffect(.pulse, options: .repeating, value: isConnected)
            }
        }
        .padding()
        .background {
            MeshGradient.coolifyHeader()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.coolifyPurple.opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal)
    }
}
