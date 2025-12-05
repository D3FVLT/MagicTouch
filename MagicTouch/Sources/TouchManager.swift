import Foundation
import Cocoa
import QuartzCore

enum SwiftTouchState: Int32 {
    case notTracking = 0
    case startInRange = 1
    case hoverInRange = 2
    case makeTouch = 3
    case touching = 4
    case breakTouch = 5
    case lingerInRange = 6
    case outOfRange = 7
}

struct TouchInfo {
    let identifier: Int32
    let state: SwiftTouchState
    let normalizedX: Float
    let normalizedY: Float
    let velocityX: Float
    let velocityY: Float
    let timestamp: Double
}

enum TouchPosition {
    case left
    case right
}

private var globalTouchCallback: ((MTDeviceRef?, [TouchInfo]) -> Void)?

private func mtContactCallback(device: MTDeviceRef?, touches: UnsafeMutablePointer<MTTouch>?, numTouches: Int32, timestamp: Double, frame: Int32) {
    var touchInfos: [TouchInfo] = []
    
    if let touches = touches {
    for i in 0..<Int(numTouches) {
        let touch = touches[i]
        let info = TouchInfo(
            identifier: touch.identifier,
            state: SwiftTouchState(rawValue: touch.state) ?? .notTracking,
            normalizedX: touch.normalizedX,
            normalizedY: touch.normalizedY,
            velocityX: touch.velocityX,
            velocityY: touch.velocityY,
            timestamp: timestamp
        )
        touchInfos.append(info)
        }
    }
    
    globalTouchCallback?(device, touchInfos)
}

private struct TouchStart {
    let x: Float
    let y: Float
    let time: Double
    var maxMovementX: Float = 0
    var maxMovementY: Float = 0
    var lastUpdateTime: Double
    
    init(x: Float, y: Float, time: Double) {
        self.x = x
        self.y = y
        self.time = time
        self.lastUpdateTime = time
    }
}

class TouchManager {
    static let shared = TouchManager()
    
    private var devices: [MTDeviceRef] = []
    private var isRunning = false
    private var activeTouches: [Int32: TouchInfo] = [:]
    private var touchStarts: [Int32: TouchStart] = [:]
    private var lastFrameTime: Double = 0
    
    private var lastTapTime: Double = 0
    private var lastTapX: Float = 0
    private var lastTapPosition: TouchPosition?
    
    private let settings = Settings.shared
    private let clickGenerator = ClickGenerator.shared
    
    private let touchQueue = DispatchQueue(label: "com.magictouch.touchmanager", qos: .userInteractive)
    
    private let tapMaxDuration: Double = 0.25
    private let tapMaxMovement: Float = 0.05
    private let tapMaxVelocity: Float = 1.0
    private let touchTimeout: Double = 0.5
    private let doubleTapMaxInterval: Double = 0.4
    private let doubleTapMaxDistance: Float = 0.15
    
    private init() {
        globalTouchCallback = { [weak self] device, touches in
            self?.touchQueue.async {
                self?.handleTouches(touches)
            }
        }
    }
    
    func start() {
        guard !isRunning else { return }
        
        guard let handle = dlopen("/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport", RTLD_NOW) else {
            return
        }
        
        typealias MTDeviceCreateListFunc = @convention(c) () -> CFArray?
        typealias MTRegisterCallbackFunc = @convention(c) (MTDeviceRef, MTContactCallbackFunction) -> Void
        typealias MTDeviceStartFunc = @convention(c) (MTDeviceRef, Int32) -> Void
        typealias MTDeviceIsBuiltInFunc = @convention(c) (MTDeviceRef) -> Bool
        
        guard let createListPtr = dlsym(handle, "MTDeviceCreateList"),
              let registerCallbackPtr = dlsym(handle, "MTRegisterContactFrameCallback"),
              let deviceStartPtr = dlsym(handle, "MTDeviceStart") else {
            return
        }
        
        let createList = unsafeBitCast(createListPtr, to: MTDeviceCreateListFunc.self)
        let registerCallback = unsafeBitCast(registerCallbackPtr, to: MTRegisterCallbackFunc.self)
        let deviceStart = unsafeBitCast(deviceStartPtr, to: MTDeviceStartFunc.self)
        
        guard let deviceList = createList() else { return }
        
        let count = CFArrayGetCount(deviceList)
        
        for i in 0..<count {
            guard let devicePtr = CFArrayGetValueAtIndex(deviceList, i) else { continue }
            let device = unsafeBitCast(devicePtr, to: MTDeviceRef.self)
            
            if let isBuiltInPtr = dlsym(handle, "MTDeviceIsBuiltIn") {
                let isBuiltIn = unsafeBitCast(isBuiltInPtr, to: MTDeviceIsBuiltInFunc.self)
                if !isBuiltIn(device) || settings.includeBuiltInTrackpad {
                    registerCallback(device, mtContactCallback)
                    deviceStart(device, 0)
                    devices.append(device)
                }
            } else {
                registerCallback(device, mtContactCallback)
                deviceStart(device, 0)
                devices.append(device)
            }
        }
        
        isRunning = true
    }
    
