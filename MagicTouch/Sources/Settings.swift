import Foundation
import Combine

enum TapAction: String, CaseIterable, Codable {
    case none = "None"
    case leftClick = "Left Click"
    case rightClick = "Right Click"
    case middleClick = "Middle Click"
    case doubleClick = "Double Click"
    
    var description: String { rawValue }
    
    static var selectableCases: [TapAction] {
        [.none, .leftClick, .rightClick, .middleClick]
    }
}

class Settings: ObservableObject {
    static let shared = Settings()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let isEnabled = "isEnabled"
        static let leftTapAction = "leftTapAction"
        static let centerTapAction = "centerTapAction"
        static let rightTapAction = "rightTapAction"
        static let leftZoneThreshold = "leftZoneThreshold"
        static let rightZoneThreshold = "rightZoneThreshold"
        static let launchAtLogin = "launchAtLogin"
        static let includeBuiltInTrackpad = "includeBuiltInTrackpad"
        static let tapSensitivity = "tapSensitivity"
    }
    
    @Published var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Keys.isEnabled) }
    }
    
    @Published var leftTapAction: TapAction {
        didSet { defaults.set(leftTapAction.rawValue, forKey: Keys.leftTapAction) }
    }
    
    @Published var centerTapAction: TapAction {
        didSet { defaults.set(centerTapAction.rawValue, forKey: Keys.centerTapAction) }
    }
    
    @Published var rightTapAction: TapAction {
        didSet { defaults.set(rightTapAction.rawValue, forKey: Keys.rightTapAction) }
    }
    
    @Published var leftZoneThreshold: Float {
        didSet { defaults.set(leftZoneThreshold, forKey: Keys.leftZoneThreshold) }
    }
    
    @Published var rightZoneThreshold: Float {
        didSet { defaults.set(rightZoneThreshold, forKey: Keys.rightZoneThreshold) }
    }
    
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin()
        }
    }
    
    @Published var includeBuiltInTrackpad: Bool {
        didSet { defaults.set(includeBuiltInTrackpad, forKey: Keys.includeBuiltInTrackpad) }
    }
    
    @Published var tapSensitivity: Double {
        didSet { defaults.set(tapSensitivity, forKey: Keys.tapSensitivity) }
    }
    
    private init() {
        defaults.register(defaults: [
            Keys.isEnabled: true,
            Keys.leftTapAction: TapAction.leftClick.rawValue,
            Keys.centerTapAction: TapAction.none.rawValue,
            Keys.rightTapAction: TapAction.rightClick.rawValue,
            Keys.leftZoneThreshold: 0.5,
            Keys.rightZoneThreshold: 0.5,
            Keys.launchAtLogin: false,
            Keys.includeBuiltInTrackpad: false,
            Keys.tapSensitivity: 0.3
        ])
        
        isEnabled = defaults.bool(forKey: Keys.isEnabled)
        leftTapAction = TapAction(rawValue: defaults.string(forKey: Keys.leftTapAction) ?? "") ?? .leftClick
        centerTapAction = TapAction(rawValue: defaults.string(forKey: Keys.centerTapAction) ?? "") ?? .none
        rightTapAction = TapAction(rawValue: defaults.string(forKey: Keys.rightTapAction) ?? "") ?? .rightClick
        leftZoneThreshold = defaults.float(forKey: Keys.leftZoneThreshold)
        rightZoneThreshold = defaults.float(forKey: Keys.rightZoneThreshold)
        launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        includeBuiltInTrackpad = defaults.bool(forKey: Keys.includeBuiltInTrackpad)
        tapSensitivity = defaults.double(forKey: Keys.tapSensitivity)
    }
    
    func resetToDefaults() {
        isEnabled = true
        leftTapAction = .leftClick
        centerTapAction = .none
        rightTapAction = .rightClick
        leftZoneThreshold = 0.5
        rightZoneThreshold = 0.5
        launchAtLogin = false
        includeBuiltInTrackpad = false
        tapSensitivity = 0.3
    }
    
    private func updateLaunchAtLogin() {
        #if swift(>=5.9)
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
        #endif
    }
}

#if swift(>=5.9)
import ServiceManagement
#endif
