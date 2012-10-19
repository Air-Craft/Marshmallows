/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */
/// \file AUMException.h
 
#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Exception Constants
/////////////////////////////////////////////////////////////////////////

/** For AVAudioSession generated errors */
FOUNDATION_EXTERN NSString *const kAUMAudioSessionException;

FOUNDATION_EXTERN NSString *const kAUMAudioUnitException;   ///< Audio Units and the AUGraph
FOUNDATION_EXTERN NSString *const kAUMAudioFileException;   ///< Audio file I/O
FOUNDATION_EXTERN NSString *const kAUMAudioIncompatibleFileFormatException;   ///< Audio file format issues (eg. > 2 channels)

/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMException
/////////////////////////////////////////////////////////////////////////

/**
 \brief Typed exception subclass for easily handling by the client
 
 AUMExceptions are generally recoverable, eg. file read errors.
 */
@interface AUMException : NSException

/** Easily raise OSStatus-based exceptions with underlying userInfo dict that has the status as an NSNumber in the kMMOSStatusKey key */
+ (void)raise:(NSString *)name OSStatus:(OSStatus)anOSStatus format:(NSString *)format, ...;

/** Base method used via version above and others to pass va_list directly */
+ (void)raise:(NSString *)name OSStatus:(OSStatus)anOSStatus format:(NSString *)format arguments:(va_list)argList;


@property (nonatomic, readonly) OSStatus OSStatus;
@property (nonatomic, readonly) NSString *OSStatusAsNSString;




@end

/// @}