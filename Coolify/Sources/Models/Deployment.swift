import Foundation

struct Deployment: Identifiable, Codable, Hashable {
    let id: Int?
    let deploymentUuid: String
    let applicationId: Int?
    let applicationName: String?
    let serverName: String?
    let serverId: Int?
    let pullRequestId: Int?
    let forceRebuild: Bool?
    let commit: String?
    let status: String?
    let isWebhook: Bool?
    let isApi: Bool?
    let deploymentUrl: String?
    let logs: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case deploymentUuid = "deployment_uuid"
        case applicationId = "application_id"
        case applicationName = "application_name"
        case serverName = "server_name"
        case serverId = "server_id"
        case pullRequestId = "pull_request_id"
        case forceRebuild = "force_rebuild"
        case commit, status
        case isWebhook = "is_webhook"
        case isApi = "is_api"
        case deploymentUrl = "deployment_url"
        case logs
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var statusColor: String {
        switch status?.lowercased() {
        case "finished", "success":
            return "green"
        case "in_progress", "queued", "building":
            return "yellow"
        case "failed", "error", "cancelled":
            return "red"
        default:
            return "gray"
        }
    }

    var statusIcon: String {
        switch status?.lowercased() {
        case "finished", "success":
            return "checkmark.circle.fill"
        case "in_progress", "queued", "building":
            return "arrow.clockwise"
        case "failed", "error", "cancelled":
            return "xmark.circle.fill"
        default:
            return "questionmark.circle"
        }
    }

    var isInProgress: Bool {
        let s = status?.lowercased() ?? ""
        return s == "in_progress" || s == "queued" || s == "building"
    }

    var shortCommit: String? {
        guard let commit = commit, commit.count > 7 else { return commit }
        return String(commit.prefix(7))
    }

    var formattedDate: String? {
        guard let createdAt = createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return createdAt
    }
}

struct DeployResponse: Codable {
    let deploymentUuid: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case deploymentUuid = "deployment_uuid"
        case message
    }
}
