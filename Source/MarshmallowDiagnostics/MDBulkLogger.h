//
//  MDBulkLogger.h
//  InstrumentMotion
//
//  Created by Hari Karam Singh on 27/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** ********************************************************************************************************************/
#pragma mark -
#pragma mark MDBulkLogger Class

@interface MDBulkLogger : NSObject {
    NSMutableArray *logStrings;
}

@property (nonatomic, strong) NSString *separator;
@property (nonatomic) NSUInteger size;
@property (nonatomic, strong) NSString *preamble;

- (id)initWithSize:(NSUInteger)theSize;

- (void)add:(NSString *)format, ...; 
- (void)addWithFormat:(NSString *)format arguments:(va_list)arguments; 

- (void)dump;

@end


/** ********************************************************************************************************************/
#pragma mark -
#pragma mark Convenience Functions


#ifdef __cplusplus
extern "C" {
#endif

void MBLog1(NSString *format, ...);
void MBLog1SetSize(NSUInteger size);
void MBLog1SetSeparator(NSString *separator);
void MBLog1SetPreamble(NSString *pre);

void MBLog2(NSString *format, ...);
void MBLog2SetSize(NSUInteger size);
void MBLog2SetSeparator(NSString *separator);
void MBLog2SetPreamble(NSString *pre);

#ifdef __cplusplus
}   
#endif
