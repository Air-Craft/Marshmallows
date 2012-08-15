/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 15/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file NSArray+NSDictionary+Subscripting.h
/// See this post for more info: http://stackoverflow.com/questions/11658669/how-to-enable-the-new-objective-c-object-literals-on-ios

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@interface NSDictionary(subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary(subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end

@interface NSArray(subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray(subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end
#endif


/// @}