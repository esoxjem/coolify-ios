import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddInstance = false
    @State private var showLogoutConfirmation = false
    @State private var instanceToEdit: CeilInstance?

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            List {
                if appState.isDemoMode {
                    demoModeSection
                } else {
                    currentInstanceSection
                    instancesSection
                }
                aboutSection
                if appState.isDemoMode {
                    exitDemoSection
                } else {
                    logoutSection
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAddInstance) {
                AddInstanceView()
            }
            .sheet(item: $instanceToEdit) { instance in
                AddInstanceView(instanceToEdit: instance)
            }
            .confirmationDialog("Sign Out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { appState.logout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all saved instances and their API tokens from this device.")
            }
        }
    }

    @ViewBuilder
    private var currentInstanceSection: some View {
        Section {
            if let instance = appState.currentInstance {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.statusSuccess)
                                .symbolEffect(.pulse)
                            Text(instance.name)
                                .fontWeight(.semibold)
                        }
                        Text(instance.baseURL)
                            .font(.monoCaption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        instanceToEdit = instance
                    } label: {
                        Image(systemName: "pencil")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Current Instance")
        }
    }

    private var instancesSection: some View {
        Section {
            ForEach(appState.instances) { instance in
                instanceRow(for: instance)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    appState.removeInstance(appState.instances[index])
                }
            }

            Button {
                showAddInstance = true
            } label: {
                Label("Add Instance", systemImage: "plus.circle")
            }
        } header: {
            Text("Instances")
        } footer: {
            Text("Manage multiple servers")
        }
    }

    private func instanceRow(for instance: CeilInstance) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(instance.name)
                Text(instance.baseURL)
                    .font(.monoCaption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if instance.id == appState.currentInstance?.id {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            appState.setCurrentInstance(instance)
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "0.1")
            Link(destination: URL(string: "https://github.com/esoxjem/coolify-ios/issues")!) {
                LabeledContent("Report an Issue") {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        } footer: {
            VStack(spacing: 16) {
                Text("Ciel is an unofficial third-party client.\nNot affiliated with or endorsed by Coolify or coolLabs.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Link(destination: URL(string: "https://x.com/ES0XJEM")!) {
                    Text("Made with 💜 by ES0XJEM")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
        }
    }

    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                showLogoutConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Sign Out of All Instances")
                    Spacer()
                }
            }
        }
    }

    // MARK: - Demo Mode Sections

    private var demoModeSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.brandPurple)
                        Text("Demo Instance")
                            .fontWeight(.semibold)
                    }
                    Text("Explore the app with sample data")
                        .font(.monoCaption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)

            Button {
                showAddInstance = true
            } label: {
                Label("Connect Real Instance", systemImage: "server.rack")
            }
        } header: {
            Text("Demo Mode")
        } footer: {
            Text("You're exploring with mock data. Connect a real Coolify instance to manage your servers.")
        }
    }

    private var exitDemoSection: some View {
        Section {
            Button(role: .destructive) {
                appState.exitDemoMode()
            } label: {
                HStack {
                    Spacer()
                    Text("Exit Demo Mode")
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    SettingsView()
        .environment(appState)
}
