/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 15/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "NSDictionary+Marshmallows.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - NSDictionary (Marshmallows)
/////////////////////////////////////////////////////////////////////////

@implementation NSDictionary (Marshmallows)

/////////////////////////////////////////////////////////////////////////

- (id)objectForNumericKey:(NSNumber *)aNumericKey
{
    // Loop through the keys and find one that matches this number
    id key = nil;
    for (key in self.allKeys) {
        if ([key isKindOfClass:NSNumber.class] && [(NSNumber *)key isEqualToNumber:aNumericKey]) {
            break;
        }
    }
    
    // Return the associated value or nil
    if (key) {
        return [self objectForKey:key];
    }
    return nil;
    
}

/////////////////////////////////////////////////////////////////////////

- (id)objectForIntegerKey:(NSInteger)anIntegerKey
{
    return [self objectForNumericKey:@(anIntegerKey)];
}

/////////////////////////////////////////////////////////////////////////

@end

/////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableDictionary (Marshmallows)
/////////////////////////////////////////////////////////////////////////

@implementation NSMutableDictionary (Marshmallows)

- (void)setObject:(id)anObject forNumericKey:(NSNumber *)aNumericKey
{
    // Get any existing key with this numeric value, or use the supplied one if its new
    NSNumber *key;
    key = [self objectForNumericKey:aNumericKey];
    if (!key) {
        key = aNumericKey;
    }
    [self setObject:anObject forKey:key];
}

/////////////////////////////////////////////////////////////////////////

- (void)setObject:(id)anObject forIntegerKey:(NSInteger)anIntegerKey
{
    return [self setObject:anObject forNumericKey:@(anIntegerKey)];
}

@end


/// @}