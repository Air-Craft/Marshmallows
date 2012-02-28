#include "MarshmallowMath.h"


inline const float MMMapLinearRange(float inVal, float inMin, float inMax, float outMin, float outMax)
{
    return ( (inVal-inMin) / (inMax-inMin) * (outMax-outMin) + outMin );
}




inline const float MMMapBilinearRange(float inVal, float inMin, float inMax, float inMed, float outMin, float outMax, float outMed) 
{
    if (inVal <= inMed) {
        return MMMapLinearRange(inVal, inMin, inMed, outMin, outMed);
    } else {
        return MMMapLinearRange(inVal, inMed, inMax, outMed, outMax);
    }
}

