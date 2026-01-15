import SwiftUI

extension Color {
    static let coolifyPurple = Color(hex: "6B16ED")
    static let coolifyPurpleLight = Color(hex: "7317FF")
    static let coolifyPurpleDark = Color(hex: "5A12C7")
    static let coolifyPurpleMuted = Color(hex: "4A0FA3")
    static let coolifyPurpleBackground = Color(hex: "F5F0FF")

    static let coolifySuccess = Color(hex: "22C55E")
    static let coolifyError = Color(hex: "DC2626")
    static let coolifyWarning = Color(hex: "FCD452")

    static let coolifyDarkBase = Color(hex: "101010")
    static let coolifyDark100 = Color(hex: "181818")
    static let coolifyDark200 = Color(hex: "202020")
    static let coolifyDark300 = Color(hex: "242424")
    static let coolifyDark400 = Color(hex: "282828")
    static let coolifyDark500 = Color(hex: "323232")

    static let coolifyAccent = coolifyPurple
    static let coolifyServer = Color(hex: "3B82F6")
    static let coolifyApplication = coolifySuccess
    static let coolifyDatabase = Color(hex: "F97316")
    static let coolifyService = coolifyPurple
    static let coolifyDeployment = Color(hex: "06B6D4")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension MeshGradient {
    static func coolifyHeader() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifyPurple.opacity(0.15), .coolifyPurpleLight.opacity(0.1), .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.2), .coolifyPurpleLight.opacity(0.1), .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.15)]
        )
    }

    static func coolifyServer() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifyServer.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyServer.opacity(0.15), .coolifyPurple.opacity(0.08), .coolifyServer.opacity(0.2), .coolifyPurple.opacity(0.08), .coolifyServer.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyServer.opacity(0.15)]
        )
    }

    static func coolifyApplication() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifySuccess.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifySuccess.opacity(0.15), .coolifyPurple.opacity(0.08), .coolifySuccess.opacity(0.2), .coolifyPurple.opacity(0.08), .coolifySuccess.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifySuccess.opacity(0.15)]
        )
    }

    static func coolifyDatabase() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifyDatabase.opacity(0.15), .coolifyWarning.opacity(0.1), .coolifyDatabase.opacity(0.15), .coolifyWarning.opacity(0.08), .coolifyDatabase.opacity(0.2), .coolifyWarning.opacity(0.08), .coolifyDatabase.opacity(0.15), .coolifyWarning.opacity(0.1), .coolifyDatabase.opacity(0.15)]
        )
    }

    static func coolifyService() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.08), .coolifyPurple.opacity(0.2), .coolifyPurpleDark.opacity(0.08), .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.15)]
        )
    }

    static func coolifyDeployment() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifyDeployment.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyDeployment.opacity(0.15), .coolifyPurple.opacity(0.08), .coolifyDeployment.opacity(0.2), .coolifyPurple.opacity(0.08), .coolifyDeployment.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyDeployment.opacity(0.15)]
        )
    }

    static func coolifyOnboarding() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.coolifyPurple.opacity(0.4), .coolifyPurpleLight.opacity(0.3), .coolifyPurple.opacity(0.4), .coolifyPurpleDark.opacity(0.3), .coolifyPurple.opacity(0.5), .coolifyPurpleLight.opacity(0.3), .coolifyPurple.opacity(0.4), .coolifyPurpleDark.opacity(0.3), .coolifyPurple.opacity(0.4)]
        )
    }
}

extension LinearGradient {
    static var coolifyButton: LinearGradient {
        LinearGradient(colors: [.coolifyPurple, .coolifyPurpleDark], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var coolifyAccent: LinearGradient {
        LinearGradient(colors: [.coolifyPurpleLight, .coolifyPurple], startPoint: .top, endPoint: .bottom)
    }
}

extension ShapeStyle where Self == Color {
    static var coolifyPurple: Color { Color.coolifyPurple }
    static var coolifyPurpleLight: Color { Color.coolifyPurpleLight }
    static var coolifyPurpleDark: Color { Color.coolifyPurpleDark }
    static var coolifyPurpleMuted: Color { Color.coolifyPurpleMuted }
    static var coolifyPurpleBackground: Color { Color.coolifyPurpleBackground }
    static var coolifySuccess: Color { Color.coolifySuccess }
    static var coolifyError: Color { Color.coolifyError }
    static var coolifyWarning: Color { Color.coolifyWarning }
    static var coolifyDarkBase: Color { Color.coolifyDarkBase }
    static var coolifyDark100: Color { Color.coolifyDark100 }
    static var coolifyDark200: Color { Color.coolifyDark200 }
    static var coolifyDark300: Color { Color.coolifyDark300 }
    static var coolifyDark400: Color { Color.coolifyDark400 }
    static var coolifyDark500: Color { Color.coolifyDark500 }
    static var coolifyAccent: Color { Color.coolifyAccent }
    static var coolifyServer: Color { Color.coolifyServer }
    static var coolifyApplication: Color { Color.coolifyApplication }
    static var coolifyDatabase: Color { Color.coolifyDatabase }
    static var coolifyService: Color { Color.coolifyService }
    static var coolifyDeployment: Color { Color.coolifyDeployment }
}
