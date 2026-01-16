import SwiftUI

/// Coolify brand colors matching the official dashboard theme
extension Color {
    // MARK: - Primary Brand Colors

    /// Main Coollabs purple brand color: #6b16ed
    static let coolifyPurple = Color(hex: "6B16ED")

    /// Lighter purple variant: #7317ff
    static let coolifyPurpleLight = Color(hex: "7317FF")

    /// Darker purple variant: #5a12c7
    static let coolifyPurpleDark = Color(hex: "5A12C7")

    /// Muted purple for subtle accents: #4a0fa3
    static let coolifyPurpleMuted = Color(hex: "4A0FA3")

    /// Light purple background tint: #f5f0ff
    static let coolifyPurpleBackground = Color(hex: "F5F0FF")

    // MARK: - Status Colors

    /// Success/Running state: #22C55E
    static let coolifySuccess = Color(hex: "22C55E")

    /// Error/Stopped state: #dc2626
    static let coolifyError = Color(hex: "DC2626")

    /// Warning/Pending state: #fcd452
    static let coolifyWarning = Color(hex: "FCD452")

    // MARK: - Dark Theme Background Colors

    /// Base dark background: #101010
    static let coolifyDarkBase = Color(hex: "101010")

    /// Dark gray 100: #181818
    static let coolifyDark100 = Color(hex: "181818")

    /// Dark gray 200: #202020
    static let coolifyDark200 = Color(hex: "202020")

    /// Dark gray 300: #242424
    static let coolifyDark300 = Color(hex: "242424")

    /// Dark gray 400: #282828
    static let coolifyDark400 = Color(hex: "282828")

    /// Dark gray 500: #323232
    static let coolifyDark500 = Color(hex: "323232")

    // MARK: - Semantic Colors

    /// Primary accent color (purple)
    static let coolifyAccent = coolifyPurple

    /// Server-related color
    static let coolifyServer = Color(hex: "3B82F6") // Blue

    /// Application-related color
    static let coolifyApplication = coolifySuccess

    /// Database-related color
    static let coolifyDatabase = Color(hex: "F97316") // Orange

    /// Service-related color
    static let coolifyService = coolifyPurple

    /// Deployment-related color
    static let coolifyDeployment = Color(hex: "06B6D4") // Cyan
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Presets

extension MeshGradient {
    /// Coolify purple mesh gradient for headers
    static func coolifyHeader() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifyPurple.opacity(0.15), .coolifyPurpleLight.opacity(0.1), .coolifyPurple.opacity(0.15),
                .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.2), .coolifyPurpleLight.opacity(0.1),
                .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.15)
            ]
        )
    }

    /// Server-themed mesh gradient
    static func coolifyServer() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifyServer.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyServer.opacity(0.15),
                .coolifyPurple.opacity(0.08), .coolifyServer.opacity(0.2), .coolifyPurple.opacity(0.08),
                .coolifyServer.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyServer.opacity(0.15)
            ]
        )
    }

    /// Application-themed mesh gradient
    static func coolifyApplication() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifySuccess.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifySuccess.opacity(0.15),
                .coolifyPurple.opacity(0.08), .coolifySuccess.opacity(0.2), .coolifyPurple.opacity(0.08),
                .coolifySuccess.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifySuccess.opacity(0.15)
            ]
        )
    }

    /// Database-themed mesh gradient
    static func coolifyDatabase() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifyDatabase.opacity(0.15), .coolifyWarning.opacity(0.1), .coolifyDatabase.opacity(0.15),
                .coolifyWarning.opacity(0.08), .coolifyDatabase.opacity(0.2), .coolifyWarning.opacity(0.08),
                .coolifyDatabase.opacity(0.15), .coolifyWarning.opacity(0.1), .coolifyDatabase.opacity(0.15)
            ]
        )
    }

    /// Service-themed mesh gradient
    static func coolifyService() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.15),
                .coolifyPurpleDark.opacity(0.08), .coolifyPurple.opacity(0.2), .coolifyPurpleDark.opacity(0.08),
                .coolifyPurple.opacity(0.15), .coolifyPurpleDark.opacity(0.1), .coolifyPurple.opacity(0.15)
            ]
        )
    }

    /// Deployment-themed mesh gradient
    static func coolifyDeployment() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifyDeployment.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyDeployment.opacity(0.15),
                .coolifyPurple.opacity(0.08), .coolifyDeployment.opacity(0.2), .coolifyPurple.opacity(0.08),
                .coolifyDeployment.opacity(0.15), .coolifyPurple.opacity(0.1), .coolifyDeployment.opacity(0.15)
            ]
        )
    }

    /// Onboarding hero mesh gradient
    static func coolifyOnboarding() -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .coolifyPurple.opacity(0.4), .coolifyPurpleLight.opacity(0.3), .coolifyPurple.opacity(0.4),
                .coolifyPurpleDark.opacity(0.3), .coolifyPurple.opacity(0.5), .coolifyPurpleLight.opacity(0.3),
                .coolifyPurple.opacity(0.4), .coolifyPurpleDark.opacity(0.3), .coolifyPurple.opacity(0.4)
            ]
        )
    }
}

// MARK: - Linear Gradient Presets

extension LinearGradient {
    /// Coolify purple button gradient
    static var coolifyButton: LinearGradient {
        LinearGradient(
            colors: [.coolifyPurple, .coolifyPurpleDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Coolify accent gradient
    static var coolifyAccent: LinearGradient {
        LinearGradient(
            colors: [.coolifyPurpleLight, .coolifyPurple],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
