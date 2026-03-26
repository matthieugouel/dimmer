import AppKit

final class OverlayManager {
    private(set) var currentOpacity: Double
    private(set) var isDimming: Bool = false

    init() {
        let saved = UserDefaults.standard.double(forKey: Constants.userDefaultsOpacityKey)
        currentOpacity = saved > 0 ? saved : Constants.defaultOpacity
    }

    func setOpacity(_ opacity: Double) {
        currentOpacity = opacity
        UserDefaults.standard.set(opacity, forKey: Constants.userDefaultsOpacityKey)
        applyGamma()
    }

    func toggle() {
        if isDimming {
            clear()
        } else {
            engage()
        }
    }

    func engage() {
        isDimming = true
        applyGamma()
    }

    func clear() {
        isDimming = false
        CGDisplayRestoreColorSyncSettings()
    }

    private func applyGamma() {
        isDimming = true
        let brightness = CGGammaValue(1.0 - currentOpacity)

        for screen in NSScreen.screens {
            let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
            CGSetDisplayTransferByFormula(
                displayID,
                0, brightness, 1.0,  // red: min, max, gamma
                0, brightness, 1.0,  // green
                0, brightness, 1.0   // blue
            )
        }
    }
}
