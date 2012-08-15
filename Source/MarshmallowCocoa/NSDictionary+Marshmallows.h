/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 15/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file NSDictionary+Marshmallows.h

#import <Foundation/Foundation.h>


/////////////////////////////////////////////////////////////////////////
#pragma mark - NSDictionary (Marshmallows)
/////////////////////////////////////////////////////////////////////////
/**
 \brief 
 */
@interface NSDictionary (Marshmallows)

/** Returns an object with a key matching the value of the supplied NSNumber 
 
 Note, just using object for key with object literals like @5 is not ideal as the compiler does not guarantee it will always reference the same pointer space
 */
- (id)objectForNumericKey:(NSNumber *)aNumericKey;

/** Get an object who's key is an NSNumber matching the given integer value */
- (id)objectForIntegerKey:(NSInteger)anIntegerKey;

@end


/////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableDictionary (Marshmallows)
/////////////////////////////////////////////////////////////////////////

/**
 \brief
 */
@interface NSMutableDictionary (Marshmallows)

/** Sets an entry with the given key overwriting any existing entry with a key of similar NSNumber value
 
 Note, just using object for key with object literals like @5 is not ideal as the compiler does not guarantee it will always reference the same pointer space
 */
- (void)setObject:(id)anObject forNumericKey:(NSNumber *)aNumericKey;

/** Set an object who's key is an NSNumber matching the given integer value */
- (void)setObject:(id)anObject forIntegerKey:(NSInteger)anIntegerKey;

@end

/// @}