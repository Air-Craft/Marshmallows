//
//  NSError+MMAudioSessionErrors.h
//  SoundWand
//
//  Created by  on 20/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Marshmallows)

/**
 Convenience method. Pass nil to bypass a parameter.
 */
+ errorWithDomain:(NSString *)domain 
             code:(NSInteger)code 
      description:(NSString *)description 
    failureReason:(NSString *)failureReason 
  underlyingError:(NSError *)underlyingError;


/**
 Convenience method for NSOSStatusErrorDomain errors.  Code is the OSStatus returned
 */
+ (NSError *)errorWithOSStatus:(OSStatus)osErr 
                   description:(NSString *)description
                 failureReason:(NSString *)failureReason;

@end
