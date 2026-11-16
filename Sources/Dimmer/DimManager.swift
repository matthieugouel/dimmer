import AppKit

/// Dims the screen by scaling down the display gamma transfer function.
///
/// The gamma override is owned by WindowServer and shares the display pipeline
/// with `corebrightnessd`. To stay out of its way, the override is released
/// before the display or the system goes to sleep and re-applied only after
/// wake has settled, so it never exists across a sleep/wake transition.
final class DimManager {
    private(set) var currentOpacity: Double
    private(set) var isDimming: Bool = false

    /// True between a sleep notification and the matching wake. Gamma is never
    /// applied while this is set.
    private var isSuspended = false
    private var pendingReapply: DispatchWorkItem?

    /// Delay before re-applying after wake, letting the system finish its own
    /// display and brightness work first.
    private static let wakeSettleDelay: TimeInterval = 2.0

    init() {
        let saved = UserDefaults.standard.double(forKey: Constants.userDefaultsOpacityKey)
        currentOpacity = saved > 0 ? saved : Constants.defaultOpacity

        // Start from the system's own colour settings, whatever a previous run left.
        CGDisplayRestoreColorSyncSettings()

        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(self, selector: #selector(willSleep),
                              name: NSWorkspace.willSleepNotification, object: nil)
        workspace.addObserver(self, selector: #selector(willSleep),
                              name: NSWorkspace.screensDidSleepNotification, object: nil)
        workspace.addObserver(self, selector: #selector(didWake),
                              name: NSWorkspace.didWakeNotification, object: nil)
        workspace.addObserver(self, selector: #selector(didWake),
                              name: NSWorkspace.screensDidWakeNotification, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }

    func setOpacity(_ opacity: Double) {
        currentOpacity = opacity
        UserDefaults.standard.set(opacity, forKey: Constants.userDefaultsOpacityKey)
        engage()
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
        pendingReapply?.cancel()
        CGDisplayRestoreColorSyncSettings()
    }

    // MARK: - Sleep / wake

    @objc private func willSleep() {
        isSuspended = true
        pendingReapply?.cancel()
        // Release unconditionally: cheap, and covers any override left behind.
        CGDisplayRestoreColorSyncSettings()
    }

    @objc private func didWake() {
        isSuspended = false
        scheduleReapply()
    }

    /// Displays can be added, removed or reconfigured while dimming.
    @objc private func screenParametersChanged() {
        scheduleReapply()
    }

    // MARK: - Private

    private func scheduleReapply() {
        pendingReapply?.cancel()
        guard isDimming else { return }
        let work = DispatchWorkItem { [weak self] in self?.applyGamma() }
        pendingReapply = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.wakeSettleDelay, execute: work)
    }

    private func applyGamma() {
        guard isDimming, !isSuspended else { return }
        let brightness = CGGammaValue(1.0 - currentOpacity)

        for screen in NSScreen.screens {
            guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                continue
            }
            let displayID = CGDirectDisplayID(number.uint32Value)
            // Skip displays that are asleep or mirrored-off; touching them mid-transition is what we avoid.
            guard CGDisplayIsAsleep(displayID) == 0 else { continue }
            CGSetDisplayTransferByFormula(
                displayID,
                0, brightness, 1.0,  // red: min, max, gamma
                0, brightness, 1.0,  // green
                0, brightness, 1.0   // blue
            )
        }
    }
}
