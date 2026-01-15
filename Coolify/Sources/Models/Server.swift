import Foundation

struct Server: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let ip: String
    let user: String
    let port: Int
    let proxyType: String?
    let validationLogs: String?
    let logDrainNotificationSent: Bool?
    let swarmCluster: String?
    let settings: ServerSettings?
    let isBuildServer: Bool?
    let isReachable: Bool?
    let isUsable: Bool?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, description, ip, user, port
        case proxyType = "proxy_type"
        case validationLogs = "validation_logs"
        case logDrainNotificationSent = "log_drain_notification_sent"
        case swarmCluster = "swarm_cluster"
        case settings
        case isBuildServer = "is_build_server"
        case isReachable = "is_reachable"
        case isUsable = "is_usable"
    }

    var statusColor: String {
        if isReachable == true && isUsable == true {
            return "green"
        } else if isReachable == true {
            return "yellow"
        } else {
            return "red"
        }
    }

    var statusText: String {
        if isReachable == true && isUsable == true {
            return "Online"
        } else if isReachable == true {
            return "Limited"
        } else {
            return "Offline"
        }
    }
}

struct ServerSettings: Codable, Hashable {
    let id: Int?
    let concurrentBuilds: Int?
    let dynamicTimeout: Int?
    let forceDisabled: Bool?
    let isCloudflareEnabled: Bool?
    let isReachable: Bool?
    let isSwarmManager: Bool?
    let isSwarmWorker: Bool?
    let isBuildServer: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case concurrentBuilds = "concurrent_builds"
        case dynamicTimeout = "dynamic_timeout"
        case forceDisabled = "force_disabled"
        case isCloudflareEnabled = "is_cloudflare_enabled"
        case isReachable = "is_reachable"
        case isSwarmManager = "is_swarm_manager"
        case isSwarmWorker = "is_swarm_worker"
        case isBuildServer = "is_build_server"
    }
}

struct ServerResources: Codable {
    let applications: [Application]?
    let databases: [Database]?
    let services: [Service]?
}
