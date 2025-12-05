import Cocoa
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem
    private var menu: NSMenu
    private var enabledMenuItem: NSMenuItem?
    private var leftConfigItem: NSMenuItem?
    private var rightConfigItem: NSMenuItem?
    
    var onSettingsClicked: (() -> Void)?
    var onQuitClicked: (() -> Void)?
    var onToggleEnabled: ((Bool) -> Void)?
    
    private let settings = Settings.shared
    private var updateWorkItem: DispatchWorkItem?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        
        setupStatusItem()
        setupMenu()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupStatusItem() {
        if let button = statusItem.button {
            button.toolTip = "MagicTouch"
            if let image = NSImage(systemSymbolName: "hand.tap.fill", accessibilityDescription: "MagicTouch") {
                image.isTemplate = true
                button.image = image
            }
        }
        statusItem.menu = menu
    }
    
    private func setupMenu() {
        let titleItem = NSMenuItem(title: "MagicTouch", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        enabledMenuItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled(_:)), keyEquivalent: "e")
        enabledMenuItem?.target = self
        enabledMenuItem?.state = settings.isEnabled ? .on : .off
        menu.addItem(enabledMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        let configHeader = NSMenuItem(title: "Current Configuration:", action: nil, keyEquivalent: "")
        configHeader.isEnabled = false
        menu.addItem(configHeader)
        
        leftConfigItem = NSMenuItem(title: "  Left tap: \(settings.leftTapAction.description)", action: nil, keyEquivalent: "")
        leftConfigItem?.isEnabled = false
        menu.addItem(leftConfigItem!)
        
        rightConfigItem = NSMenuItem(title: "  Right tap: \(settings.rightTapAction.description)", action: nil, keyEquivalent: "")
        rightConfigItem?.isEnabled = false
        menu.addItem(rightConfigItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings(_:)), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: "About MagicTouch", action: #selector(showAbout(_:)), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func toggleEnabled(_ sender: NSMenuItem) {
        settings.isEnabled.toggle()
        sender.state = settings.isEnabled ? .on : .off
        onToggleEnabled?(settings.isEnabled)
        updateIcon()
    }
    
    @objc private func openSettings(_ sender: NSMenuItem) {
        onSettingsClicked?()
    }
    
    @objc private func showAbout(_ sender: NSMenuItem) {
        let alert = NSAlert()
        alert.messageText = "MagicTouch"
        alert.informativeText = "Version 1.0.0\n\nTap-to-click for Magic Mouse.\n\n© 2024 MIT License"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quitApp(_ sender: NSMenuItem) {
        onQuitClicked?()
    }
    
    @objc private func settingsChanged() {
        updateWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateMenuItems()
        }
        updateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    private func updateMenuItems() {
        enabledMenuItem?.state = settings.isEnabled ? .on : .off
        leftConfigItem?.title = "  Left tap: \(settings.leftTapAction.description)"
        rightConfigItem?.title = "  Right tap: \(settings.rightTapAction.description)"
        updateIcon()
    }
    
    private func updateIcon() {
        guard let button = statusItem.button else { return }
        let iconName = settings.isEnabled ? "hand.tap.fill" : "hand.tap"
        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "MagicTouch") {
            image.isTemplate = true
            button.image = image
        }
    }
}
