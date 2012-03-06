//
//  NSArray+Marshmallows.h
//  SoundWand
//
//  Created by  on 24/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Marshmallows)

/**
 Unpacks the elements into the ObjC objects passed into the method by reference.
 
 Elements remain in the array.  If there are fewer elements then the remaining object references will be untouched.  If there are fewer objects passed then they will be filled with the subset of the array.
 */
- (void)unpackInto:(__strong id *)obj1, ...;

@end
