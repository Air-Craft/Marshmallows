/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 04/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file MUIPushButton.h
 
 
#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - Enums
/////////////////////////////////////////////////////////////////////

/// Events for custom target-action paradigm
typedef enum {
    kMUIPushButtonEventPressed = 1 << 0,     ///< Touch up inside of button unless doEventsOnTouchDown
    kMUIPushButtonEventToggled = 1 << 1,     ///< Sent when pressed if autoToggle is on.  Not sent when "on" is manually set
    kMUIPushButtonEventToggledOn = 1 << 2,   ///< Just for toggled on
    kMUIPushButtonEventToggledOff = 1 << 3,  ///< Just for toggled off
} MUIPushButtonEvent;


/////////////////////////////////////////////////////////////////////
#pragma mark - MUIPushButton
/////////////////////////////////////////////////////////////////////


/** \brief A specialised button designed for image based push buttons with optional on/off toggling (eg. for panel buttons which light up)
 
 \section muipbun Usage Notes
 Extends UIButton for Interface Builder compatibility however MUIPushButton uses it's own paradigm and sends it's own custom events.  It does, however, bridge between the Normal/Highlighted states and the UpOff/DownOff states so if set in IB they needn't be set again.
 
 \par
 The autoToggle property, when set to YES, sets the button to "on" when touched, updating the "on" property and button image.  It also enables the dispatch of the Toggled* events which are NOT dispatched when autoToggle is off.  They also are not sent when "on" is manually set.  You can have a toggle button which you manually control by setting autoToggle to NO and then set the "on" property manually. To use in non-toggle mode (eg for a simple push button), simply set autoToggle to NO and don't set the UpOn and DownOn stateImage* props.
 */
@interface MUIPushButton : UIButton


/** Buttons default to activating "on" states and sending event message when
 the touch up occurs.  Set this to YES for have Touch Down trigger the events
 */
@property (nonatomic) BOOL doEventsOnTouchDown;

/** Allows toggle events and auto state updating.  See the detailed class docs. */
@property (nonatomic) BOOL autoToggle;

/// @name State Images
@property (nonatomic, strong) UIImage *stateImageUpOff;
@property (nonatomic, strong) UIImage *stateImageDownOff;
@property (nonatomic, strong) UIImage *stateImageUpOn;
@property (nonatomic, strong) UIImage *stateImageDownOn;
/// @}

/// Read or set the button state
@property (nonatomic) BOOL on;

/** Add a listener for our custom MUIPushButtonEvent 
 Can have 0 or 1 parameter (ie MUIPushButton *sender)
 */
- (void)addTarget:(id)target action:(SEL)action forPushButtonEvents:(MUIPushButtonEvent)eventMask;

@end


/// @}