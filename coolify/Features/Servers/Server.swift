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

struct ServerResources: Codable {
    let applications: [Application]?
    let databases: [Database]?
    let services: [Service]?
}
