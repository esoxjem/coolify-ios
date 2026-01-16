import SwiftUI

struct DatabasesView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DatabasesViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.databases.isEmpty {
                    ContentUnavailableView {
                        Label("Loading", systemImage: "cylinder")
                            .symbolEffect(.pulse)
                    } description: {
                        Text("Fetching databases...")
                    }
                } else if viewModel.databases.isEmpty {
                    ContentUnavailableView(
                        "No Databases",
                        systemImage: "cylinder",
                        description: Text("No databases found in this instance")
                    )
                } else {
                    List(viewModel.databases) { db in
                        NavigationLink {
                            DatabaseDetailView(database: db, viewModel: viewModel)
                                .navigationTransition(.zoom(sourceID: db.id, in: namespace))
                        } label: {
                            DatabaseRowView(database: db)
                        }
                        .matchedTransitionSource(id: db.id, in: namespace)
                        .swipeActions(edge: .trailing) {
                            if db.isRunning {
                                Button {
                                    Task {
                                        await viewModel.stopDatabase(db)
                                    }
                                } label: {
                                    Label("Stop", systemImage: "stop.fill")
                                }
                                .tint(.red)
                            } else {
                                Button {
                                    Task {
                                        await viewModel.startDatabase(db)
                                    }
                                } label: {
                                    Label("Start", systemImage: "play.fill")
                                }
                                .tint(.green)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Databases")
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .task {
            if let instance = appState.currentInstance {
                viewModel.setInstance(instance)
                await viewModel.loadDatabases()
            }
        }
    }
}

struct DatabaseRowView: View {
    let database: Database
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: database.databaseIcon)
                .font(.title2)
                .foregroundStyle(.orange)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(database.name)
                    .font(.headline)

                if let type = database.type ?? database.image {
                    Text(type)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let status = database.status {
                StatusBadge(
                    status: status.capitalized,
                    color: database.statusColor
                )
            }
        }
        .padding(.vertical, 4)
        .onAppear { appeared = true }
    }
}

struct DatabaseDetailView: View {
    let database: Database
    var viewModel: DatabasesViewModel
    @State private var isPerformingAction = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with Mesh Gradient
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: database.databaseIcon)
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                            .symbolEffect(.bounce, options: .nonRepeating)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(database.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            if let status = database.status {
                                StatusBadge(
                                    status: status.capitalized,
                                    color: database.statusColor
                                )
                            }
                        }

                        Spacer()

                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                isPerformingAction = true
                                Task {
                                    if database.isRunning {
                                        await viewModel.stopDatabase(database)
                                    } else {
                                        await viewModel.startDatabase(database)
                                    }
                                    isPerformingAction = false
                                }
                            } label: {
                                Image(systemName: database.isRunning ? "stop.fill" : "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(database.isRunning ? Color.red : Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isPerformingAction)

                            Button {
                                isPerformingAction = true
                                Task {
                                    await viewModel.restartDatabase(database)
                                    isPerformingAction = false
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .symbolEffect(.rotate, isActive: isPerformingAction)
                            }
                            .disabled(isPerformingAction)
                        }
                    }
                }
                .padding()
                .background {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ],
                        colors: [
                            .orange.opacity(0.1), .yellow.opacity(0.1), .orange.opacity(0.1),
                            .yellow.opacity(0.05), .orange.opacity(0.1), .yellow.opacity(0.05),
                            .orange.opacity(0.1), .yellow.opacity(0.1), .orange.opacity(0.1)
                        ]
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Database Info
                InfoCard(title: "Configuration") {
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

                // Resources
                InfoCard(title: "Resources") {
                    if let memory = database.limitMemory {
                        InfoRow(label: "Memory Limit", value: memory)
                    }
                    if let cpus = database.limitCpus {
                        InfoRow(label: "CPU Limit", value: cpus)
                    }
                }

                // Connection Info (if public)
                if database.isPublic == true {
                    InfoCard(title: "Connection") {
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
            }
            .padding()
        }
        .navigationTitle("Database")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    DatabasesView()
        .environment(appState)
}
