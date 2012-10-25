/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 25/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "NSURL+Marshmallows.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - NSURL (Marshmallows)
/////////////////////////////////////////////////////////////////////////

@implementation NSURL (Marshmallows)

/////////////////////////////////////////////////////////////////////////
#pragma mark - App & User Directory convenience functions
/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)directoryConstant domainMask:(NSSearchPathDomainMask)domainMask
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:directoryConstant
                                             inDomains:domainMask];
    NSURL* url = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        url = [possibleURLs objectAtIndex:0];
    }

    return url;
}

/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForApplicationSupportDataDirectory
{
    NSURL *appSupportDir = [self URLForDirectory:NSApplicationSupportDirectory domainMask:NSUserDomainMask];
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        return [appSupportDir URLByAppendingPathComponent:appBundleID];
    } else
        return nil;
}

/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForApplicationSupportWithAppendedPath:(NSString *)pathToAppend
{
    return [[self URLForApplicationSupportDataDirectory] URLByAppendingPathComponent:pathToAppend];
}

/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForUserDirectory
{
    return [self URLForDirectory:NSUserDirectory domainMask:NSUserDomainMask];
}

/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForUserDirectoryWithAppendedPath:(NSString *)pathToAppend
{
    return [[self URLForUserDirectory] URLByAppendingPathComponent:pathToAppend];
    
}

/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForDocumentDirectory
{
    return [self URLForDirectory:NSDocumentDirectory domainMask:NSUserDomainMask];
}

/////////////////////////////////////////////////////////////////////////

+ (NSURL *)URLForDocumentDirectoryWithAppendedPath:(NSString *)pathToAppend
{
    return [[self URLForDocumentDirectory] URLByAppendingPathComponent:pathToAppend];
}

@end

/// @}