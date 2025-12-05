// MultitouchSupport.h
// Bridging header for Apple's private MultitouchSupport.framework

#ifndef MultitouchSupport_h
#define MultitouchSupport_h

#import <Foundation/Foundation.h>

// Multitouch device reference
typedef struct __MTDevice *MTDeviceRef;

// Touch data structure
typedef struct {
    int32_t frame;           // Frame number
    double timestamp;        // Event timestamp
    int32_t identifier;      // Finger identifier
    int32_t state;           // Touch state (see MTTouchState)
    int32_t fingerID;        // Finger ID
    int32_t handID;          // Hand ID
    float normalizedX;       // Normalized X position (0.0 - 1.0)
    float normalizedY;       // Normalized Y position (0.0 - 1.0)
    float totalX;            // Total X position
    float totalY;            // Total Y position
    float velocityX;         // X velocity
    float velocityY;         // Y velocity
    float angle;             // Touch angle
    float majorAxis;         // Major ellipse axis
    float minorAxis;         // Minor ellipse axis
    float absoluteX;         // Absolute X position
    float absoluteY;         // Absolute Y position
    int32_t unknown1;
    int32_t unknown2;
    float density;           // Touch density/pressure
} MTTouch;

// Touch state values
typedef enum {
    MTTouchStateNotTracking = 0,
    MTTouchStateStartInRange = 1,
    MTTouchStateHoverInRange = 2,
    MTTouchStateMakeTouch = 3,
    MTTouchStateTouching = 4,
    MTTouchStateBreakTouch = 5,
    MTTouchStateLingerInRange = 6,
    MTTouchStateOutOfRange = 7
} MTTouchState;

// Callback type for touch events
typedef void (*MTContactCallbackFunction)(MTDeviceRef device, MTTouch *touches, int32_t numTouches, double timestamp, int32_t frame);

// Get list of all multitouch devices
CFArrayRef MTDeviceCreateList(void);

// Device lifecycle
void MTRegisterContactFrameCallback(MTDeviceRef device, MTContactCallbackFunction callback);
void MTUnregisterContactFrameCallback(MTDeviceRef device, MTContactCallbackFunction callback);
void MTDeviceStart(MTDeviceRef device, int32_t mode);
void MTDeviceStop(MTDeviceRef device);

// Device info
int32_t MTDeviceGetDeviceID(MTDeviceRef device);
OSStatus MTDeviceGetFamilyID(MTDeviceRef device, int32_t *familyID);
bool MTDeviceIsRunning(MTDeviceRef device);
bool MTDeviceIsBuiltIn(MTDeviceRef device);
bool MTDeviceIsOpaqueSurface(MTDeviceRef device);

#endif /* MultitouchSupport_h */

