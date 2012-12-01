/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */

#import "AUMException.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - Exception Constants
/////////////////////////////////////////////////////////////////////////

NSString *const kAUMAudioSessionException = @"kAUMAudioSessionException";
NSString *const kAUMAudioUnitException = @"kAUMAudioUnitException";
NSString *const kAUMAudioFileException = @"kAUMAudioFileException";
NSString *const kAUMAudioIncompatibleFileFormatException = @"kAUMAudioIncompatibleFileFormatException";



/////////////////////////////////////////////////////////////////////////
#pragma mark - AUMException
/////////////////////////////////////////////////////////////////////////

@implementation AUMException


+ (void)raise:(NSString *)name OSStatus:(OSStatus)anOSStatus format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [self raise:name OSStatus:anOSStatus format:format arguments:args];
    va_end(args);
    
}

/////////////////////////////////////////////////////////////////////////

+ (void)raise:(NSString *)name OSStatus:(OSStatus)anOSStatus format:(NSString *)format arguments:(va_list)argList
{
    // Get the reason formatted string
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:argList];
    
    // Throw!
    AUMException *e = (AUMException *)[self exceptionWithName:name reason:reason userInfo:nil];
    
    e->_OSStatus = anOSStatus;
    
    @throw e;
}

/////////////////////////////////////////////////////////////////////////

- (NSString *)OSStatusAsNSString
{
    char str[10]="";
    OSStatus error = _OSStatus;
    
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


@end

/// @}