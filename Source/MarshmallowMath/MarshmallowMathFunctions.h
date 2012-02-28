//
/// \file  MarshmallowMath.h
/// \ingroup Marshmallows
//
//  Created by  on 28/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

//

#ifndef MarshmallowMath_h
#define MarshmallowMath_h

#ifdef __cplusplus
extern "C" {
#endif
    
/**
 Maps a value in one range propertionately into another range
 */
static inline const float MM_MapLinearRange(float inVal, float inMin, float inMax, float outMin, float outMax)
{
    return ( (inVal-inMin) / (inMax-inMin) * (outMax-outMin) + outMin );
}

/**
 Maps the in value onto one of two connected but not smooth ranges depending on whether it falls above or below inMed.  inMed maps to outMed
 */
static inline const float MM_MapBilinearRange(float inVal, float inMin, float inMax, float inMed, float outMin, float outMax, float outMed) 
{
    if (inVal <= inMed) {
        return MM_MapLinearRange(inVal, inMin, inMed, outMin, outMed);
    } else {
        return MM_MapLinearRange(inVal, inMed, inMax, outMed, outMax);
    }
}

#ifdef __cplusplus
}
#endif

#endif
