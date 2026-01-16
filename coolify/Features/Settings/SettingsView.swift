import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddInstance = false
    @State private var showLogoutConfirmation = false
    @State private var pollingInterval: Double = 30

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            List {
                currentInstanceSection
                instancesSection
                preferencesSection
                aboutSection
                logoutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAddInstance) {
                AddInstanceView()
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
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.coolifySuccess)
                            .symbolEffect(.pulse)
                        Text(instance.name)
                            .fontWeight(.semibold)
                    }
                    Text(instance.baseURL)
                        .font(.coolifyMonoCaption)
                        .foregroundStyle(.secondary)
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
            Text("Manage multiple Coolify instances")
        }
    }

    private func instanceRow(for instance: CoolifyInstance) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(instance.name)
                    .fontWeight(instance.id == appState.currentInstance?.id ? .semibold : .regular)
                Text(instance.baseURL)
                    .font(.coolifyMonoCaption)
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

    private var preferencesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Auto-refresh Interval")
                Picker("Interval", selection: $pollingInterval) {
                    Text("15 seconds").tag(15.0)
                    Text("30 seconds").tag(30.0)
                    Text("1 minute").tag(60.0)
                    Text("5 minutes").tag(300.0)
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Preferences")
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "1.0.0")
            Link(destination: URL(string: "https://coolify.io/docs")!) {
                LabeledContent("Coolify Documentation") {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            Link(destination: URL(string: "https://github.com/coollabsio/coolify")!) {
                LabeledContent("Coolify on GitHub") {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
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
}

#Preview {
    @Previewable @State var appState = AppState()
    SettingsView()
        .environment(appState)
}
