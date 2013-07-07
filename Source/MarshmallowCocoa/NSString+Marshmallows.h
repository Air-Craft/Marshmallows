/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 24/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file NSString+Marshmallows.h

#import <Foundation/Foundation.h>


@interface NSString (Marshmallows)

/** Convert an OSStatus number to its 4 char code as an NSString, or to a string of the number if it isn't a char code */
+ (NSString *)mm_ErrorCodeStringFromOSStatus:(OSStatus)anOSStatus;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Paths
/////////////////////////////////////////////////////////////////////////

/** Returns an NSString representing the first path found matching the specified constants or nil if none */
+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directoryConstant domainMask:(NSSearchPathDomainMask)domainMask;

/** Returns the application support directory with the app's bundle id appended.  As recommended in the File System Programming Guide */
+ (NSString *)pathForApplicationSupportDataDirectory;

/** Append a subfolder/file path onto the app data directory */
+ (NSString *)pathForApplicationSupportWithAppendedPath:(NSString *)pathToAppend;

/** Returns the user directory */
+ (NSString *)pathForUserDirectory;

/** Append a subfolder/file path onto the user directory */
+ (NSString *)pathForUserDirectoryWithAppendedPath:(NSString *)pathToAppend;

/** Returns the user's document directory */
+ (NSString *)pathForDocumentDirectory;

/** Append a subfolder/file path onto the user's document directory */
+ (NSString *)pathForDocumentDirectoryWithAppendedPath:(NSString *)pathToAppend;





@end
/// @}