//
//  MDTimeProfilerOC.h
//  SamplerEngine
//
//  Created by Hari Karam Singh on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Forward definition for C++ class
struct MDTimeProfiler;
typedef struct MDTimeProfiler MDTimeProfiler;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Objective-C Interface
/////////////////////////////////////////////////////////////////////////

@interface MDTimeProfilerOC : NSObject {
@private
    MDTimeProfiler *proxy;
}

+ profilerWithMaxMarks:(NSUInteger)maxMarks sampleSize:(NSUInteger)sampleSize;

- (id)initWithMaxMarks:(NSUInteger)maxMarks sampleSize:(NSUInteger)sampleSize;

- (void)setMainLabel:(NSString *)label;
- (void)setLabel:(NSString *)label forMark:(NSUInteger)markNum;
- (void)start;
- (void)mark:(NSUInteger)markNum;
- (void)outputAndReset;

@end