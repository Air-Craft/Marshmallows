//
//  Created by Hari Karam Singh on 16/12/2011.
//  Copyright (c) 2011 Amritvela / Club 15CC.  MIT License.
//
#import "MNSMutableObjectKeyDictionary.h"

@implementation MNSMutableObjectKeyDictionary

+ (id)dictionary 
{
    return [[self alloc] init];
}

/////////////////////////////////////////////////////////////////////////

- (id)init
{
    if (self = [super init]) {
        dict = [[NSMutableDictionary alloc] init]; 
        retainer = [NSMutableSet set];
    }
    return self;
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
    // Get an NSValue for the pointer address
    NSValue *ptrVal = [NSValue valueWithPointer:(__bridge const void *)aKey];
    return [dict objectForKey:ptrVal];    
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
    mutationCount++;
    // Convert key array to NSValue with pointers array
    for (id key in keyArray) {
        [self removeObjectForKey:key];
    }
}

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
