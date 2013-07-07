/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 24/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "NSString+Marshmallows.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - NSString (Marshmallows)
/////////////////////////////////////////////////////////////////////////

@implementation NSString (Marshmallows)

+ (NSString *)mm_ErrorCodeStringFromOSStatus:(OSStatus)anOSStatus
{
    char str[10]="";
    OSStatus error = anOSStatus;
    
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else {
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    }
    
    return [NSString stringWithUTF8String:str];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - App & User Directory convenience functions
/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directoryConstant domainMask:(NSSearchPathDomainMask)domainMask
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray *possiblepaths = [sharedFM URLsForDirectory:directoryConstant
                                             inDomains:domainMask];
    NSURL *path = nil;
    
    if ([possiblepaths count] >= 1) {
        // Use the first directory (if multiple are returned)
        path = [possiblepaths objectAtIndex:0];
    }
    
    return path.path;
}

/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForApplicationSupportDataDirectory
{
    NSString *appSupportDir = [self pathForDirectory:NSApplicationSupportDirectory domainMask:NSUserDomainMask];
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString *appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        return [appSupportDir stringByAppendingPathComponent:appBundleID];
    } else
        return nil;
}

/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForApplicationSupportWithAppendedPath:(NSString *)pathToAppend
{
    return [[self pathForApplicationSupportDataDirectory] stringByAppendingPathComponent:pathToAppend];
}

/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForUserDirectory
{
    return [self pathForDirectory:NSUserDirectory domainMask:NSUserDomainMask];
}

/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForUserDirectoryWithAppendedPath:(NSString *)pathToAppend
{
    return [[self pathForUserDirectory] stringByAppendingPathComponent:pathToAppend];
    
}

/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForDocumentDirectory
{
    return [self pathForDirectory:NSDocumentDirectory domainMask:NSUserDomainMask];
}

/////////////////////////////////////////////////////////////////////////

+ (NSString *)pathForDocumentDirectoryWithAppendedPath:(NSString *)pathToAppend
{
    return [[self pathForDocumentDirectory] stringByAppendingPathComponent:pathToAppend];
}


@end

/// @}