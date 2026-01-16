import Foundation

struct Database: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let type: String?
    let status: String?
    let image: String?
    let isPublic: Bool?
    let publicPort: Int?
    let internalDbUrl: String?
    let externalDbUrl: String?
    let limitMemory: String?
    let limitCpus: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, description, type, status, image
        case isPublic = "is_public"
        case publicPort = "public_port"
        case internalDbUrl = "internal_db_url"
        case externalDbUrl = "external_db_url"
        case limitMemory = "limit_memory"
        case limitCpus = "limit_cpus"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Database {
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

    var databaseIcon: String {
        let dbType = type?.lowercased() ?? image?.lowercased() ?? ""
        return iconForDatabaseType(dbType)
    }

    var displayType: String? {
        type ?? image
    }

    private func iconForDatabaseType(_ dbType: String) -> String {
        if dbType.contains("postgres") {
            return "cylinder.split.1x2"
        } else if dbType.contains("mysql") || dbType.contains("mariadb") {
            return "cylinder"
        } else if dbType.contains("mongo") {
            return "leaf"
        } else if dbType.contains("redis") {
            return "memorychip"
        } else if dbType.contains("clickhouse") {
            return "chart.bar"
        } else {
            return "externaldrive"
        }
    }
}

struct DatabaseBackup: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String?
    let filename: String?
    let status: String?
    let size: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, filename, status, size
        case createdAt = "created_at"
    }
}
