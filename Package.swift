// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Dimmer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Dimmer",
            path: "Sources/Dimmer"
        )
    ]
)
