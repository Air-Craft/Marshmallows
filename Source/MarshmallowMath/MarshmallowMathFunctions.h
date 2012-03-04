//
/// \file  MarshmallowMath.h
/// \ingroup Marshmallows
//
//  Created by  on 28/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

//
#import <tgmath.h>
#ifndef MarshmallowMath_h
#define MarshmallowMath_h

#ifdef __cplusplus
extern "C" {
#endif
    
/**
 Maps a value in one range propertionately into another range
 */
const float MM_MapLinearRange(float inVal, float inMin, float inMax, float outMin, float outMax);

/**
 Maps the in value onto one of two connected but not smooth ranges depending on whether it falls above or below inMed.  inMed maps to outMed
 */
const float MM_MapBilinearRange(float inVal, float inMin, float inMax, float inMed, float outMin, float outMax, float outMed) ;

    
/**
 Return the value if between min and max otherwise return min or max. 
 */
const float MM_Clamp(float inVal, float minVal, float maxVal);
    
#ifdef __cplusplus
}
#endif

#endif
