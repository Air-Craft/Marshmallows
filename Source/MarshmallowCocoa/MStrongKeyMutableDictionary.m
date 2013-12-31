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
    NSInteger idx = [self _indexForKey:key];
    if (idx != NSNotFound) {
        [_values replaceObjectAtIndex:idx withObject:obj];
    } else {
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
    NSInteger idx = [_keys indexOfObject:key];
    
    if (idx != NSNotFound) {
        return _values[idx];
    }
    return nil;
}

//---------------------------------------------------------------------

- (void)removeObjectForKey:(id)aKey
{
    NSInteger idx = [_keys indexOfObject:aKey];
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


/////////////////////////////////////////////////////////////////////////
#pragma mark - NSFastEnumeration
/////////////////////////////////////////////////////////////////////////

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    NSUInteger cnt = _keys.count;
    if (state->state >= cnt) {
        return 0;
    }
    
    // ?? If state.state contains the start idx then this isnt quite right, unless it is always 0
    
    // Convert the keys to a C array
    [_keys getObjects:state->itemsPtr range:NSMakeRange(0, cnt)];
    
    state->state = cnt;
    state->mutationsPtr = &_mutationCount;
    
    return cnt;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Additional Privates
/////////////////////////////////////////////////////////////////////////

/** The index in the keys/values arrays or NSNotFound */
- (NSInteger)_indexForKey:(id)aKey
{
    __block NSInteger resIdx = NSNotFound;
    [_keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == aKey) {
            resIdx = idx;
            *stop = YES;
        }
    }];
    
    return resIdx;
}




@end