    func stop() {
        guard isRunning else { return }
        
        guard let handle = dlopen("/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport", RTLD_NOW) else {
            return
        }
        
        typealias MTUnregisterCallbackFunc = @convention(c) (MTDeviceRef, MTContactCallbackFunction) -> Void
        typealias MTDeviceStopFunc = @convention(c) (MTDeviceRef) -> Void
        
        if let unregisterCallbackPtr = dlsym(handle, "MTUnregisterContactFrameCallback"),
           let deviceStopPtr = dlsym(handle, "MTDeviceStop") {
            let unregisterCallback = unsafeBitCast(unregisterCallbackPtr, to: MTUnregisterCallbackFunc.self)
            let deviceStop = unsafeBitCast(deviceStopPtr, to: MTDeviceStopFunc.self)
            
            for device in devices {
                unregisterCallback(device, mtContactCallback)
                deviceStop(device)
            }
        }
        
        devices.removeAll()
        isRunning = false
    }
    
    private func handleTouches(_ touches: [TouchInfo]) {
        let systemTime = CACurrentMediaTime()
        let currentTime = touches.first?.timestamp ?? lastFrameTime
        let cleanupTime = currentTime > 0 ? currentTime : systemTime
        
        let staleIds = touchStarts.filter { cleanupTime - $0.value.lastUpdateTime > touchTimeout }.map { $0.key }
        for id in staleIds {
            #if DEBUG
            debugLog("Removing stale touch: \(id)")
            #endif
            activeTouches.removeValue(forKey: id)
            touchStarts.removeValue(forKey: id)
        }
        
        for touch in touches {
            switch touch.state {
            case .makeTouch:
                activeTouches[touch.identifier] = touch
                touchStarts[touch.identifier] = TouchStart(
                    x: touch.normalizedX,
                    y: touch.normalizedY,
                    time: touch.timestamp
                )
                
            case .touching:
                activeTouches[touch.identifier] = touch
                if var start = touchStarts[touch.identifier] {
                    start.maxMovementX = max(start.maxMovementX, abs(touch.normalizedX - start.x))
                    start.maxMovementY = max(start.maxMovementY, abs(touch.normalizedY - start.y))
                    start.lastUpdateTime = touch.timestamp
                    touchStarts[touch.identifier] = start
                }
                
            case .breakTouch, .outOfRange, .lingerInRange, .notTracking:
                if let start = touchStarts[touch.identifier] {
                    let duration = touch.timestamp - start.time
                    let velocity = sqrt(touch.velocityX * touch.velocityX + touch.velocityY * touch.velocityY)
                    
                    let isTap = duration < tapMaxDuration &&
                                start.maxMovementX < tapMaxMovement &&
                                start.maxMovementY < tapMaxMovement &&
                                velocity < tapMaxVelocity
                    

                    if isTap && (touch.state == .breakTouch || touch.state == .outOfRange) {
                        let reallyActiveTouches = activeTouches.filter { entry in
                            entry.key != touch.identifier &&
                            entry.value.state == .touching
                        }
                        if reallyActiveTouches.isEmpty {
                            let position: TouchPosition = start.x < settings.leftZoneThreshold ? .left : .right
                            handleTap(at: position, x: start.x, timestamp: touch.timestamp)
                        }
                    }
                }
                
                activeTouches.removeValue(forKey: touch.identifier)
                touchStarts.removeValue(forKey: touch.identifier)
                
            case .startInRange, .hoverInRange:
                if touchStarts[touch.identifier] != nil {
                    activeTouches.removeValue(forKey: touch.identifier)
                    touchStarts.removeValue(forKey: touch.identifier)
                }
            }
        }
        
        if currentTime > 0 {
            lastFrameTime = currentTime
        }
    }
    
    private func handleTap(at position: TouchPosition, x: Float, timestamp: Double) {
        guard settings.isEnabled else { return }
        
        let timeSinceLastTap = timestamp - lastTapTime
        let distanceFromLastTap = abs(x - lastTapX)
        let isDoubleTap = timeSinceLastTap < doubleTapMaxInterval &&
                          distanceFromLastTap < doubleTapMaxDistance &&
                          lastTapPosition == position
        
        let action: TapAction
        switch position {
        case .left:
            action = settings.leftTapAction
        case .right:
            action = settings.rightTapAction
        }
        
        if isDoubleTap && action == .leftClick {
            executeAction(.doubleClick)
            lastTapTime = 0
            lastTapX = 0
            lastTapPosition = nil
        } else {
            executeAction(action)
            lastTapTime = timestamp
            lastTapX = x
            lastTapPosition = position
        }
    }
    
    func resetState() {
        touchQueue.async { [weak self] in
            self?.activeTouches.removeAll()
            self?.touchStarts.removeAll()
            self?.lastTapTime = 0
            self?.lastTapX = 0
            self?.lastTapPosition = nil
            #if DEBUG
            debugLog("TouchManager state reset")
            #endif
        }
    }
    
    var activeTouchCount: Int {
        var count = 0
        touchQueue.sync {
            count = activeTouches.count
        }
        return count
    }
    
    private func executeAction(_ action: TapAction) {
        DispatchQueue.main.async { [weak self] in
            switch action {
            case .none:
                break
            case .leftClick:
                self?.clickGenerator.performLeftClick()
            case .rightClick:
                self?.clickGenerator.performRightClick()
            case .middleClick:
                self?.clickGenerator.performMiddleClick()
            case .doubleClick:
                self?.clickGenerator.performDoubleClick()
            }
        }
    }
}
