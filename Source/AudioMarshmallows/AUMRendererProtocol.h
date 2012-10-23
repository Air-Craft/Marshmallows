/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMRendererProtocol.h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/**
 Protocol to define "Renderer" which can be attached to an AUMUnit's busses via its render callback struct. 
 */
@protocol AUMRendererProtocol <NSObject>

@property (nonatomic, readonly) AudioStreamBasicDescription renderCallbackStreamFormat;
@property (nonatomic, readonly) AURenderCallbackStruct renderCallbackStruct;


@end


/// @}