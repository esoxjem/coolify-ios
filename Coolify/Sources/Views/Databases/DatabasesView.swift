import SwiftUI

struct DatabasesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DatabasesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.databases.isEmpty {
                    ProgressView("Loading databases...")
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
                        } label: {
                            DatabaseRowView(database: db)
                        }
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: database.databaseIcon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 44, height: 44)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(database.name)
                    .font(.headline)

                if let type = database.type ?? database.image {
                    Text(type)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
    }
}

struct DatabaseDetailView: View {
    let database: Database
    @ObservedObject var viewModel: DatabasesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: database.databaseIcon)
                            .font(.largeTitle)
                            .foregroundColor(.orange)

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
                                Task {
                                    if database.isRunning {
                                        await viewModel.stopDatabase(database)
                                    } else {
                                        await viewModel.startDatabase(database)
                                    }
                                }
                            } label: {
                                Image(systemName: database.isRunning ? "stop.fill" : "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(database.isRunning ? Color.red : Color.green)
                                    .cornerRadius(10)
                            }

                            Button {
                                Task {
                                    await viewModel.restartDatabase(database)
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

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
                                    .foregroundColor(.secondary)
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
    DatabasesView()
        .environmentObject(AppState())
}
