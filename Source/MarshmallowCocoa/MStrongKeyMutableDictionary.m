//
//  MMutableStrongKeyDictionary.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 29/12/2013.
//
//

#import "MStrongKeyMutableDictionary.h"

@implementation MStrongKeyMutableDictionary
{
    NSMutableArray *_keys;
    NSMutableArray *_values;
    unsigned long _mutationCount;
}

+ (instancetype)dictionary
{
    return [[self alloc] init];
}

//---------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (self) {
        _keys = [NSMutableArray array];
        _values = [NSMutableArray array];
    }
    return self;
}

//---------------------------------------------------------------------

- (NSUInteger)count
{
    return _keys.count;
}

//---------------------------------------------------------------------

- (void)setObject:(id)anObject forKey:(id)aKey
{
    self[aKey] = anObject;
}

//---------------------------------------------------------------------

/** "dict[key] = obj" notation */
- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
    _mutationCount++;
    
    // Replace if exists otherwise add it
    NSUInteger idx = [self _indexForKey:key];
    if (idx != NSNotFound) {
        // "nil" means remove
        if (!obj) {
            [_values removeObjectAtIndex:(NSUInteger)idx];
            [_keys removeObjectAtIndex:(NSUInteger)idx];
        } else {
            [_values replaceObjectAtIndex:(NSUInteger)idx withObject:obj];
        }
    } else {
        if (obj == nil) [NSException raise:NSInvalidArgumentException format:@"MStrongKeyMutableDictionary cannot set nil on a key that does not exist."];
        [_keys addObject:key];
        [_values addObject:obj];
    }
}

//---------------------------------------------------------------------

/** "dict[key]" syntax */
- (id)objectForKey:(id)aKey
{
    return self[aKey];
}

//---------------------------------------------------------------------

- (id)objectForKeyedSubscript:(id)key
{
    NSUInteger idx = [_keys indexOfObject:key];
    
    if (idx != NSNotFound) {
        return _values[idx];
    }
    return nil;
}

//---------------------------------------------------------------------

- (void)removeObjectForKey:(id)aKey
{
    NSUInteger idx = [_keys indexOfObject:aKey];
    if (idx != NSNotFound) {
        _mutationCount++;

        [_values removeObjectAtIndex:idx];
        [_keys removeObjectAtIndex:idx];
    }
}

//---------------------------------------------------------------------

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    // Convert key array to NSValue with pointers array
    for (id key in keyArray) {
        [self removeObjectForKey:key];
    }
}

//---------------------------------------------------------------------

- (void)removeAllObjects
{
    if (_keys.count) {
        _mutationCount++;
        [_keys removeAllObjects];
        [_values removeAllObjects];
    }
}

//---------------------------------------------------------------------

- (void)addEntriesFromStrongKeyDictionary:(MStrongKeyMutableDictionary *)otherDictionary
{
    // Fast enum undoes the keys.
    for (id aKey in otherDictionary) {
        self[aKey] = otherDictionary[aKey];
    }
}

//---------------------------------------------------------------------

- (NSArray *)allKeys
{
    return [_keys copy];
}

//---------------------------------------------------------------------

- (NSArray *)allValues
{
    return [_values copy];
}

//---------------------------------------------------------------------

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id, id, BOOL *))block
{
    for (NSUInteger i=0; i<_keys.count; i++) {

        BOOL stop = NO;
        block(_keys[i], _values[i], &stop);
        if (stop) break;
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - NSFastEnumeration
/////////////////////////////////////////////////////////////////////////

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    // We're after items starting at index state->state (I think!)
    NSUInteger cnt = _keys.count - state->state;
    if (cnt <= 0) {
        return 0;
    }
    
    // Convert a C array
    __unsafe_unretained id *objects;
    objects = (__unsafe_unretained id *)malloc(sizeof(id) * cnt);
    [_keys getObjects:objects range:NSMakeRange(state->state, cnt)];
    
    state->state += cnt;
    state->mutationsPtr = &_mutationCount;
    state->itemsPtr = objects;
    
    return cnt;
}

//---------------------------------------------------------------------


/////////////////////////////////////////////////////////////////////////
#pragma mark - Additional Privates
/////////////////////////////////////////////////////////////////////////

/** The index in the keys/values arrays or NSNotFound */
- (NSUInteger)_indexForKey:(id)aKey
{
    __block NSUInteger resIdx = NSNotFound;
    [_keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == aKey) {
            resIdx = idx;
            *stop = YES;
        }
    }];
    
    return resIdx;
}




@end
