import AppKit

final class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let overlayManager: OverlayManager
    private var opacityMenuItems: [NSMenuItem] = []

    init(overlayManager: OverlayManager) {
        self.overlayManager = overlayManager
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        configureButton()
        buildMenu()
    }

    func updateMenuState() {
        for item in opacityMenuItems {
            let opacity = Double(item.tag) / 100.0
            item.state = (overlayManager.isDimming && opacity == overlayManager.currentOpacity) ? .on : .off
        }
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        updateMenuState()
    }

    // MARK: - Private

    private func configureButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "sun.min", accessibilityDescription: Constants.appName)
    }

    private func buildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        let titleItem = NSMenuItem(title: Constants.appName, action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        for preset in Constants.opacityPresets {
            let item = NSMenuItem(title: preset.label, action: #selector(opacitySelected(_:)), keyEquivalent: "")
            item.target = self
            item.tag = Int(preset.value * 100)
            opacityMenuItems.append(item)
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let clearItem = NSMenuItem(title: "Clear", action: #selector(clearSelected), keyEquivalent: "")
        clearItem.target = self
        menu.addItem(clearItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func opacitySelected(_ sender: NSMenuItem) {
        let opacity = Double(sender.tag) / 100.0
        overlayManager.setOpacity(opacity)
    }

    @objc private func clearSelected() {
        overlayManager.clear()
    }
}
