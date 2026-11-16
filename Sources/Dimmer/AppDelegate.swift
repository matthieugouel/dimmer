import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var dimManager: DimManager!

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
        dimManager = DimManager()
        statusBarController = StatusBarController(dimManager: dimManager)
    }

    func applicationWillTerminate(_ notification: Notification) {
        dimManager.clear()
    }
}
