#import <Foundation/Foundation.h>

/**
 An incomplete implementation which casts UITouch objects used as keys using NSValue:valueFromPointer to allow
 them to be safely used as MutableDictionary keys.
 */
@interface MNSMutableObjectKeyDictionary : NSObject <NSFastEnumeration>
{
    NSMutableDictionary *dict;
    NSMutableSet *retainer;
    
    unsigned long mutationCount;
}

+ (id)dictionary;

- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray *)keyArray;

@end
