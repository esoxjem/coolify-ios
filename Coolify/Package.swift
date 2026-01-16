// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Coolify",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Coolify",
            targets: ["Coolify"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "21.0.0"),
    ],
    targets: [
        .target(
            name: "Coolify",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
            ],
            path: "Sources"
        ),
    ]
)
