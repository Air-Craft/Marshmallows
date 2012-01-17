#import "MarshmallowsTests.h"
#if DO_MMAnimatorTests == 1
//
//  MMAnimatorTests.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMAnimatorTests.h"


@implementation MMAnimatorTests


- (void)testSimplePinnedAnimator 
{
    MMSimplePinnedAnimator *anim = [MMSimplePinnedAnimator animatorFromValue:2 toValue:100];
    anim.pinValue = 40;
    anim.resetToPinValueOnFinish = YES;
    anim.duration = 5;
//    anim.beginTimeOffset = 1.5;
    anim.timingFunction = MMAnimatorTimingQuadraticEaseInOut;
    
    DLOGf(anim.currentValue);
    
    int i = 0;
    [anim start];
    while (i++ < 100 && !anim.finished) {
        usleep(100000);     // 1/10th sec
        DLOG("%.3f", anim.currentValue);
    }
    
    DLOGf(anim.currentValue);
    
}

@end


#endif