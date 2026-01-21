import SwiftUI

extension Color {
    static let brandPurple = Color(hex: "6B16ED")
    static let brandPurpleLight = Color(hex: "7317FF")
    static let brandPurpleDark = Color(hex: "5A12C7")
    static let brandPurpleMuted = Color(hex: "4A0FA3")
    static let brandPurpleBackground = Color(hex: "F5F0FF")

    static let statusSuccess = Color(hex: "22C55E")
    static let statusError = Color(hex: "DC2626")
    static let statusWarning = Color(hex: "FCD452")

    static let darkBase = Color(hex: "101010")
    static let dark100 = Color(hex: "181818")
    static let dark200 = Color(hex: "202020")
    static let dark300 = Color(hex: "242424")
    static let dark400 = Color(hex: "282828")
    static let dark500 = Color(hex: "323232")

    static let accentColor = brandPurple
    static let serverColor = Color(hex: "3B82F6")
    static let applicationColor = statusSuccess
    static let databaseColor = Color(hex: "F97316")
    static let serviceColor = brandPurple
    static let deploymentColor = Color(hex: "06B6D4")
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
    static func headerGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.brandPurple.opacity(0.15), .brandPurpleLight.opacity(0.1), .brandPurple.opacity(0.15), .brandPurpleDark.opacity(0.1), .brandPurple.opacity(0.2), .brandPurpleLight.opacity(0.1), .brandPurple.opacity(0.15), .brandPurpleDark.opacity(0.1), .brandPurple.opacity(0.15)]
        )
    }

    static func serverGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.serverColor.opacity(0.15), .brandPurple.opacity(0.1), .serverColor.opacity(0.15), .brandPurple.opacity(0.08), .serverColor.opacity(0.2), .brandPurple.opacity(0.08), .serverColor.opacity(0.15), .brandPurple.opacity(0.1), .serverColor.opacity(0.15)]
        )
    }

    static func applicationGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.statusSuccess.opacity(0.15), .brandPurple.opacity(0.1), .statusSuccess.opacity(0.15), .brandPurple.opacity(0.08), .statusSuccess.opacity(0.2), .brandPurple.opacity(0.08), .statusSuccess.opacity(0.15), .brandPurple.opacity(0.1), .statusSuccess.opacity(0.15)]
        )
    }

    static func databaseGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.databaseColor.opacity(0.15), .statusWarning.opacity(0.1), .databaseColor.opacity(0.15), .statusWarning.opacity(0.08), .databaseColor.opacity(0.2), .statusWarning.opacity(0.08), .databaseColor.opacity(0.15), .statusWarning.opacity(0.1), .databaseColor.opacity(0.15)]
        )
    }

    static func serviceGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.brandPurple.opacity(0.15), .brandPurpleDark.opacity(0.1), .brandPurple.opacity(0.15), .brandPurpleDark.opacity(0.08), .brandPurple.opacity(0.2), .brandPurpleDark.opacity(0.08), .brandPurple.opacity(0.15), .brandPurpleDark.opacity(0.1), .brandPurple.opacity(0.15)]
        )
    }

    static func deploymentGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.deploymentColor.opacity(0.15), .brandPurple.opacity(0.1), .deploymentColor.opacity(0.15), .brandPurple.opacity(0.08), .deploymentColor.opacity(0.2), .brandPurple.opacity(0.08), .deploymentColor.opacity(0.15), .brandPurple.opacity(0.1), .deploymentColor.opacity(0.15)]
        )
    }

    static func onboardingGradient() -> MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
            colors: [.brandPurple.opacity(0.4), .brandPurpleLight.opacity(0.3), .brandPurple.opacity(0.4), .brandPurpleDark.opacity(0.3), .brandPurple.opacity(0.5), .brandPurpleLight.opacity(0.3), .brandPurple.opacity(0.4), .brandPurpleDark.opacity(0.3), .brandPurple.opacity(0.4)]
        )
    }
}

extension LinearGradient {
    static var buttonGradient: LinearGradient {
        LinearGradient(colors: [.brandPurple, .brandPurpleDark], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var accentGradient: LinearGradient {
        LinearGradient(colors: [.brandPurpleLight, .brandPurple], startPoint: .top, endPoint: .bottom)
    }
}

extension ShapeStyle where Self == Color {
    static var brandPurple: Color { Color.brandPurple }
    static var brandPurpleLight: Color { Color.brandPurpleLight }
    static var brandPurpleDark: Color { Color.brandPurpleDark }
    static var brandPurpleMuted: Color { Color.brandPurpleMuted }
    static var brandPurpleBackground: Color { Color.brandPurpleBackground }
    static var statusSuccess: Color { Color.statusSuccess }
    static var statusError: Color { Color.statusError }
    static var statusWarning: Color { Color.statusWarning }
    static var darkBase: Color { Color.darkBase }
    static var dark100: Color { Color.dark100 }
    static var dark200: Color { Color.dark200 }
    static var dark300: Color { Color.dark300 }
    static var dark400: Color { Color.dark400 }
    static var dark500: Color { Color.dark500 }
    static var accentColor: Color { Color.accentColor }
    static var serverColor: Color { Color.serverColor }
    static var applicationColor: Color { Color.applicationColor }
    static var databaseColor: Color { Color.databaseColor }
    static var serviceColor: Color { Color.serviceColor }
    static var deploymentColor: Color { Color.deploymentColor }
}

extension Font {
    static let monoLargeTitle = Font.system(.largeTitle, design: .monospaced)
    static let monoTitle = Font.system(.title, design: .monospaced)
    static let monoTitle2 = Font.system(.title2, design: .monospaced)
    static let monoTitle3 = Font.system(.title3, design: .monospaced)
    static let monoHeadline = Font.system(.headline, design: .monospaced)
    static let monoSubheadline = Font.system(.subheadline, design: .monospaced)
    static let monoBody = Font.system(.body, design: .monospaced)
    static let monoCallout = Font.system(.callout, design: .monospaced)
    static let monoFootnote = Font.system(.footnote, design: .monospaced)
    static let monoCaption = Font.system(.caption, design: .monospaced)
    static let monoCaption2 = Font.system(.caption2, design: .monospaced)
}
