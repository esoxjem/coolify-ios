import Foundation

struct CoolifyInstance: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var baseURL: String
    var apiToken: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, baseURL: String, apiToken: String) {
        self.id = id
        self.name = name
        self.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiToken = apiToken.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Date()
    }

    var apiBaseURL: String {
        "\(baseURL)/api/v1"
    }
}
