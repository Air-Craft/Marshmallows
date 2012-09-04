/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "AUMFilePlayerUnit.h"
#import "AUMFilePlayerUnitRCB.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMFilePlayerUnit
/////////////////////////////////////////////////////////////////////////

@implementation AUMFilePlayerUnit

/////////////////////////////////////////////////////////////////////////
#pragma mark - Init
/////////////////////////////////////////////////////////////////////////

/** Create an underlying RemoteIO unit and set our callback to it */
- (id)initWithSampleRate:(Float64)theSampleRate
        ioBufferDuration:(NSTimeInterval)theIOBufferDuration
        fileReaderThread:(id<MCThreadProxyProtocol>)aThread
{
    self = [super init];
    if (self) {

        /////////////////////////////////////////
        // SETUP REMOTEIO UNIT
        /////////////////////////////////////////

        _proxiedUnit = [[AUMRemoteIOUnit alloc] init];
        _remoteIOUnit = _proxiedUnit;   // typed for convenience
        
        // Set our render callback and create an ASBD to match its code
        AURenderCallbackStruct rcb;
        rcb.inputProc = &AUMFilePlayerUnitRCB;
        rcb.inputProcRefCon = NULL;

        // Set the asbd used by our callback
        AudioStreamBasicDescription asbd;
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kAudioFormatFlagsCanonical; // interleaved, float
        asbd.mChannelsPerFrame = 2u;
        asbd.mFramesPerPacket = 1u;
        asbd.mBitsPerChannel = 8u * sizeof(Float32);
        asbd.mBytesPerFrame = asbd.mChannelsPerFrame * asbd.mBitsPerChannel / 8u;
        asbd.mBytesPerPacket = asbd.mBytesPerFrame * asbd.mFramesPerPacket;
        asbd.mSampleRate = theSampleRate;
        
        _remoteIOUnit setInputRenderCallback:rcb withStreamFormat:(AudioStreamBasicDescription)
        
        /////////////////////////////////////////
        // SETUP THREAD
        /////////////////////////////////////////
        // Assign our thread and set
        _mcThread = anMCThread;
        
        
        [_mcThread addInvocation:<#(NSInvocation *)#> desiredInterval:<#(NSTimeInterval)#>];
        

    }
    return self;
}

- (id)init
{
    // Create a MCSimpleThread to use
    MCSimpleThreadProxy *thread = [[MCSimpleThreadProxy alloc] init];
    if (self = [)
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Property Accessors
/////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
/////////////////////////////////////////////////////////////////////////



@end

/// @}