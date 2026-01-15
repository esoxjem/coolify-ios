import Foundation

struct Service: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let status: String?
    let fqdn: String?
    let dockerComposeRaw: String?
    let connectToDockerNetwork: Bool?
    let isContainerLabelEscapeEnabled: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, description, status, fqdn
        case dockerComposeRaw = "docker_compose_raw"
        case connectToDockerNetwork = "connect_to_docker_network"
        case isContainerLabelEscapeEnabled = "is_container_label_escape_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var statusColor: String {
        switch status?.lowercased() {
        case "running":
            return "green"
        case "starting", "restarting":
            return "yellow"
        case "stopped", "exited":
            return "red"
        default:
            return "gray"
        }
    }

    var isRunning: Bool {
        status?.lowercased() == "running"
    }

    var displayURL: String? {
        guard let fqdn = fqdn, !fqdn.isEmpty else { return nil }
        return fqdn.components(separatedBy: ",").first
    }
}
