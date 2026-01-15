import Foundation

final class KeychainManager {
    static let shared = KeychainManager()

    private let instancesKey = "coolify_instances"
    private let currentInstanceKey = "coolify_current_instance"

    private init() {}

    // MARK: - Instance Management

    func saveInstance(_ instance: CoolifyInstance) {
        var instances = getAllInstances()
        if let index = instances.firstIndex(where: { $0.id == instance.id }) {
            instances[index] = instance
        } else {
            instances.append(instance)
        }
        saveInstances(instances)
    }

    func getAllInstances() -> [CoolifyInstance] {
        guard let data = KeychainHelper.load(key: instancesKey),
              let instances = try? JSONDecoder().decode([CoolifyInstance].self, from: data) else {
            return []
        }
        return instances
    }

    func removeInstance(_ instance: CoolifyInstance) {
        var instances = getAllInstances()
        instances.removeAll { $0.id == instance.id }
        saveInstances(instances)
    }

    private func saveInstances(_ instances: [CoolifyInstance]) {
        guard let data = try? JSONEncoder().encode(instances) else { return }
        KeychainHelper.save(key: instancesKey, data: data)
    }

    // MARK: - Current Instance

    func setCurrentInstance(_ instance: CoolifyInstance) {
        guard let data = try? JSONEncoder().encode(instance) else { return }
        KeychainHelper.save(key: currentInstanceKey, data: data)
    }

    func getCurrentInstance() -> CoolifyInstance? {
        guard let data = KeychainHelper.load(key: currentInstanceKey),
              let instance = try? JSONDecoder().decode(CoolifyInstance.self, from: data) else {
            return nil
        }
        return instance
    }

    func clearAll() {
        KeychainHelper.delete(key: instancesKey)
        KeychainHelper.delete(key: currentInstanceKey)
    }
}

// MARK: - Keychain Helper

enum KeychainHelper {
    static func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
