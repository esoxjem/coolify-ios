import SwiftUI
import Observation

@Observable
@MainActor
final class AppState {
    var isAuthenticated: Bool = false
    var currentInstance: CeilInstance?
    var instances: [CeilInstance] = []
    var isLoading: Bool = false
    var error: AppError?

    private let keychainManager = KeychainManager.shared

    init() {
        loadSavedInstances()
    }

    func loadSavedInstances() {
        instances = keychainManager.getAllInstances()
        if let current = keychainManager.getCurrentInstance() {
            currentInstance = current
            isAuthenticated = true
        }
    }

    func addInstance(_ instance: CeilInstance) {
        keychainManager.saveInstance(instance)
        instances = keychainManager.getAllInstances()
        setCurrentInstance(instance)
    }

    func setCurrentInstance(_ instance: CeilInstance) {
        keychainManager.setCurrentInstance(instance)
        currentInstance = instance
        isAuthenticated = true
    }

    func updateInstance(_ instance: CeilInstance) {
        keychainManager.saveInstance(instance)  // Already handles upsert
        instances = keychainManager.getAllInstances()

        // Refresh currentInstance if it was updated
        if currentInstance?.id == instance.id {
            currentInstance = instance
            keychainManager.setCurrentInstance(instance)
        }
    }

    func removeInstance(_ instance: CeilInstance) {
        keychainManager.removeInstance(instance)
        instances = keychainManager.getAllInstances()

        if currentInstance?.id == instance.id {
            currentInstance = instances.first
            if currentInstance == nil {
                isAuthenticated = false
            } else {
                keychainManager.setCurrentInstance(currentInstance!)
            }
        }
    }

    func logout() {
        keychainManager.clearAll()
        instances = []
        currentInstance = nil
        isAuthenticated = false
    }

    // MARK: - Demo Mode

    /// Whether the app is currently in demo mode
    var isDemoMode: Bool {
        currentInstance?.isDemo ?? false
    }

    /// Enter demo mode with a pre-configured demo instance
    func enterDemoMode() {
        currentInstance = CeilInstance.demo
        isAuthenticated = true
    }

    /// Exit demo mode and return to onboarding
    func exitDemoMode() {
        currentInstance = nil
        isAuthenticated = false
    }

    func showError(_ error: AppError) {
        self.error = error
    }

    func clearError() {
        error = nil
    }
}

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
