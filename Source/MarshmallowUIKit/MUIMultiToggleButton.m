/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 04/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{
 */

#import "MUIMultiToggleButton.h"


/////////////////////////////////////////////////////////////////////
#pragma mark - MUIMultiToggleButtonTargetAction
/////////////////////////////////////////////////////////////////////
/**
 Private class for handled cusotm target-action events
 */
@interface MUIMultiToggleButtonTargetAction : NSObject
{
@public
    __weak id target;
    SEL action;
}
@end
@implementation MUIMultiToggleButtonTargetAction @end


/////////////////////////////////////////////////////////////////////
#pragma mark - MUIMultiToggleButton()
/////////////////////////////////////////////////////////////////////

@interface MUIMultiToggleButton()
{
    NSMutableArray *targetActions;
    NSMutableArray *toggleImages;
}
- (void)commonInit;
- (void)setupTouchHandling;
- (void)handleButtonPress;
- (void)sendActionsForToggleEvent;
@end


/////////////////////////////////////////////////////////////////////
#pragma mark - MUIMultiToggleButton
/////////////////////////////////////////////////////////////////////

@implementation MUIMultiToggleButton

@synthesize doEventsOnTouchDown;
@synthesize toggleIdx;

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

/////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    targetActions = [NSMutableArray array];
    toggleImages = [NSMutableArray array];
    toggleIdx = -1;     // ie uninitialised until addToggleImage is called
    
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

- (void)setToggleIdx:(NSInteger)anIdx
{
    // Bound checking
    if (anIdx < 0 || anIdx >= toggleImages.count) {
        [NSException raise:NSRangeException format:@"Index out of bounds"];
    }
    toggleIdx = anIdx;
    
    // Set the normal and touchdown images to prevent auto highlighted state when doEventsOnTouchDown is enabled
    [self setImage:[toggleImages objectAtIndex:toggleIdx] forState:UIControlStateNormal];
    [self setImage:[toggleImages objectAtIndex:toggleIdx] forState:UIControlStateHighlighted];}


/////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////

- (void)addToggleWithImage:(UIImage *)image
{
    // Interface with UIButton:
    // If this is the first added toggle image and UIButton's Normal state is set (eg via IB), add it as the first entry prior
    // to the passed argument.
    // If Normal is NOT set, initialise it with this first entry.
    UIImage *normalImg = [self imageForState:UIControlStateNormal];
    if (normalImg) {
        if (toggleImages.count == 0) {
            [toggleImages addObject:normalImg];
            toggleIdx = 0;
        }
    } else {
        [self setImage:image forState:UIControlStateNormal];
    }
    
    // Set the image and initialise the toggleIdx if this is the first addition
    [toggleImages addObject:image];
    if (toggleImages.count == 1)
        toggleIdx = 0;
}

/////////////////////////////////////////////////////////////////////////

- (void)addToggleEventTarget:(id)target action:(SEL)action
{
    MUIMultiToggleButtonTargetAction *ta = [[MUIMultiToggleButtonTargetAction alloc] init];
    ta->target = target;
    ta->action = action;
    [targetActions addObject:ta];
}

/////////////////////////////////////////////////////////////////////////

- (void)toggleBack
{
    // Update the idx via accessors to have the image updated as well
    if (toggleIdx == 0)
        self.toggleIdx = toggleImages.count-1;
    else
        self.toggleIdx--;
}

/////////////////////////////////////////////////////////////////////////

- (void)toggleForward
{
    // Update the idx via accessors to have the image updated as well
    if (toggleIdx == toggleImages.count-1)
        self.toggleIdx = 0;
    else
        self.toggleIdx++;
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

- (void)handleButtonPress
{
    [self toggleForward];
    [self sendActionsForToggleEvent];
}

- (void)sendActionsForToggleEvent
{
    for (MUIMultiToggleButtonTargetAction *targetAction in targetActions) {
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
    }
#pragma clang diagnostic pop
}

@end

/// @}
