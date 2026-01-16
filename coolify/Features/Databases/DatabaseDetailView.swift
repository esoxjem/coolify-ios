import SwiftUI

struct DatabaseDetailView: View {
    let database: Database
    var viewModel: DatabasesViewModel
    @State private var isPerformingAction = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                configurationCard
                resourcesCard
                connectionCard
            }
            .padding()
        }
        .navigationTitle("Database")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                headerIcon
                headerText
                Spacer()
                actionButtons
            }
        }
        .padding()
        .background { MeshGradient.coolifyDatabase() }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.coolifyDatabase.opacity(0.3), lineWidth: 1)
        }
    }

    private var headerIcon: some View {
        Image(systemName: database.databaseIcon)
            .font(.largeTitle)
            .foregroundStyle(.coolifyDatabase)
            .symbolEffect(.bounce, options: .nonRepeating)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(database.name)
                .font(.title2)
                .fontWeight(.bold)
            headerStatusBadge
        }
    }

    @ViewBuilder
    private var headerStatusBadge: some View {
        if let status = database.status {
            StatusBadge(
                status: status.capitalized,
                color: database.statusColor
            )
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            toggleButton
            restartButton
        }
    }

    private var toggleButton: some View {
        Button {
            performToggleAction()
        } label: {
            Image(systemName: toggleButtonIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(toggleButtonColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(isPerformingAction)
    }

    private var toggleButtonIcon: String {
        database.isRunning ? "stop.fill" : "play.fill"
    }

    private var toggleButtonColor: Color {
        database.isRunning ? .coolifyError : .coolifySuccess
    }

    private func performToggleAction() {
        isPerformingAction = true
        Task {
            if database.isRunning {
                await viewModel.stopDatabase(database)
            } else {
                await viewModel.startDatabase(database)
            }
            isPerformingAction = false
        }
    }

    private var restartButton: some View {
        Button {
            performRestartAction()
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.coolifyWarning)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .symbolEffect(.rotate, isActive: isPerformingAction)
        }
        .disabled(isPerformingAction)
    }

    private func performRestartAction() {
        isPerformingAction = true
        Task {
            await viewModel.restartDatabase(database)
            isPerformingAction = false
        }
    }

    private var configurationCard: some View {
        InfoCard(title: "Configuration") {
            configurationRows
        }
    }

    @ViewBuilder
    private var configurationRows: some View {
        if let type = database.type {
            InfoRow(label: "Type", value: type)
        }
        if let image = database.image {
            InfoRow(label: "Image", value: image)
        }
        if database.isPublic == true, let port = database.publicPort {
            InfoRow(label: "Public Port", value: "\(port)")
        }
    }

    private var resourcesCard: some View {
        InfoCard(title: "Resources") {
            resourcesRows
        }
    }

    @ViewBuilder
    private var resourcesRows: some View {
        if let memory = database.limitMemory {
            InfoRow(label: "Memory Limit", value: memory)
        }
        if let cpus = database.limitCpus {
            InfoRow(label: "CPU Limit", value: cpus)
        }
    }

    @ViewBuilder
    private var connectionCard: some View {
        if database.isPublic == true {
            InfoCard(title: "Connection") {
                connectionContent
            }
        }
    }

    @ViewBuilder
    private var connectionContent: some View {
        if let internalUrl = database.internalDbUrl {
            VStack(alignment: .leading, spacing: 4) {
                Text("Internal URL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(internalUrl)
                    .font(.caption)
                    .fontWeight(.medium)
                    .textSelection(.enabled)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseDetailView(
            database: Database(
                uuid: "test-uuid",
                name: "PostgreSQL Production",
                description: nil,
                type: "postgres",
                status: "running",
                image: "postgres:15",
                isPublic: true,
                publicPort: 5432,
                internalDbUrl: "postgres://localhost:5432/db",
                externalDbUrl: nil,
                limitMemory: "512M",
                limitCpus: "1",
                createdAt: nil,
                updatedAt: nil
            ),
            viewModel: DatabasesViewModel()
        )
    }
}
