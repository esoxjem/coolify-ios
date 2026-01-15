import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddInstance = false
    @State private var showLogoutConfirmation = false
    @State private var pollingInterval: Double = 30

    var body: some View {
        NavigationStack {
            List {
                // Current Instance
                Section {
                    if let instance = appState.currentInstance {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(instance.name)
                                    .fontWeight(.semibold)
                            }

                            Text(instance.baseURL)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Current Instance")
                }

                // All Instances
                Section {
                    ForEach(appState.instances) { instance in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(instance.name)
                                    .fontWeight(instance.id == appState.currentInstance?.id ? .semibold : .regular)

                                Text(instance.baseURL)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if instance.id == appState.currentInstance?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appState.setCurrentInstance(instance)
                        }
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

                // Preferences
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

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://coolify.io/docs")!) {
                        HStack {
                            Text("Coolify Documentation")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/coollabsio/coolify")!) {
                        HStack {
                            Text("Coolify on GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }

                // Logout
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
            .navigationTitle("Settings")
            .sheet(isPresented: $showAddInstance) {
                AddInstanceView()
            }
            .confirmationDialog(
                "Sign Out",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    appState.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all saved instances and their API tokens from this device.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
