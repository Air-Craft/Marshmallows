//
/// \file       Marshmallows.h
/// \defgroup   Marshmallows    Marshmallows: Cocoa extensions. Mmmmm...
///


//  Created by Hari Karam Singh on 03/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Marshmallows
#define Marshmallows

/////////////////////////////////////////////////////////////////////////
#pragma mark - Imports
/////////////////////////////////////////////////////////////////////////

#import "GLKit/MMGLK.h"

#import "ObjC/CEObjectiveCRuntime.h"

#import "Animator/MMAnimator.h"
#import "Animator/MMSimpleAnimator.h"
#import "Animator/MMSimplePinnedAnimator.h"
#import "Animator/MMAnimatorTimingBlock.h"


// ^ old way   v new way

#import "MarshmallowDebug.h"
#import "MarshmallowAnimation/MarshmallowAnimation.h"
#import "MarshmallowCocoa/MarshmallowCocoa.h"
#import "MarshmallowConcurrency/MarshmallowConcurrency.h"
#import "MarshmallowDiagnostics/MarshmallowDiagnostics.h"
#import "MarshmallowMath/MarshmallowMath.h"
#import "MarshmallowProfiling/MarshmallowProfiling.h"
#import "MarshmallowRecovery/MarshmallowRecovery.h"
#import "MarshmallowUIKit/MarshmallowUIKit.h"
#import "AudioMarshmallows/AudioMarshmallows.h"
#import "MarshmallowMisc/MarshmallowMisc.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
/////////////////////////////////////////////////////////////////////////
/// \ingroup Marshmallows
/// @{

/**
 Use in a singleton class inside a sharedInstance method.  The block should alloc, init and return the object
 */
#define MM_DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
    static dispatch_once_t token = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&token, ^{ \
        _sharedObject = block(); \
    }); \
    return _sharedObject; \


/// @}
#endif
