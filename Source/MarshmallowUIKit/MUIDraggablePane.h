/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 10/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file MUIDraggablePaneView.h

#import <UIKit/UIKit.h>
#import "MUITypes.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - Enums
/////////////////////////////////////////////////////////////////////////

/** Open/closed state constants */
typedef enum {
    kMUIDraggablePaneViewStateOpen,
    kMUIDraggablePaneViewStateClosed,
} MUIDraggablePaneState;


/**
 \brief A two-state (open/closed) view with draggable handle.  Used for sliding covers, draggable menu bars, and to mimic things like the iphone's notification panel
 
 \todo Support for x-axis sliding panels
 */
@interface MUIDraggablePane : UIView

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

/// @name Configuration properties
@property (nonatomic, weak) IBOutlet UIView *dragHandle;
//@property (nonatomic) MUIAxis motionAxis;
@property (nonatomic) CGFloat positionWhenClosed;
@property (nonatomic) CGFloat positionWhenOpen;

/// Touch movement released within this distance (points) of endpoints will return to endpoint...
@property (nonatomic) CGFloat requiredDragThresholdWhenClosed;

/// Touch movement released within this distance (points) of endpoints will return to endpoint...
@property (nonatomic) CGFloat requiredDragThresholdWhenOpen;

/// Drags released after a movement of this velocity (points/sec) will animate to next state regardless of above thresholds
@property (nonatomic) CGFloat requiredVelocityToOverrideDragThreshold;

/// Velocity used on return animations when above thresholds aren't met
@property (nonatomic) CGFloat revertAnimationVelocity;

/// Min. velocity (points/sec) to use for animation (when touch velocity is less).
@property (nonatomic) CGFloat minimumAnimationVelocity;

/// Animation velocity for Public API open/close methods.
@property (nonatomic) CGFloat animationVelocityForManualStateChanges;
/// @}


/// @name Event callback blocks
@property (nonatomic, copy) BOOL(^paneDragStarted)();
@property (nonatomic, copy) void(^paneDragUpdated)(CGFloat fractionalPosition);
@property (nonatomic, copy) void(^paneDidFinishOpening)();
@property (nonatomic, copy) void(^paneDidFinishClosing)();
@property (nonatomic, copy) void(^paneWillFinishOpening)(NSTimeInterval aTime);
@property (nonatomic, copy) void(^paneWillFinishClosing)(NSTimeInterval aTime);
/// @}


/// @name Running State Properties

/** The fractional position of the pane.  0 = closed, 1 = open, in between means it's being dragged.  Note, setting the position manual disengages the automatic animations until the next touch & release.  Setting it to 0 or 1 updates currentState accordingly.  No event blocks are called however.
 */
@property (nonatomic) CGFloat currentFractionalPosition;

/** The last stable state of the pane. */
@property (nonatomic, readonly) MUIDraggablePaneState currentState;

/// Use to unlatch the touch detection such as when animations are occuring
@property (nonatomic, getter=ignoreTouch) BOOL ignoreTouch;

/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/// Common initialiser for use after initWithFrame or after IB creation
- (void)prepareWithDragHandle:(UIControl *)dragHandle /*motionAxis:(MUIAxis)aMotionAxis */positionWhenClosed:(CGFloat)aPositionWhenClosed positionWhenOpen:(CGFloat)aPositionWhenOpen initialState:(MUIDraggablePaneState)theState;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)openAnimated:(BOOL)animated;
- (void)closeAnimated:(BOOL)animated;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end
/// @}