#import <Foundation/Foundation.h>

/**
 An incomplete implementation which does NOT copy the key objects but instead, behind the scenes, creates an NSValue pointer to them to use as the key. This allows you to use them for things like UITouch objects
 */
@interface MWeakKeyMutableDictionary : NSObject <NSFastEnumeration>
{
    NSMutableDictionary *dict;
    NSMutableSet *retainer;
    
    unsigned long mutationCount;
}

+ (instancetype)dictionary;

- (NSUInteger)count;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)removeAllObjects;
- (void)addEntriesFromWeakKeyDictionary:(MWeakKeyMutableDictionary *)otherDictionary;
- (NSArray *)allKeys;
@end
