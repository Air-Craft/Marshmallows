//
//  NSError+MMAudioSessionErrors.m
//  SoundWand
//
//  Created by  on 20/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "NSError+Marshmallows.h"

@implementation NSError (Marshmallows)

//+ (id)errorWithDomain:(NSString *)domain d

/////////////////////////////////////////////////////////////////////////

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description failureReason:(NSString *)failureReason underlyingError:(NSError *)underlyingError
{
    NSMutableDictionary *userDict = [NSMutableDictionary dictionary]; 
    if (nil != description) {
        [userDict setObject:description forKey:NSLocalizedDescriptionKey];
    }
    if (nil != failureReason) {
        [userDict setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
    }
    if (nil != underlyingError) {
        [userDict setObject:underlyingError forKey:NSUnderlyingErrorKey];
    }
    
    return [NSError errorWithDomain:domain code:code userInfo:userDict];
}

/////////////////////////////////////////////////////////////////////////
+ (NSError *)errorWithOSStatus:(OSStatus)osErr description:(NSString *)description failureReason:(NSString *)failureReason
{
    return [NSError errorWithDomain:NSOSStatusErrorDomain
                               code:osErr
                        description:description
                      failureReason:failureReason 
                    underlyingError:nil];
}


/////////////////////////////////////////////////////////////////////////



@end
