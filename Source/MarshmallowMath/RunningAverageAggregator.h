/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file RunningAverageAggregator

#ifndef __Marshmallows__TimeWindowAverageAggregator__
#define __Marshmallows__TimeWindowAverageAggregator__

#include <iostream>
#include <queue>


namespace Marshmallows {

/////////////////////////////////////////////////////////////////////////
#pragma mark - Declaration
/////////////////////////////////////////////////////////////////////////

    
    template <typename SampleType=double>
    class RunningAverageAggregator
    {
    public:
        RunningAverageAggregator(unsigned poolSize) :
        _poolSize(poolSize),
        _sum(0),
        _samples(std::queue<SampleType>())
        {
            std::cout<<_samples.size();
        };
        
        
    public:
        void add(SampleType value);   // override
        
        /** The current average of the last N (<= poolSize) samples added.  If none, then it returns 0. If only 1 then the average will be the sample's value. */
        SampleType currentValue();
        
    private:
        std::queue<SampleType> _samples;
        SampleType _sum;
        uint32_t _poolSize;
    };
    
    

/////////////////////////////////////////////////////////////////////////
#pragma mark - Definitions
/////////////////////////////////////////////////////////////////////////
    
    template <typename SampleType>
    void RunningAverageAggregator<SampleType>::add(SampleType value)
    {
        // If the pool size is at the max, remove & subtract the last sample
        if (_samples.size() == _poolSize) {
            _sum -= _samples.front();
            _samples.pop();
        }
        
        // And add the new one
        _samples.push(value);
        _sum += value;
    }
    
    
    template <typename SampleType>
    SampleType RunningAverageAggregator<SampleType>::currentValue()
    {
        // Report 0 if no samples
        if (!_samples.size()) return SampleType(0);
        
        return _sum / SampleType(_samples.size());
    }
    


}





#endif /* defined(__Marshmallows__TimeWindowAverageAggregator__) */

/// @}
