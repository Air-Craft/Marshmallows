/** 
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 22/11/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{ 
 */


#import "MCachedModalStoryboardSegue.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Statics
/////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * _MCachedModalStoryboardSegueCache;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Private Class - _MCachedSegueKey
/////////////////////////////////////////////////////////////////////////

@interface _MCachedSegueKey : NSObject <NSCopying>
{
    Class _vcClass;
    NSString *_identifier;
}
+ (id)keyWithIdentifier:(NSString *)anId viewController:(UIViewController *)aVC;
@end

@implementation _MCachedSegueKey

+ (id)keyWithIdentifier:(NSString *)anId viewController:(UIViewController *)aVC
{
    _MCachedSegueKey *me = [[self alloc] init];
    me->_vcClass = aVC.class;
    me->_identifier = [anId copy];
    return me;
}

- (BOOL)isEqual:(id)object
{
    _MCachedSegueKey *obj = (_MCachedSegueKey *)object;
    BOOL e = ([obj->_identifier isEqualToString:self->_identifier] &&
            obj->_vcClass == self->_vcClass);
    return e;
}

- (NSUInteger)hash
{
    NSUInteger hash = 0;
    hash = ((NSUInteger)_vcClass * 0x1f1f1f1f) ^ _identifier.hash;
    return hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    _MCachedSegueKey *copy = [_MCachedSegueKey new];
    copy->_identifier = [_identifier copy];
    copy->_vcClass = _vcClass;
    return copy;
}

@end




/////////////////////////////////////////////////////////////////////////
#pragma mark - MCachedModalStoryboardSegue
/////////////////////////////////////////////////////////////////////////

@implementation MCachedModalStoryboardSegue

/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

+ (void)drainCache
{
    _MCachedModalStoryboardSegueCache = nil;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Overrides
/////////////////////////////////////////////////////////////////////////


- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    // Alloc the static dict if required
    if (!_MCachedModalStoryboardSegueCache) {
        _MCachedModalStoryboardSegueCache = [NSMutableDictionary dictionary];
    }
    
    // Add it to the cache if doesn't exist...
    _MCachedSegueKey *key = [_MCachedSegueKey keyWithIdentifier:identifier viewController:destination];

    _destinationWasCached = YES;
    if (!([_MCachedModalStoryboardSegueCache.allKeys containsObject:key])) {
        _MCachedModalStoryboardSegueCache[key] = destination;
        _destinationWasCached = NO;
    }
    
    // Swizzle for the cached destination
    UIViewController *newDest = _MCachedModalStoryboardSegueCache[key];
    return [super initWithIdentifier:identifier source:source destination:newDest];
    
}

/////////////////////////////////////////////////////////////////////////

- (void)perform
{
    [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:nil];
}

@end

/// @}