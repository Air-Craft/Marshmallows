#import <Foundation/Foundation.h>

/**
 An incomplete implementation which casts UITouch objects used as keys using NSValue:valueFromPointer to allow
 them to be safely used as MutableDictionary keys.
 */
@interface MMMutablePointerKeyedDictionary : NSObject
{
    NSMutableDictionary *dict;
}

- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray *)keyArray;

@end
