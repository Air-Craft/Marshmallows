//
//  MarshmallowMath.h
//  SoundWand
//
//  Created by  on 28/02/2012.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#ifndef MarshmallowMath_h
#define MarshmallowMath_h

/**
 Maps a value in one range propertionately into another range
 */
inline const float MMMapLinearRange(float inVal, float inMin, float inMax, float outMin, float outMax);

/**
 Maps the in value onto one of two connected but not smooth ranges depending on whether it falls above or below inMed.  inMed maps to outMed
 */
inline const float MMMapBilinearRange(float inVal, float inMin, float inMax, float inMed, float outMin, float outMax, float outMed);

#endif
