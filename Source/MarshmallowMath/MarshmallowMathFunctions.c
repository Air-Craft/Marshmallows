#include <tgmath.h>
#include <CoreGraphics/CoreGraphics.h>
#include "MarshmallowMathFunctions.h"


/////////////////////////////////////////////////////////////////////////

const CGFloat MM_MapLinearRange(CGFloat inVal, CGFloat inMin, CGFloat inMax, CGFloat outMin, CGFloat outMax)
{
    return ( (inVal-inMin) / (inMax-inMin) * (outMax-outMin) + outMin );
}

/////////////////////////////////////////////////////////////////////////

const CGFloat MM_MapBilinearRange(CGFloat inVal, CGFloat inMin, CGFloat inMax, CGFloat inMed, CGFloat outMin, CGFloat outMax, CGFloat outMed) 
{
    if (inVal <= inMed) {
        return MM_MapLinearRange(inVal, inMin, inMed, outMin, outMed);
    } else {
        return MM_MapLinearRange(inVal, inMed, inMax, outMed, outMax);
    }
}

/////////////////////////////////////////////////////////////////////////

const CGFloat MM_Clamp(CGFloat inVal, CGFloat minVal, CGFloat maxVal)
{
    return (inVal < minVal ? minVal : (inVal > maxVal ? maxVal : inVal));
}

/////////////////////////////////////////////////////////////////////////

const CGFloat MM_Wrap(CGFloat inVal, CGFloat min, CGFloat max)
{
    const CGFloat range = max - min;
    
    // Optomisations
    if (inVal >= min) {
        if (inVal <= max)   return inVal;                       // within range
        else if (inVal < max + range) return inVal - range;     // within one range above
    } else if (inVal >= min - range) return inVal + range;      // within one range below
    
    // General case
    return fmod(inVal - min, range) + min;
}