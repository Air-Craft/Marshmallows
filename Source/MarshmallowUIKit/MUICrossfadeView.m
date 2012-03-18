//
//  MUICrossfadeView.m
//  SoundWand
//
//  Created by  on 05/03/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "MUICrossfadeView.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - MUICrossfadeView()
/////////////////////////////////////////////////////////////////////////

@interface MUICrossfadeView()

@end


/////////////////////////////////////////////////////////////////////////
#pragma mark - MUICrossfadeView
/////////////////////////////////////////////////////////////////////////

@implementation MUICrossfadeView

@synthesize activeIndex, fadeDuration;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame views:(NSArray *)theViews fadeDuration:(NSTimeInterval)theFadeDuration
{
    if (self = [super initWithFrame:frame]) {
        // Hide all the views and add them as subs to this view
        for (UIView *v in theViews) {
            
            // Disable fadeDuration to use default
            fadeDuration = theFadeDuration;
            activeIndex = NSNotFound;    // disabled as well
        
            v.hidden = YES;
            v.alpha = 0;
            [self addSubview:v];
        }
    }
    return self;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////


- (void)addView:(UIView *)view
{
    view.hidden = YES;
    [self addSubview:view];
}

/////////////////////////////////////////////////////////////////////////

- (void)showViewAtIndex:(NSUInteger)theIdx
{
    // Nothing to do if it's already the active one
    if (activeIndex == theIdx)
        return;    
    
    // Hide immediately all lagging animations and
    // fade out the visible one if any
    for (int i=0; i<self.subviews.count; i++) {
        UILabel *v = [[self subviews] objectAtIndex:i];
       // if (i == activeIndex) {
        if (!v.hidden){
            [UIView 
             animateWithDuration:fadeDuration 
             delay:0.0
             options:UIViewAnimationOptionBeginFromCurrentState
             animations:^{
                 v.alpha = 0; 
             }
             completion:nil];
        }
    }
    
    // Show the new one
    UILabel *v = [[self subviews] objectAtIndex:theIdx];
    v.hidden = NO;
    [UIView 
     animateWithDuration:fadeDuration 
     delay:0.0
     options:UIViewAnimationOptionBeginFromCurrentState
     animations:^{
        v.alpha = 1;
     }
     completion:nil];
    
    activeIndex = theIdx;
}

/////////////////////////////////////////////////////////////////////////

- (void)hideAll
{
    // Hide the visible one if any
    if (activeIndex != NSNotFound) {
        ((UIView *)[[self subviews] objectAtIndex:activeIndex]).hidden = YES;
        activeIndex = NSNotFound;
    }
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end
