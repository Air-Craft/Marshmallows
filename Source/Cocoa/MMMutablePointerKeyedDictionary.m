//
//  Created by Hari Karam Singh on 16/12/2011.
//  Copyright (c) 2011 Amritvela / Club 15CC.  MIT License.
//
#import "MMMutablePointerKeyedDictionary.h"

@implementation MMMutablePointerKeyedDictionary

- (id)init
{
    if (self = [super init]) {
        dict = [[NSMutableDictionary alloc] init]; 
    }
    return self;
}

/**********************************************************************/

- (void)setObject:(id)anObject forKey:(id)aKey
{   
    // Get an NSValue for the pointer address
    NSValue *ptrVal = [NSValue valueWithPointer:(__bridge const void *)aKey];
    [dict setObject:anObject forKey:ptrVal];
}

/**********************************************************************/

- (id)objectForKey:(id)aKey
{
    // Get an NSValue for the pointer address
    NSValue *ptrVal = [NSValue valueWithPointer:(__bridge const void *)aKey];
    return [dict objectForKey:ptrVal];    
}

/**********************************************************************/

- (void)removeObjectForKey:(id)aKey 
{
    [dict removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)aKey]];
}

/**********************************************************************/

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    // Convert key array to NSValue with pointers array
    NSMutableArray *newKeys;
    for (id key in keyArray) {
        [newKeys addObject:[NSValue valueWithPointer:(__bridge const void *)key]];
    }
    [dict removeObjectsForKeys:newKeys];
}



@end
