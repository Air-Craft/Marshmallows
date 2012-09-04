/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */
/// \file AUMFilePlayerUnit.h
 
#import <Foundation/Foundation.h>
#import "AUMProxyUnitAbstract.h"
#import "AUMRemoteIOUnit.h"
#import "MarshmallowConcurrency.h"

/**
 \brief 
 */
@interface AUMFilePlayerUnit : AUMProxyUnitAbstract
{
    AUMRemoteIOUnit *_remoteIOUnit;     ///< Typed reference to _proxiedUnit for autocomplete convenience
    id <MCThreadProxyProtocol> _mcThread;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

- (id)initWithSampleRate:(Float64)theSampleRate
        ioBufferDuration:(NSTimeInterval)theIOBufferDuration
        fileReaderThread:(id<MCThreadProxyProtocol>)aThread;

/** Convenience method which creates it's own BG thread */
- (id)initWithSampleRate:(Float64)theSampleRate
        ioBufferDuration:(NSTimeInterval)theIOBufferDuration;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}