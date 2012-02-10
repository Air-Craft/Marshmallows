#import <exception>
#import <stdexcept>
#import <cmath>
#import <sstream>
#import <iomanip>
#import "MDTimeProfiler.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - C++ Definitions
/////////////////////////////////////////////////////////////////////////

MDTimeProfiler::MDTimeProfiler(size_t theMaxMarks, size_t theSampleSize)
{
    
    sampleSize = theSampleSize;
    maxMarks = theMaxMarks;
    
    clear();
    
    // Init the labels
    mainLabel = "MDTimeProfiler";
    string s = "";
    markLabels = vector<string>(maxMarks, s);
}

/////////////////////////////////////////////////////////////////////////

void MDTimeProfiler::clear()
{
    iteration = -1;
    
    // Init the vectors
    vector<NSTimeInterval> unit = vector<NSTimeInterval>(sampleSize, 0);
    times = vector< vector<NSTimeInterval> >(maxMarks, unit);
}

/////////////////////////////////////////////////////////////////////////

void MDTimeProfiler::setMainLabel(string labelStr) {  mainLabel = labelStr; }

/////////////////////////////////////////////////////////////////////////

void MDTimeProfiler::setMarkLabel(size_t markNum, string labelStr)
{
    if (markNum < 1 ) throw out_of_range("Yo");
    markLabels.assign(markNum, labelStr);
}

/////////////////////////////////////////////////////////////////////////

void MDTimeProfiler::outputAndReset()
{
    NSTimeInterval mean, stdDev, max;
    
    // Get the row label padding from the longest mark label
    unsigned labelPadding = 0;
    for (int i=0; i<markLabels.size(); i++) {
        labelPadding = markLabels[i].length() > labelPadding 
        ? markLabels[i].length() 
        : labelPadding;
    }
    if (labelPadding < 7) labelPadding = 7;
    labelPadding += LABEL_PADDING;
    
    
    // Output the header info
    cout << mainLabel << endl;
    
    cout.flags(ios_base::left);
    cout << setw(labelPadding) << " ";
    cout << setw(NUMBER_FIELD_WIDTH) << "mean" 
         << setw(NUMBER_FIELD_WIDTH) << "std dev" 
         << setw(NUMBER_FIELD_WIDTH) << "max" << endl;
    
    
    // Loop through the marks, get the time diffs and calculate the stats for them and output
    for (size_t i = 0; i < maxMarks - 1; i++) {
        
        // Break if we've hit an empty mark set
        if (0 == times[i+1][0] or 0 == times[i][0]) {
            break;
        }
        
        // Calculate the time lapsed between the two marks
        vector<NSTimeInterval> *markA, *markB;
        markA = &times[i];
        markB = &times[i+1];
        vector<NSTimeInterval> diffs = vector<NSTimeInterval> (sampleSize);
        
        for (size_t j=0; j < sampleSize; j++) {   // should be the sample size
            diffs[j] = (*markB)[j] - (*markA)[j];
        }
        
        calculateStats(diffs, mean, stdDev, max);
        
        //  Output the label...
        if (markLabels[i+1] == "") {
            stringstream ss;
            ss << "Mark " << i+1;
            cout << setw(labelPadding) << ss.str();
        } else {
            cout << setw(labelPadding) << markLabels[i+1];  // one based
        }
        
        // Output the results...
        cout << setw(NUMBER_FIELD_WIDTH) << formatTimeForOutput(mean) 
             << setw(NUMBER_FIELD_WIDTH) << formatTimeForOutput(stdDev) 
             << setw(NUMBER_FIELD_WIDTH) << formatTimeForOutput(max) 
             << endl;
    }
    
    // Reset values
    clear();
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - C++ Definitions, Privates
/////////////////////////////////////////////////////////////////////////

void MDTimeProfiler::calculateStats(vector<NSTimeInterval> &inVals, 
                                    NSTimeInterval &outMean, 
                                    NSTimeInterval &outStdDev, 
                                    NSTimeInterval &outMax)
{
    outMax = 0;
    
    // Sum and get the mean and the max...
    NSTimeInterval total = 0;
    for (size_t i=0; i<inVals.size(); i++) {
        
        total += inVals[i];
        
        if (inVals[i] > outMax) 
            outMax = inVals[i];
    }
    outMean = total / inVals.size();
    
    // Standard dev
    total = 0;
    for (size_t i=0; i<inVals.size(); i++) {
        total += (inVals[i] - outMean) * (inVals[i] - outMean);
    }
    total /= inVals.size();
    outStdDev = sqrt(total);
}

/////////////////////////////////////////////////////////////////////////

string MDTimeProfiler::formatTimeForOutput(NSTimeInterval t)
{
    if (t == 0) return "0";
    if (t < 0) throw out_of_range("Must be >= 0!");
    
    const char *suffices[] = {"s", "ms", "μs", "ns", "ps"};
    int i = -1;
    int mult = 1;
    while ( ++i < 5 and t * mult < 1.0 ) {
        mult *= 1000;
    }
    t *= mult;
    if (i == 5) i--;
    
    stringstream ss (stringstream::in | stringstream::out);
    ss << setprecision(2) << fixed << t << suffices[i];
    return ss.str();
}
