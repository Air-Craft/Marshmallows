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
 Abstract protocol to define "Renderer" which can be attached to an AUMUnit's busses via its render callback struct. 
 \abstract
 */
@protocol AUMRendererProtocolAbstract <NSObject>

@property (nonatomic, readonly) AURenderCallbackStruct renderCallbackStruct;

@end


/// @}