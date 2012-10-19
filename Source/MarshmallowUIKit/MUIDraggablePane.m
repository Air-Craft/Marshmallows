/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 10/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import <tgmath.h>
#import "UIView+Marshmallows.h"
#import "MUIDraggablePane.h"
#import "MarshmallowDebug.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - MUIDraggablePaneView
/////////////////////////////////////////////////////////////////////////

@implementation MUIDraggablePane
{
    BOOL _hasTouchDown;
    CGFloat _slideVelocity;      ///< stores velocity on last touch update for use in release animation
    CGFloat _prevTimestamp;      ///< used for calculating velocity

}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (void)prepareWithDragHandle:(UIControl *)aDragHandle /*motionAxis:(MUIAxis)aMotionAxis */positionWhenClosed:(CGFloat)aPositionWhenClosed positionWhenOpen:(CGFloat)aPositionWhenOpen initialState:(MUIDraggablePaneState)theState
{
    _dragHandle = aDragHandle;
//    _motionAxis = aMotionAxis;
    _positionWhenClosed = aPositionWhenClosed;
    _positionWhenOpen = aPositionWhenOpen;
    
    // Set the defaults for other properties
    // These are designed to mimic roughly the iphones notifications panel
    CGFloat slideDist = fabs(aPositionWhenClosed - aPositionWhenOpen);
    _requiredDragThresholdWhenClosed = 0.05 * slideDist; // 5%
    _requiredDragThresholdWhenOpen = 0.01 * slideDist;   // 1%
    _requiredVelocityToOverrideDragThreshold = 100;
    _revertAnimationVelocity = 100;
    _minimumAnimationVelocity = 850;
    _animationVelocityForManualStateChanges = 1700;     // 2x the above
    
    // Set the initial state and update the view
    _currentState = theState;
    [self moveOriginToY: (_currentState == kMUIDraggablePaneViewStateClosed ? _positionWhenClosed : _positionWhenOpen)];
    
    // Setup the UIControl's listening methods
    [aDragHandle addTarget:self action:@selector(_paneDragged:withEvent:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragOutside];      // DragOutside shouldnt occur I don't think
    
    [aDragHandle addTarget:self action:@selector(_paneDragReleased:withEvent:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchDragExit];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Property Accessors
/////////////////////////////////////////////////////////////////////////

- (CGFloat)currentFractionalPosition
{
    CGFloat currPos = self.frame.origin.y;
    return (currPos - _positionWhenClosed) / (_positionWhenOpen - _positionWhenClosed);
}

/////////////////////////////////////////////////////////////////////////

- (void)setCurrentFractionalPosition:(CGFloat)aFractionalPosition
{
    // Move immediately to the requested position
    CGFloat newPos = aFractionalPosition * (_positionWhenOpen - _positionWhenClosed) + _positionWhenClosed;
    [self moveOriginToY:newPos];
    
    // Update the current state prop if moved to the endpoints
    if (aFractionalPosition == 1.0) {
        _currentState = kMUIDraggablePaneViewStateOpen;
    } else if (aFractionalPosition == 0.0) {
        _currentState = kMUIDraggablePaneViewStateClosed;
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)openAnimated:(BOOL)animated
{
    NSTimeInterval t = animated
        ? [self _animationTimeNeededForStateChangeTo:kMUIDraggablePaneViewStateOpen withVelocity:_animationVelocityForManualStateChanges]
        : 0;
    
    [self _animateToState:kMUIDraggablePaneViewStateOpen inTime:t];
}

/////////////////////////////////////////////////////////////////////////

- (void)closeAnimated:(BOOL)animated
{
    NSTimeInterval t = animated
    ? [self _animationTimeNeededForStateChangeTo:kMUIDraggablePaneViewStateClosed withVelocity:_animationVelocityForManualStateChanges]
    : 0;
    
    [self _animateToState:kMUIDraggablePaneViewStateClosed inTime:t];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - UIControl Handlers
/////////////////////////////////////////////////////////////////////////

- (void)_paneDragged:(id)sender withEvent:(UIEvent *)theEvent
{
    if (_ignoreTouch)
        return;
    
    // First touch?  Send delegate event and cancel if return NO
    if (!_hasTouchDown) {
        _hasTouchDown = YES;
        if (_paneDragStarted) {
            if (!_paneDragStarted()) {
                return;
            }
        }
    }
    
    //   DLOGi([self.handle allControlEvents]);
    UITouch *touch = (UITouch *)[[theEvent allTouches] anyObject];
    CGPoint point =  [touch locationInView:self.superview];
    CGPoint prevPoint = [touch previousLocationInView:self.superview];
    
    CGFloat deltaY = point.y - prevPoint.y;
    CGFloat newY = self.frame.origin.y + deltaY;
    
    // Store timestamp to calc velocity on release
    // Gthis must be done here
    _slideVelocity = deltaY / (theEvent.timestamp - _prevTimestamp);
    _prevTimestamp = theEvent.timestamp;
    
    // Check the bounds & update the position & notify the callback
    newY = (newY > _positionWhenOpen) ? _positionWhenOpen : (newY < _positionWhenClosed ? _positionWhenClosed : newY);
    self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
    if (_paneDragUpdated) {
        _paneDragUpdated(self.currentFractionalPosition);
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)_paneDragReleased:(id)sender withEvent:(UIEvent *)theEvent
{
    CGFloat newY;
    CGFloat slideVel;
    CGFloat speed = fabs(_slideVelocity);
    
    // Reset the flag
    _hasTouchDown = NO;
    
    // Return to endpoints if velocity and distance moved is too little
    if ( (self.frame.origin.y - _positionWhenClosed) < _requiredDragThresholdWhenClosed &&
        speed < _requiredVelocityToOverrideDragThreshold ) {
        
        newY = _positionWhenClosed;
        slideVel = _requiredVelocityToOverrideDragThreshold;
        
    } else if ( (_positionWhenOpen - self.frame.origin.y) < _requiredDragThresholdWhenOpen &&
               speed < _requiredVelocityToOverrideDragThreshold ) {
        
        newY = _positionWhenOpen;
        slideVel = _requiredVelocityToOverrideDragThreshold;
        
        // Otherwise, open or close?  Get the coord wrt center.
    } else {
        if (_slideVelocity < 0) {
            newY = _positionWhenClosed;
        } else {
            newY = _positionWhenOpen;
        }
        // Cap velocity minimum.  Sign doesn't matter
        slideVel = fabs(_slideVelocity) < _minimumAnimationVelocity ? _minimumAnimationVelocity : _slideVelocity;
    }
    
    // Calc animation time
    CFTimeInterval t = fabs( (self.frame.origin.y - newY) / (slideVel) );
    //DLOG("delY=%.0f, newY=%.0f, vel: %.1f=>%.1f, %.2f", deltaY, newY, _slideVelocity, slideVel, t);
    
    // Send delegate notification if closing
    if (newY == _positionWhenClosed) {
        if (_paneWillFinishClosing) {
            _paneWillFinishClosing(t);
        }
    } else {
        if (_paneWillFinishOpening) {
            _paneWillFinishOpening(t);
        }
    }
    
    MMLogInfo("%@ in %f", (newY == _positionWhenClosed ? @"Closing":@"Opening"), t);
    
    // Unlatch the touch
    _ignoreTouch = YES;
    [UIView animateWithDuration:t
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL didComplete){
                         if (self.frame.origin.y == _positionWhenOpen) {
                             _currentState = kMUIDraggablePaneViewStateOpen;
                             if (_paneDidFinishOpening) {
                                 _paneDidFinishOpening();
                             }
                         } else {
                             _currentState = kMUIDraggablePaneViewStateClosed;
                             if (_paneDidFinishClosing) {
                                 _paneDidFinishClosing();
                             }
                         }
                         
                         // Restore touch handling
                         _ignoreTouch = NO;
                         MMLogInfo(@"%@", _currentState == kMUIDraggablePaneViewStateOpen ? @"Open":@"Closed");
                     }];
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////

/// Use time = 0 to update now
- (void)_animateToState:(MUIDraggablePaneState)aState inTime:(NSTimeInterval)aTime
{
    // Check it's not already in that state
    if (aState == _currentState)
        return;
    
    // Do the future event notification
    if (aState == kMUIDraggablePaneViewStateOpen) {
        if (_paneWillFinishOpening) {
            _paneWillFinishOpening(aTime);
        }
    } else {
        if (_paneWillFinishClosing) {
            _paneWillFinishClosing(aTime);
        }
    }
    
    // Get the new position
    CGFloat newY = (aState == kMUIDraggablePaneViewStateOpen ? _positionWhenOpen : _positionWhenClosed);
    
    // update now if aTime == 0 (ie no animation)
    if (aTime == 0) {
        [self moveOriginToY:newY];
        _currentState = aState;
        if (aState == kMUIDraggablePaneViewStateOpen) {
            if (_paneDidFinishOpening) {
                _paneDidFinishOpening();
            }
        } else {
            if (_paneDidFinishClosing) {
                _paneDidFinishClosing();
            }
        }
        return;
    }
    
    // Do the animation
    // Unlatch the touch
    _ignoreTouch = YES;
    [UIView animateWithDuration:aTime
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self moveOriginToY:newY];
                     }
                     completion:^(BOOL didComplete){
                         if (self.frame.origin.y == _positionWhenOpen) {
                             _currentState = kMUIDraggablePaneViewStateOpen;
                             if (_paneDidFinishOpening) {
                                 _paneDidFinishOpening();
                             }
                         } else {
                             _currentState = kMUIDraggablePaneViewStateClosed;
                             if (_paneDidFinishClosing) {
                                 _paneDidFinishClosing();
                             }
                         }
                         
                         // Restore touch handling
                         _ignoreTouch = NO;
                         MMLogInfo(@"%@", _currentState == kMUIDraggablePaneViewStateOpen ? @"Open":@"Closed");
                     }];
    

}

/////////////////////////////////////////////////////////////////////////

// Calculate the animation time needed to open/close from whereever we are given a fixed velocity (points/sec)
- (NSTimeInterval)_animationTimeNeededForStateChangeTo:(MUIDraggablePaneState)aState withVelocity:(CGFloat)aVelocity
{
    
    CGFloat newY = (aState == kMUIDraggablePaneViewStateOpen ? _positionWhenOpen : _positionWhenClosed);
    CGFloat currY = self.frame.origin.y;
    
    // Otherwise animated
    return fabs( (currY - newY) / aVelocity );
}

@end
/// @}