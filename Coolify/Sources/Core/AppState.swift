import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentInstance: CoolifyInstance?
    @Published var instances: [CoolifyInstance] = []
    @Published var isLoading: Bool = false
    @Published var error: AppError?

    private let keychainManager = KeychainManager.shared
    private var cancellables = Set<AnyCancellable>()

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

    func addInstance(_ instance: CoolifyInstance) {
        keychainManager.saveInstance(instance)
        instances = keychainManager.getAllInstances()
        setCurrentInstance(instance)
    }

    func setCurrentInstance(_ instance: CoolifyInstance) {
        keychainManager.setCurrentInstance(instance)
        currentInstance = instance
        isAuthenticated = true
    }

    func removeInstance(_ instance: CoolifyInstance) {
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

    func showError(_ error: AppError) {
        self.error = error
    }

    func clearError() {
        self.error = nil
    }
}

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
