import SwiftUI

struct ServicesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ServicesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.services.isEmpty {
                    ProgressView("Loading services...")
                } else if viewModel.services.isEmpty {
                    ContentUnavailableView(
                        "No Services",
                        systemImage: "square.stack.3d.up",
                        description: Text("No services found in this instance")
                    )
                } else {
                    List(viewModel.services) { service in
                        NavigationLink {
                            ServiceDetailView(service: service, viewModel: viewModel)
                        } label: {
                            ServiceRowView(service: service)
                        }
                        .swipeActions(edge: .trailing) {
                            if service.isRunning {
                                Button {
                                    Task {
                                        await viewModel.stopService(service)
                                    }
                                } label: {
                                    Label("Stop", systemImage: "stop.fill")
                                }
                                .tint(.red)
                            } else {
                                Button {
                                    Task {
                                        await viewModel.startService(service)
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
            .navigationTitle("Services")
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
                await viewModel.loadServices()
            }
        }
    }
}

struct ServiceRowView: View {
    let service: Service

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 44, height: 44)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)

                if let url = service.displayURL {
                    Text(url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let status = service.status {
                StatusBadge(
                    status: status.capitalized,
                    color: service.statusColor
                )
            }
        }
        .padding(.vertical, 4)
    }
}

struct ServiceDetailView: View {
    let service: Service
    @ObservedObject var viewModel: ServicesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "square.stack.3d.up")
                            .font(.largeTitle)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            if let status = service.status {
                                StatusBadge(
                                    status: status.capitalized,
                                    color: service.statusColor
                                )
                            }
                        }

                        Spacer()

                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    if service.isRunning {
                                        await viewModel.stopService(service)
                                    } else {
                                        await viewModel.startService(service)
                                    }
                                }
                            } label: {
                                Image(systemName: service.isRunning ? "stop.fill" : "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(service.isRunning ? Color.red : Color.green)
                                    .cornerRadius(10)
                            }

                            Button {
                                Task {
                                    await viewModel.restartService(service)
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

                // URL
                if let url = service.fqdn, !url.isEmpty {
                    InfoCard(title: "URLs") {
                        ForEach(url.components(separatedBy: ","), id: \.self) { singleUrl in
                            Link(destination: URL(string: singleUrl.trimmingCharacters(in: .whitespaces)) ?? URL(string: "https://example.com")!) {
                                HStack {
                                    Text(singleUrl.trimmingCharacters(in: .whitespaces))
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }

                // Description
                if let description = service.description, !description.isEmpty {
                    InfoCard(title: "Description") {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ServicesView()
        .environmentObject(AppState())
}
