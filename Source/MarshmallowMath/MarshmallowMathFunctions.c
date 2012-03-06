#include <tgmath.h>
#include "MarshmallowMathFunctions.h"


/////////////////////////////////////////////////////////////////////////

const float MM_MapLinearRange(float inVal, float inMin, float inMax, float outMin, float outMax)
{
    return ( (inVal-inMin) / (inMax-inMin) * (outMax-outMin) + outMin );
}

/////////////////////////////////////////////////////////////////////////

const float MM_MapBilinearRange(float inVal, float inMin, float inMax, float inMed, float outMin, float outMax, float outMed) 
{
    if (inVal <= inMed) {
        return MM_MapLinearRange(inVal, inMin, inMed, outMin, outMed);
    } else {
        return MM_MapLinearRange(inVal, inMed, inMax, outMed, outMax);
    }
}

/////////////////////////////////////////////////////////////////////////

const float MM_Clamp(float inVal, float minVal, float maxVal)
{
    return (inVal < minVal ? minVal : (inVal > maxVal ? maxVal : inVal));
}

/////////////////////////////////////////////////////////////////////////

const float MM_Wrap(float inVal, float min, float max)
{
    const float range = max - min;
    
    // Optomisations
    if (inVal >= min) {
        if (inVal <= max)   return inVal;                       // within range
        else if (inVal < max + range) return inVal - range;     // within one range above
    } else if (inVal >= min - range) return inVal + range;      // within one range below
    
    // General case
    return fmod(inVal - min, range) + min;
}