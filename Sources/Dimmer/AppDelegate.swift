import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var overlayManager: OverlayManager!

    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let delegate = AppDelegate()
        app.delegate = delegate

        withExtendedLifetime(delegate) {
            app.run()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayManager = OverlayManager()
        statusBarController = StatusBarController(overlayManager: overlayManager)
    }
}
