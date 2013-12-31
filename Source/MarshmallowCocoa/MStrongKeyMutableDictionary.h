//
//  MMutableStrongKeyDictionary.h
//  Marshmallows
//
//  Created by Hari Karam Singh on 29/12/2013.
//
//

#import <Foundation/Foundation.h>

/** A dictionary object which retains the keys rather than copies them. Please note that keys lookup up by pointer value and NOT isEqual.  If you need it the other way, then you probably want a normal dict */
@interface MStrongKeyMutableDictionary : NSObject <NSFastEnumeration>

+ (instancetype)dictionary;

- (NSUInteger)count;

- (void)setObject:(id)obj forKeyedSubscript:(id)key;
- (void)setObject:(id)anObject forKey:(id)aKey;

- (id)objectForKeyedSubscript:(id)key;
- (id)objectForKey:(id)aKey;

- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)removeAllObjects;

- (void)addEntriesFromStrongKeyDictionary:(MStrongKeyMutableDictionary *)otherDictionary;

- (NSArray *)allKeys;


@end
