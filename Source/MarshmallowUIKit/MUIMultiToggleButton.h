/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 04/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file MUIMultiToggleButton.h

#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - MUIMultiToggleButton
/////////////////////////////////////////////////////////////////////

/** \brief IB Compatible custom button to allow rotation through multiple states/images via button presses
 
 \section muimtbus Usage
 \code{.m}
 - viewDidLoad {
 //...
 // Set up in interface builder. Set the "normal" state image.
 // Note the first call automatically adds the Normal state as the first toggle.
 [myMTButton addToggleWithImage:mySecondImage];
 [myMTButton addToggleWithImage:myThirdImage];
 [myMTButton addToggleEventTarget:self action:@selector(handleToggle:)];
 }
 
 - (void)handleToggle:(id)sender {
 MUIMultiToggleButton *btn = (MUIMultiToggleButton *)sender;
 NSLog(@"Current toggle index: %i", (MUIMultiToggleButton *)btn.toggleIdx);
 
 // Revert to previous state
 if ([self cantDoItForIdx:btn.toggleIdx]) {
 [btn toggleBack];
 }
 }
 \endcode
 
 \section muimtbn IB & UIButton Compatibility and Other Notes
 This class extends UIButton for IB compatibility and adds its Normal state image a the first toggle state.  This happens via a lazy init, when addToggleWithImage: is first called.   In this case when the UIButton's Normal state has already been set, the passed image argument would become the *second* toggle state and wouldn't show until pressed.
 
 \par
 The toggleIdx is -1 until a addToggleWithImage is called at which point it becomes 0.
 
 */
@interface MUIMultiToggleButton : UIButton

/** Buttons default to activating "on" states and sending event message when
 the touch up occurs.  Set this to YES for have Touch Down trigger the events
 */
@property (nonatomic) BOOL doEventsOnTouchDown;

/** The current button state.  Int as to be enum compatible.  -1 = uninitialised (need to call addToggleImage:) */
@property (nonatomic) NSInteger toggleIdx;

/** Adds a toggle state with corresponding image.
 If the Normal state is set in IB or via code, the first call to this method will first push this image onto the stack prior to the passed argument.  If Normal is not set, then the first call will set the Normal state to update the button appearance.
 */
- (void)addToggleWithImage:(UIImage *)image;

/** Add a target-action listener.  Note, no bitmask is needed as there is only 1 event. */
- (void)addToggleEventTarget:(id)target action:(SEL)action;

/** Manually toggle the button back one state.  Does NOT send events */
- (void)toggleBack;

/** Manually toggle the button forward one state.  Does NOT send events */
- (void)toggleForward;

@end

/// @}