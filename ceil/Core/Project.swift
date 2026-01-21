import Foundation

struct Project: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let environments: [ProjectEnvironment]?

    var environmentCount: Int {
        environments?.count ?? 0
    }
}

struct ProjectEnvironment: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String?
    let name: String
    let description: String?
    let projectId: Int?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, description
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
