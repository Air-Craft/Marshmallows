//
//  MDBulkLogger.m
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 27/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDBulkLogger.h"

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark MDBulkLogger

@implementation MDBulkLogger

@synthesize separator, size, preamble;


- (id)initWithSize:(NSUInteger)theSize 
{
    if (self = [super init]) {
        if (! (logStrings = [[NSMutableArray alloc] initWithCapacity:theSize]) ) {
            return self = nil;
        }
        size = theSize;
        separator = @"\t";  // default to tab
    }
    return self;
}

- (void)add:(NSString *)format, ... 
{
    va_list args;
    va_start(args, format);
    [self addWithFormat:format arguments:args];
    
    va_end(args);
}

- (void)addWithFormat:(NSString *)format arguments:(va_list)arguments
{
    [logStrings addObject:[[NSString alloc] initWithFormat:format arguments:arguments]];
    
    if ([logStrings count] >= size) {
        [self dump];
    }
}

- (void)dump
{
    if (preamble) {
        NSLog(@"%@\n%@", preamble, [logStrings componentsJoinedByString:separator]);
    } else {
        NSLog(@"%@", [logStrings componentsJoinedByString:separator]);
    }
    [logStrings removeAllObjects];
}

@end


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Convenience Functions

#define _MBlogDef(sizeVar, sepVar, preambleVar) \
    static MDBulkLogger *logger; \
    if (nil == logger) { \
        logger = [[MDBulkLogger alloc] initWithSize:sizeVar]; \
        if (nil != sepVar) { logger.separator = sepVar; } \
        if (nil != preambleVar) { logger.preamble = preambleVar; } \
    } \
    va_list args; \
    va_start(args, format); \
    [logger addWithFormat:format arguments:args]; \
    va_end(args);

NSUInteger _MBLog1Size = 100u;
NSString *_MBLog1Sep = nil;    
NSString *_MBLog1Preamble = nil;    
void MBLog1(NSString *format, ...) { _MBlogDef(_MBLog1Size, _MBLog1Sep, _MBLog1Preamble); }
void MBLog1SetSize(NSUInteger size) { _MBLog1Size = size; }
void MBLog1SetSeparator(NSString *sep) { _MBLog1Sep = sep; }
void MBLog1SetPreamble(NSString *pre) { _MBLog1Preamble = pre; }

NSUInteger _MBLog2Size = 100u;
NSString *_MBLog2Sep = nil;    
NSString *_MBLog2Preamble = nil;    
void MBLog2(NSString *format, ...) { _MBlogDef(_MBLog2Size, _MBLog2Sep, _MBLog2Preamble); }
void MBLog2SetSize(NSUInteger size) { _MBLog2Size = size; }
void MBLog2SetSeparator(NSString *sep) { _MBLog2Sep = sep; }
void MBLog2SetPreamble(NSString *pre) { _MBLog2Preamble = pre; }

