import SwiftUI

struct ServicesView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ServicesViewModel()
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.services.isEmpty {
                    ContentUnavailableView {
                        Label("Loading", systemImage: "square.stack.3d.up")
                            .symbolEffect(.pulse)
                    } description: {
                        Text("Fetching services...")
                    }
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
                                .navigationTransition(.zoom(sourceID: service.id, in: namespace))
                        } label: {
                            ServiceRowView(service: service)
                        }
                        .matchedTransitionSource(id: service.id, in: namespace)
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
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up")
                .font(.title2)
                .foregroundStyle(.purple)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 44, height: 44)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)

                if let url = service.displayURL {
                    Text(url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        .onAppear { appeared = true }
    }
}

struct ServiceDetailView: View {
    let service: Service
    var viewModel: ServicesViewModel
    @State private var isPerformingAction = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with Mesh Gradient
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "square.stack.3d.up")
                            .font(.largeTitle)
                            .foregroundStyle(.purple)
                            .symbolEffect(.bounce, options: .nonRepeating)

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
                                isPerformingAction = true
                                Task {
                                    if service.isRunning {
                                        await viewModel.stopService(service)
                                    } else {
                                        await viewModel.startService(service)
                                    }
                                    isPerformingAction = false
                                }
                            } label: {
                                Image(systemName: service.isRunning ? "stop.fill" : "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(service.isRunning ? Color.red : Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isPerformingAction)

                            Button {
                                isPerformingAction = true
                                Task {
                                    await viewModel.restartService(service)
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
                            .purple.opacity(0.1), .indigo.opacity(0.1), .purple.opacity(0.1),
                            .indigo.opacity(0.05), .purple.opacity(0.1), .indigo.opacity(0.05),
                            .purple.opacity(0.1), .indigo.opacity(0.1), .purple.opacity(0.1)
                        ]
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

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
                            .foregroundStyle(.secondary)
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
    @Previewable @State var appState = AppState()
    ServicesView()
        .environment(appState)
}
