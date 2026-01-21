import SwiftUI

struct DatabaseRowView: View {
    let database: Database
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            iconView
            textContent
            Spacer()
            statusBadge
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }

    private var iconView: some View {
        Image(systemName: database.databaseIcon)
            .font(.monoTitle2)
            .foregroundStyle(.databaseColor)
            .symbolEffect(.bounce, value: appeared)
            .frame(width: 44, height: 44)
            .background(Color.databaseColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            nameText
            typeText
        }
    }

    private var nameText: some View {
        Text(database.name)
            .font(.monoHeadline)
    }

    @ViewBuilder
    private var typeText: some View {
        if let displayType = database.displayType {
            Text(displayType)
                .font(.monoCaption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if let status = database.status {
            StatusBadge(
                status: status.capitalized,
                color: database.statusColor
            )
        }
    }
}

#Preview {
    List {
        DatabaseRowView(database: Database(
            uuid: "test-uuid",
            name: "PostgreSQL Production",
            description: nil,
            type: "postgres",
            status: "running",
            image: "postgres:15",
            isPublic: true,
            publicPort: 5432,
            internalDbUrl: nil,
            externalDbUrl: nil,
            limitMemory: "512M",
            limitCpus: "1",
            createdAt: nil,
            updatedAt: nil
        ))
    }
}
