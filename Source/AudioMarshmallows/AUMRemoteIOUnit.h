/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file AUMRemoteIOUnit.h
 
#import <Foundation/Foundation.h>
#import "AUMUnitProtocol.h"
#import "AUMUnitAbstract.h"


/**
 \brief A work in progress to encapsulate Remote I/O functionality in a readable & OO fashion 
 */
@interface AUMRemoteIOUnit : AUMUnitAbstract


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////


/** Convenience method for setting input bus 0 as it's the only one to that can be assigned
-(void)setInputRenderCallback:(AURenderCallbackStruct)aRenderCallback withStreamFormat:(AudioStreamBasicDescription)aStreamFormat;
*/


@end

/// @}