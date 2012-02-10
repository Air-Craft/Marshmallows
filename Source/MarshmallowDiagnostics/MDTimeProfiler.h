#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <iostream>
#import <string>
#import <vector>
using namespace std;

/////////////////////////////////////////////////////////////////////////
#pragma mark - C++ Declaration
/////////////////////////////////////////////////////////////////////////

class MDTimeProfiler
{
public:
    static const int LABEL_PADDING = 4;
    static const int NUMBER_FIELD_WIDTH = 10;
    
private:
    vector< vector<NSTimeInterval> > times;
    vector<string> markLabels;
    string mainLabel;
    size_t sampleSize;
    size_t maxMarks;
    long iteration;

public:
    MDTimeProfiler(size_t theMaxMarks, size_t theSampleSize);
    void clear();
    void setMainLabel(string);
    void setMarkLabel(size_t, string);   
    
    inline void start();
    inline void mark(size_t);
    
    void outputAndReset();
    
private:
    void calculateStats(vector<NSTimeInterval>&inVals, NSTimeInterval &outMean, NSTimeInterval &outStdDev, NSTimeInterval &outMax);
    
    string formatTimeForOutput(NSTimeInterval);
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - C++ Inlines
/////////////////////////////////////////////////////////////////////////

inline void MDTimeProfiler::start()
{    
    // Check whether we've hit the limit and output and reset
    if (iteration == sampleSize - 1) {
        outputAndReset();
    }
    ++iteration;
    
    times[0][iteration] = CACurrentMediaTime();
}

/////////////////////////////////////////////////////////////////////////

inline void MDTimeProfiler::mark(size_t mNum)
{
    times[mNum][iteration] = CACurrentMediaTime();
}

