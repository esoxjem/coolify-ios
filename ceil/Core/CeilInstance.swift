import Foundation

struct CeilInstance: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var baseURL: String
    var apiToken: String
    var createdAt: Date
    var isDemo: Bool

    init(id: UUID = UUID(), name: String, baseURL: String, apiToken: String, isDemo: Bool = false) {
        self.id = id
        self.name = name
        self.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiToken = apiToken.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Date()
        self.isDemo = isDemo
    }

    var apiBaseURL: String {
        "\(baseURL)/api/v1"
    }

    /// A pre-configured demo instance for App Store review
    static var demo: CeilInstance {
        CeilInstance(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Demo Instance",
            baseURL: "https://demo.coolify.io",
            apiToken: "demo-token",
            isDemo: true
        )
    }
}
