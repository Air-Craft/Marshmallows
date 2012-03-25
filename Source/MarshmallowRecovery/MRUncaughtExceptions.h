/** 
 \addtogroup SoundWand
 \author     Created by  on 24/03/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 
 Many thanks to Matt Gallagher's UncaughtExceptionHandler code for the inspiration.
 */
/// \file MRUncaughtExceptions.h
 
 
#import <Foundation/Foundation.h>

typedef void (^MRUncaughtExceptionsBlock)(NSException *);

void MR_HandleUncaughtExceptionsWithBlock(MRUncaughtExceptionsBlock handlerBlock);

/////////////////////////////////////////////////////////////////////////
#pragma mark - Consts
/////////////////////////////////////////////////////////////////////////

/// @name Externs

/// Exception name for signal exceptions
extern NSString * const MRUncaughtExceptionSignalException;

/// Keys for userInfo dict 
extern NSString * const kMRUncaughtExceptionsSignalKey;
extern NSString * const kMRUncaughtExceptionsAddressesKey;

/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - MRUncaughtExceptions
/////////////////////////////////////////////////////////////////////////

/**
 \brief Static class for installing an uncaught exception handling block
 */
@interface MRUncaughtExceptions : NSObject

+ (void)installHandlerBlock:(MRUncaughtExceptionsBlock)handlerBlock;

/// Max number of uncaught exceptions to allow.  Prevents flooding and user harassment. Default =  5
+ (void)setUncaughtExceptionMaximum:(NSUInteger)max;

/// To be called manually in the handler block.  Shows an alert with the exception info and give s the option to quit or continue
+ (void)handleExceptionWithAlertView:(NSException *)exception;

/// Ensures that the handlers are deregisted and the correct abort process occurs
+ (void)rethrowException:(NSException *)exception;

@end

/// @}