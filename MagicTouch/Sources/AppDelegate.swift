import Cocoa
import SwiftUI

func debugLog(_ message: String) {
    #if DEBUG
    let logFile = "/tmp/magictouch_debug.log"
    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    let logMessage = "[\(timestamp)] \(message)\n"
    
    if let handle = FileHandle(forWritingAtPath: logFile) {
        handle.seekToEndOfFile()
        handle.write(logMessage.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: logFile, contents: logMessage.data(using: .utf8), attributes: nil)
    }
    fputs(logMessage, stderr)
    #endif
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var touchManager: TouchManager?
    private var settingsWindow: NSWindow?
    
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        checkAccessibilityPermissions()
        
        touchManager = TouchManager.shared
        touchManager?.start()
        
        statusBarController = StatusBarController()
        statusBarController?.onSettingsClicked = { [weak self] in
            self?.showSettings()
        }
        statusBarController?.onQuitClicked = {
            NSApplication.shared.terminate(nil)
        }
        statusBarController?.onToggleEnabled = { [weak self] enabled in
            if enabled {
                self?.touchManager?.start()
            } else {
                self?.touchManager?.stop()
            }
        }
        
        NSApp.setActivationPolicy(.accessory)
        
        registerSleepWakeObservers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UpdateChecker.shared.checkForUpdates(silent: true)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        touchManager?.stop()
    }
    
    private func registerSleepWakeObservers() {
        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(
            self,
            selector: #selector(handleWillSleep(_:)),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(handleDidWake(_:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc private func handleWillSleep(_ notification: Notification) {
        debugLog("System will sleep — stopping touch tracking")
        touchManager?.stop()
    }
    
    @objc private func handleDidWake(_ notification: Notification) {
        debugLog("System did wake — restarting touch tracking")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            if Settings.shared.isEnabled {
                self.touchManager?.restart()
            }
        }
    }
    
    private func checkAccessibilityPermissions() {
        guard !AXIsProcessTrusted() else { return }
        
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "MagicTouch needs accessibility permissions to generate click events. Please enable it in System Settings → Privacy & Security → Accessibility."
            alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    private func showSettings() {
        if settingsWindow == nil {
            let hostingController = NSHostingController(rootView: SettingsView())
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "MagicTouch Settings"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable]
            settingsWindow?.setContentSize(NSSize(width: 500, height: 600))
            settingsWindow?.center()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
