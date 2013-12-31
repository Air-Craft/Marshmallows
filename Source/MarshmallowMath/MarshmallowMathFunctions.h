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

#import <tgmath.h>
#include <CoreGraphics/CoreGraphics.h>


#ifdef __cplusplus
extern "C" {
#endif
    
/** Maps a value in one range propertionately into another range */
inline const CGFloat MM_MapLinearRange(CGFloat inVal, CGFloat inMin, CGFloat inMax, CGFloat outMin, CGFloat outMax);

/////////////////////////////////////////////////////////////////////////
    
/** Maps the in value onto one of two connected but not smooth ranges depending on whether it falls above or below inMed.  inMed maps to outMed */
inline const CGFloat MM_MapBilinearRange(CGFloat inVal, CGFloat inMin, CGFloat inMax, CGFloat inMed, CGFloat outMin, CGFloat outMax, CGFloat outMed) ;

/////////////////////////////////////////////////////////////////////////
    
/** Return the value if between min and max otherwise return min or max.  */
inline const CGFloat MM_Clamp(CGFloat inVal, CGFloat minVal, CGFloat maxVal);
    
    
/////////////////////////////////////////////////////////////////////////

/** Can't inline this for some reason because it uses tgmath */
const CGFloat MM_Wrap(CGFloat inVal, CGFloat min, CGFloat max);
    
#ifdef __cplusplus
}
#endif

#endif
