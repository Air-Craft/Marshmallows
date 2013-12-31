//
//  Created by Hari Karam Singh on 16/12/2011.
//  Copyright (c) 2011 Amritvela / Club 15CC.  MIT License.
//
#import "MWeakKeyMutableDictionary.h"

@implementation MWeakKeyMutableDictionary

+ (instancetype)dictionary
{
    return [[self alloc] init];
}

/////////////////////////////////////////////////////////////////////////

- (instancetype)init
{
    if (self = [super init]) {
        dict = [[NSMutableDictionary alloc] init]; 
        retainer = [NSMutableSet set];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////

- (NSUInteger)count
{
    return [retainer count];
}

/////////////////////////////////////////////////////////////////////////

- (void)setObject:(id)anObject forKey:(id)aKey
{   
    mutationCount++;
    // Get an NSValue for the pointer address
    NSValue *ptrVal = [NSValue valueWithPointer:(__bridge const void *)aKey];
    [dict setObject:anObject forKey:ptrVal];
    [retainer addObject:aKey];
}

/////////////////////////////////////////////////////////////////////////

- (id)objectForKey:(id)aKey
{
    // Loop through manually as to not have to create an NSValue (expensive)
    for (NSValue *key in [dict allKeys]) {
        if (key.pointerValue == (__bridge const void *)aKey) {
            return [dict objectForKey:key];
        }
    }
    return nil;
    
//    NSValue *ptrVal = [NSValue valueWithPointer:(__bridge const void *)aKey];
//    return [dict objectForKey:ptrVal];
}

/////////////////////////////////////////////////////////////////////////

- (void)removeObjectForKey:(id)aKey 
{
    mutationCount++;
    [dict removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)aKey]];
    [retainer removeObject:aKey];
}

/////////////////////////////////////////////////////////////////////////

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    // no need as it's covered in removeObjectForKey:  mutationCount++;
    // Convert key array to NSValue with pointers array
    for (id key in keyArray) {
        [self removeObjectForKey:key];
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)removeAllObjects
{
    mutationCount++;
    [dict removeAllObjects];
    [retainer removeAllObjects];
}

/////////////////////////////////////////////////////////////////////////

- (void)addEntriesFromWeakKeyDictionary:(MWeakKeyMutableDictionary *)otherDictionary
{
    // Fast enum undoes the keys.
    for (id aKey in otherDictionary) {
        [self setObject:[otherDictionary objectForKey:aKey] forKey:aKey];
    }
}

/////////////////////////////////////////////////////////////////////////

- (NSArray *)allKeys
{
    return [retainer allObjects];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - NSFastEnumeration
/////////////////////////////////////////////////////////////////////////


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state >= dict.count) {
        return 0;
    }
    
    // Convert the keys to a C array
    NSUInteger i = 0;
    __unsafe_unretained id *objects; 
    objects = (__unsafe_unretained id *)malloc(sizeof(id) * dict.count);
    for (NSValue *v in [dict allKeys]) {
        objects[i++] = (__unsafe_unretained id)[v pointerValue];
    }
    
    state->itemsPtr = objects;
    state->state = i;
    state->mutationsPtr = &mutationCount;
    
    return i;
}

@end
