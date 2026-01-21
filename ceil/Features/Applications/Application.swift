import Foundation

struct Application: Identifiable, Codable, Hashable {
    let uuid: String
    let name: String

    // Use uuid as Identifiable id
    var id: String { uuid }
    let description: String?
    let fqdn: String?
    let status: String?
    let repositoryProjectId: Int?
    let gitRepository: String?
    let gitBranch: String?
    let gitCommitSha: String?
    let buildPack: String?
    let dockerComposeLocation: String?
    let dockerfile: String?
    let dockerfileLocation: String?
    let dockerRegistryImageName: String?
    let dockerRegistryImageTag: String?
    let portsExposes: String?
    let portsMappings: String?
    let baseDirectory: String?
    let publishDirectory: String?
    let healthCheckEnabled: Bool?
    let healthCheckPath: String?
    let limitMemory: String?
    let limitCpus: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case uuid, name, description, fqdn, status
        case repositoryProjectId = "repository_project_id"
        case gitRepository = "git_repository"
        case gitBranch = "git_branch"
        case gitCommitSha = "git_commit_sha"
        case buildPack = "build_pack"
        case dockerComposeLocation = "docker_compose_location"
        case dockerfile
        case dockerfileLocation = "dockerfile_location"
        case dockerRegistryImageName = "docker_registry_image_name"
        case dockerRegistryImageTag = "docker_registry_image_tag"
        case portsExposes = "ports_exposes"
        case portsMappings = "ports_mappings"
        case baseDirectory = "base_directory"
        case publishDirectory = "publish_directory"
        case healthCheckEnabled = "health_check_enabled"
        case healthCheckPath = "health_check_path"
        case limitMemory = "limit_memory"
        case limitCpus = "limit_cpus"
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
}

struct ApplicationLogs: Codable {
    let logs: String?
}

struct EnvironmentVariable: Identifiable, Codable, Hashable {
    let id: Int?
    let uuid: String?
    let key: String
    let value: String?
    let isPreview: Bool?
    let isLiteral: Bool?
    let isMultiline: Bool?
    let isShownOnce: Bool?
    let isBuildTime: Bool?

    enum CodingKeys: String, CodingKey {
        case id, uuid, key, value
        case isPreview = "is_preview"
        case isLiteral = "is_literal"
        case isMultiline = "is_multiline"
        case isShownOnce = "is_shown_once"
        case isBuildTime = "is_build_time"
    }
}
