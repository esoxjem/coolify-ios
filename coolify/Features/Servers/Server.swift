import Foundation

struct Server: Identifiable, Codable, Hashable {
    let uuid: String
    let name: String
    let description: String?
    let ip: String
    let user: String
    let port: Int
    let proxy: ServerProxy?
    let settings: ServerSettings?
    let isCoolifyHost: Bool?
    let isReachable: Bool?
    let isUsable: Bool?

    // Use uuid as the Identifiable id
    var id: String { uuid }

    enum CodingKeys: String, CodingKey {
        case uuid, name, description, ip, user, port, proxy, settings
        case isCoolifyHost = "is_coolify_host"
        case isReachable = "is_reachable"
        case isUsable = "is_usable"
    }

    var statusColor: String {
        if isReachable == true && isUsable == true {
            return "green"
        } else if isReachable == true {
            return "yellow"
        }
        return "red"
    }

    var statusText: String {
        if isReachable == true && isUsable == true {
            return "Online"
        } else if isReachable == true {
            return "Limited"
        }
        return "Offline"
    }
}

struct ServerProxy: Codable, Hashable {
    let redirectEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case redirectEnabled = "redirect_enabled"
    }
}

struct ServerSettings: Codable, Hashable {
    let id: Int?
    let serverId: Int?
    let concurrentBuilds: Int?
    let dynamicTimeout: Int?
    let forceDisabled: Bool?
    let isBuildServer: Bool?
    let isCloudflareTunnel: Bool?
    let isJumpServer: Bool?
    let isSwarmManager: Bool?
    let isSwarmWorker: Bool?
    let isReachable: Bool?
    let isUsable: Bool?
    let isSentinelEnabled: Bool?
    let isMetricsEnabled: Bool?
    let isTerminalEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case serverId = "server_id"
        case concurrentBuilds = "concurrent_builds"
        case dynamicTimeout = "dynamic_timeout"
        case forceDisabled = "force_disabled"
        case isBuildServer = "is_build_server"
        case isCloudflareTunnel = "is_cloudflare_tunnel"
        case isJumpServer = "is_jump_server"
        case isSwarmManager = "is_swarm_manager"
        case isSwarmWorker = "is_swarm_worker"
        case isReachable = "is_reachable"
        case isUsable = "is_usable"
        case isSentinelEnabled = "is_sentinel_enabled"
        case isMetricsEnabled = "is_metrics_enabled"
        case isTerminalEnabled = "is_terminal_enabled"
    }
}

/// Individual resource returned by the /servers/{uuid}/resources endpoint
struct ServerResource: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String
    let name: String
    let status: String
    let type: String
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, status, type
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var statusColor: String {
        let lowercased = status.lowercased()
        if lowercased.contains("running") {
            return "green"
        } else if lowercased.contains("stopped") || lowercased.contains("exited") {
            return "red"
        }
        return "gray"
    }

    var displayStatus: String {
        if status.contains(":") {
            // Extract the main status before the colon (e.g., "running" from "running:healthy")
            return status.components(separatedBy: ":").first?.capitalized ?? status
        }
        return status.capitalized
    }
}

/// Grouped resources by type for display
struct ServerResources {
    let applications: [ServerResource]
    let databases: [ServerResource]
    let services: [ServerResource]

    init(resources: [ServerResource]) {
        applications = resources.filter { $0.type == "application" }
        databases = resources.filter { $0.type == "database" }
        services = resources.filter { $0.type == "service" }
    }
}
