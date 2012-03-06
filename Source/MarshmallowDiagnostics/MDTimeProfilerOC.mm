//
//  MDTimeProfilerOC.m
//  SamplerEngine
//
//  Created by Hari Karam Singh on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDTimeProfiler.h"
#import "MDTimeProfilerOC.h"

@implementation MDTimeProfilerOC

/////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
/////////////////////////////////////////////////////////////////////////

+ (id)profilerWithMaxMarks:(NSUInteger)maxMarks sampleSize:(NSUInteger)sampleSize
{
    return [[self alloc] initWithMaxMarks:maxMarks sampleSize:sampleSize];
}

- (id)initWithMaxMarks:(NSUInteger)maxMarks sampleSize:(NSUInteger)sampleSize
{
    if (self = [super init]) {
        proxy = new MDTimeProfiler(maxMarks, sampleSize);
    }
    return self;
}

- (void)dealloc
{
    delete proxy;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

- (void)setMainLabel:(NSString *)label
{
    proxy->setMainLabel([label cStringUsingEncoding:[NSString defaultCStringEncoding]]);
}
- (void)setLabel:(NSString *)label forMark:(NSUInteger)markNum
{
    proxy->setMarkLabel(markNum, [label cStringUsingEncoding:[NSString defaultCStringEncoding]]);
}
- (void)start 
{
    proxy->start();
}
- (void)mark:(NSUInteger)markNum
{
    proxy->mark(markNum);
}
- (void)outputAndReset 
{
    proxy->outputAndReset();
}

@end
