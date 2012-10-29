/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 04/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "MUIPushButton.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - MUIPushButtonTargetAction
/////////////////////////////////////////////////////////////////////
/**
 Private class for handled cusotm target-action events
 */
@interface MUIPushButtonTargetAction : NSObject
{
@public
    __weak id target;
    SEL action;
    int eventMask;
}
@end
@implementation MUIPushButtonTargetAction @end

/////////////////////////////////////////////////////////////////////
#pragma mark - MUIPushButton()
/////////////////////////////////////////////////////////////////////

@interface MUIPushButton()
{
    NSMutableArray *targetActions;
}
- (void)commonInit;
- (void)setupTouchHandling;
- (void)handleButtonPress;
- (void)sendActionsForPushButtonEvents:(MUIPushButtonEvent)eventsBitmask;
@end

/////////////////////////////////////////////////////////////////////
#pragma mark - MUIPushButton
/////////////////////////////////////////////////////////////////////

@implementation MUIPushButton

@synthesize stateImageUpOff, stateImageDownOff, stateImageUpOn, stateImageDownOn;
@synthesize doEventsOnTouchDown, autoToggle;
@synthesize on;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    targetActions = [NSMutableArray array];
    
    // Initialise off states from UIButton if available
    // (first condition is left in case we create a new designated init later on)
    if (!stateImageUpOff && [self imageForState:UIControlStateNormal])
        stateImageUpOff = [self imageForState:UIControlStateNormal];
    
    if (!stateImageDownOff && [self imageForState:UIControlStateHighlighted])
        stateImageDownOff = [self imageForState:UIControlStateHighlighted];
    
    [self setupTouchHandling];
}

/////////////////////////////////////////////////////////////////////
#pragma mark - Accessors
/////////////////////////////////////////////////////////////////////

/** Reinit the touch handling to reflect any changes */
- (void)setDoEventsOnTouchDown:(BOOL)aBool
{
    if (doEventsOnTouchDown == aBool) return;
    doEventsOnTouchDown = aBool;
    [self setupTouchHandling];
}

/** \name Button State Images' Accessors
 Set the corresponding UIButton state images based on whether the toggle is on or off
 */

/// Set the UpOff state from the UIButton's Normal if not set.  This prevents the need from setting again if set in Interface Builder
- (UIImage *)stateImageUpOff
{
    // Initialise of states from UIButton images in case they were set after init
    if (!stateImageUpOff && [self imageForState:UIControlStateNormal])
        stateImageUpOff = [self imageForState:UIControlStateNormal];
    
    return stateImageUpOff;
}

/// Set the DownOff state from the UIButton's Highlighted if not set.  This prevents the need from setting again if set in Interface Builder
- (UIImage *)stateImageDownOff
{
    if (!stateImageDownOff && [self imageForState:UIControlStateHighlighted])
        stateImageDownOff = [self imageForState:UIControlStateHighlighted];

    return stateImageDownOff;
}

- (void)setStateImageUpOff:(UIImage *)image
{
    stateImageUpOff = image;
    if (!on) {
        [self setImage:image forState:UIControlStateNormal];
    }
}

- (void)setStateImageDownOff:(UIImage *)image
{
    stateImageDownOff = image;
    if (!on) {
        [self setImage:image forState:UIControlStateHighlighted];
    }
}

- (void)setStateImageUpOn:(UIImage *)image
{
    stateImageUpOn = image;
    if (on) {
        [self setImage:image forState:UIControlStateNormal];
    }
}

- (void)setStateImageDownOn:(UIImage *)image
{
    stateImageDownOn = image;
    if (on) {
        [self setImage:image forState:UIControlStateHighlighted];
    }
}
/// @}

/** Update the graphics and state ivar */
- (void)setOn:(BOOL)onState
{
    if (onState == on)  return;
    on = onState;
    
    [self setImage:(on ? stateImageUpOn : stateImageUpOff) forState:UIControlStateNormal];
    [self setImage:(on ? stateImageDownOn : stateImageDownOff) forState:UIControlStateHighlighted];
}

/////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////

- (void)addTarget:(id)target action:(SEL)action forPushButtonEvents:(MUIPushButtonEvent)eventMask
{
    MUIPushButtonTargetAction *ta = [[MUIPushButtonTargetAction alloc] init];
    ta->target = target;
    ta->action = action;
    ta->eventMask = eventMask;
    [targetActions addObject:ta];
}


/////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////

/** Assign the button press handler to the correct touch event based on the doEventsOnTouchDown property */
- (void)setupTouchHandling
{
    SEL handler = @selector(handleButtonPress);
    
    // Remove the handler for the curent event bitmask and add it for the new event mask
    [self removeTarget:self action:handler forControlEvents:(doEventsOnTouchDown ? UIControlEventTouchUpInside: UIControlEventTouchDown)];
    
    [self addTarget:self action:handler forControlEvents:(doEventsOnTouchDown ? UIControlEventTouchDown : UIControlEventTouchUpInside)];
}


/** Send the button events and handle auto toggle image swapping for on/off states.  Note UIButton handles the Up/Down states via the UIControlStateNormal and Highlighted states */
- (void)handleButtonPress
{
    // Send generic Press event
    [self sendActionsForPushButtonEvents:kMUIPushButtonEventPressed];
    
    // Handle toggling events and buttons states
    if (autoToggle) {
        on = !on;
        if (!on) {  // ie, was on, now off
            [self sendActionsForPushButtonEvents:kMUIPushButtonEventToggled | kMUIPushButtonEventToggledOff];
            // Swap the images in the UIButton
            [self setImage:stateImageUpOff forState:UIControlStateNormal];
            [self setImage:stateImageDownOff forState:UIControlStateHighlighted];
        } else {
            [self sendActionsForPushButtonEvents:kMUIPushButtonEventToggled | kMUIPushButtonEventToggledOn];
            // Swap the images in the UIButton
            [self setImage:stateImageUpOn forState:UIControlStateNormal];
            [self setImage:stateImageDownOn forState:UIControlStateHighlighted];
        }
    }
}


/** Dispatch our custom target-action events */
- (void)sendActionsForPushButtonEvents:(MUIPushButtonEvent)eventsBitmask;
{
    for (MUIPushButtonTargetAction *targetAction in targetActions) {
        if (targetAction->eventMask & eventsBitmask) {
            // Check whether the signature takes an argument
            NSMethodSignature *sig = [targetAction->target methodSignatureForSelector:targetAction->action];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            // 2 = 0 (2 arguments are hidden)
            if ([sig numberOfArguments] > 3) {
                [NSException raise:NSDestinationInvalidException format:@"Target's action method must take 0 or 1 parameter"];
            }
            // No sender
            else if ([sig numberOfArguments] == 2) {
                [targetAction->target performSelector:targetAction->action withObject:self];
            } else {
                // With sender
                [targetAction->target performSelector:targetAction->action];
            }
#pragma clang diagnostic pop
        }
    }
}

@end

/// @}