/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 25/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file NSURL+Marshmallows.h

#import <Foundation/Foundation.h>

@interface NSURL (Marshmallows)

/////////////////////////////////////////////////////////////////////////
#pragma mark - App & User Directory convenience functions
/////////////////////////////////////////////////////////////////////////

/** Returns an NSURL representing the first path found matching the specified constants or nil if none */
+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)directoryConstant domainMask:(NSSearchPathDomainMask)domainMask;

/** Returns the application support directory with the app's bundle id appended.  As recommended in the Fil System Programming Guide */
+ (NSURL *)URLForApplicationSupportDataDirectory;

/** Append a subfolder/file path onto the app data directory */
+ (NSURL *)URLForApplicationSupportWithAppendedPath:(NSString *)pathToAppend;

/** Returns the user directory */
+ (NSURL *)URLForUserDirectory;

/** Append a subfolder/file path onto the user directory */
+ (NSURL *)URLForUserDirectoryWithAppendedPath:(NSString *)pathToAppend;


/** Returns the user's document directory */
+ (NSURL *)URLForDocumentDirectory;

/** Append a subfolder/file path onto the user's document directory */
+ (NSURL *)URLForDocumentDirectoryWithAppendedPath:(NSString *)pathToAppend;


@end
/// @}