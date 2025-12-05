import Cocoa
import CoreGraphics

class ClickGenerator {
    static let shared = ClickGenerator()
    
    private init() {}
    
    private func getCurrentMouseLocation() -> CGPoint {
        return NSEvent.mouseLocation
    }
    
    private func convertToScreenCoordinates(_ point: NSPoint) -> CGPoint {
        guard let mainScreen = NSScreen.main else {
            return CGPoint(x: point.x, y: point.y)
        }
        let screenHeight = mainScreen.frame.height
        return CGPoint(x: point.x, y: screenHeight - point.y)
    }
    
    func performLeftClick() {
        let location = convertToScreenCoordinates(getCurrentMouseLocation())
        
        guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left),
              let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: location, mouseButton: .left) else {
            return
        }
        
        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)
    }
    
    func performRightClick() {
        let location = convertToScreenCoordinates(getCurrentMouseLocation())
        
        guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: location, mouseButton: .right),
              let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: location, mouseButton: .right) else {
            return
        }
        
        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)
    }
    
    func performMiddleClick() {
        let location = convertToScreenCoordinates(getCurrentMouseLocation())
        
        guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: location, mouseButton: .center),
              let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .otherMouseUp, mouseCursorPosition: location, mouseButton: .center) else {
            return
        }
        
        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)
    }
    
    func performDoubleClick() {
        let location = convertToScreenCoordinates(getCurrentMouseLocation())
        
        guard let mouseDown1 = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left),
              let mouseUp1 = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: location, mouseButton: .left),
              let mouseDown2 = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left),
              let mouseUp2 = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: location, mouseButton: .left) else {
            return
        }
        
        mouseDown1.setIntegerValueField(.mouseEventClickState, value: 1)
        mouseUp1.setIntegerValueField(.mouseEventClickState, value: 1)
        mouseDown2.setIntegerValueField(.mouseEventClickState, value: 2)
        mouseUp2.setIntegerValueField(.mouseEventClickState, value: 2)
        
        mouseDown1.post(tap: .cghidEventTap)
        mouseUp1.post(tap: .cghidEventTap)
        mouseDown2.post(tap: .cghidEventTap)
        mouseUp2.post(tap: .cghidEventTap)
    }
}
