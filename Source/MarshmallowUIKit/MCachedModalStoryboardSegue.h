/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 22/11/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file MCachingModalStoryboardSegue.h

#import <UIKit/UIKit.h>

@interface MCachedModalStoryboardSegue : UIStoryboardSegue

/** Manually drain the VC cache. This is the only way to release the cached VCs from their static store
 
 Also release the dict used to hold the cache.  Make this a final op in your apps shutdown cleanup */
+ (void)drainCache;


/** Use for exampe in [prepareForSegue:...] to determine whether the destination VC is a fresh instance or a pre-existing one */
@property (nonatomic, readonly) BOOL destinationWasCached;

@end

/// @}