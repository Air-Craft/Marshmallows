/**
 \addtogroup Marshmallows
 \author     Jonathan 'Wolf' Rentzsch, 2010 - http://github.com/rentzsch/NSInvocation-blocks.  Modified by Hari Karam Singh 2012
 \copyright  Copyright (c) 2010 Jonathan 'Wolf' Rentzsch: http://rentzsch.com. With Portions Copyright 2012 Club 15CC. License: http://opensource.org/licenses/mit-license.php.
 
 @{
 *//// \file NSInvocation+MMBlocks.h

#import <Foundation/Foundation.h>


/**
 \brief 
 */
@interface NSInvocation (MMBlocks)

/* Invoke with a block which simulates the call on target.  An invocation will be returned which represents that call.
 
 Usage example:
 
 NSInvocation *invocation = [NSInvocation jr_invocationWithTarget:myObject block:^(id myObject){
 [myObject someMethodWithArg:42.0];
 }];
 */
+ (id)mm_invocationWithTarget:(id)target block:(void (^)(id target))block;


@end
/// @}