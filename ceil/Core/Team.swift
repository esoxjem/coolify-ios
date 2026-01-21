import Foundation

struct Team: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let personalTeam: Bool?
    let createdAt: String?
    let updatedAt: String?
    let members: [TeamMember]?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case personalTeam = "personal_team"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case members
    }
}

struct TeamMember: Identifiable, Codable, Hashable {
    let id: Int
    let name: String?
    let email: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"
    }
}
