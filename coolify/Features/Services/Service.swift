import Foundation

struct Service: Identifiable, Codable, Hashable {
    let uuid: String
    let name: String

    // Use uuid as Identifiable id
    var id: String { uuid }
    let description: String?
    let status: String?
    let fqdn: String?
    let dockerComposeRaw: String?
    let connectToDockerNetwork: Bool?
    let isContainerLabelEscapeEnabled: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case uuid, name, description, status, fqdn
        case dockerComposeRaw = "docker_compose_raw"
        case connectToDockerNetwork = "connect_to_docker_network"
        case isContainerLabelEscapeEnabled = "is_container_label_escape_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var statusColor: String {
        guard let status = status?.lowercased() else { return "gray" }
        if status.contains("running") {
            return "green"
        } else if status.contains("starting") || status.contains("restarting") {
            return "yellow"
        } else if status.contains("stopped") || status.contains("exited") {
            return "red"
        }
        return "gray"
    }

    var isRunning: Bool {
        status?.lowercased() == "running"
    }

    var displayURL: String? {
        guard let fqdn = fqdn, !fqdn.isEmpty else { return nil }
        return fqdn.components(separatedBy: ",").first
    }

    var urlList: [String] {
        guard let fqdn = fqdn, !fqdn.isEmpty else { return [] }
        return fqdn.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var hasDescription: Bool {
        guard let description = description else { return false }
        return !description.isEmpty
    }

    var hasURLs: Bool {
        guard let fqdn = fqdn else { return false }
        return !fqdn.isEmpty
    }

    var capitalizedStatus: String? {
        status?.capitalized
    }
}
