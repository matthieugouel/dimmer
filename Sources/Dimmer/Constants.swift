enum Constants {
    static let appName = "Dimmer"

    static let opacityPresets: [(label: String, value: Double)] = [
        ("10%", 0.10),
        ("20%", 0.20),
        ("50%", 0.50),
        ("75%", 0.75),
    ]

    static let defaultOpacity: Double = 0.20

    static let userDefaultsOpacityKey = "lastOpacity"
}
