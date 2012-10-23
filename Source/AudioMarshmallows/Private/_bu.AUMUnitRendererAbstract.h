/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 23/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file AUMFilePlayerUnitRCB.h

#import <map>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MarshmallowDebug.h"

/**
 Mostly inlined class base for render callback containing classes.  Allows chaining analagous to AUUnits on an AUGraph and easy connection setup aided by renderCallbackStruct() property.
 
 To use, implement an AURenderCallback as a static method in the subclass and override renderCallbackStruct() to specify the AURenderCallbackStruct connecting the instance and the static method.
 */
class AUMUnitRendererAbstract
{
public:

    /** Return the RCB struct pointing the static RCB function and the instance to pass in as inRefCon */
    virtual const AURenderCallbackStruct renderCallbackStruct()=0;
    
    virtual const AudioStreamBasicDescription requiredStreamFormat()=0;
    
    
    void connectRendererToInput(AUMUnitRendererAbstract& outputRenderer, NSUInteger outputBus, NSUInteger inputBus);
    
    void connectRendererToOutput(AUMUnitRendererAbstract& inputRenderer, NSUInteger inputBus, NSUInteger outputBus);
    
    
protected:
    std::map<NSUInteger, AURenderCallbackStruct> _inputConnectionMap;
    std::map<NSUInteger, AURenderCallbackStruct> _outputConnectionMap;
    
    inline OSStatus _processInputConnections(AudioUnitRenderActionFlags  *ioActionFlags,
                                         const AudioTimeStamp        *inTimeStamp,
                                         UInt32                      inBusNumber,
                                         UInt32                      inNumberFrames,
                                         AudioBufferList             *ioData);

    inline OSStatus _processOutputConnections(AudioUnitRenderActionFlags  *ioActionFlags,
                                          const AudioTimeStamp        *inTimeStamp,
                                          UInt32                      inBusNumber,
                                          UInt32                      inNumberFrames,
                                          AudioBufferList             *ioData);
         
    
private:
    inline OSStatus _processConnectionsMap(std::map<NSUInteger, AURenderCallbackStruct> conxMap,
                                           AudioUnitRenderActionFlags  *ioActionFlags,
                                           const AudioTimeStamp        *inTimeStamp,
                                           UInt32                      inBusNumber,
                                           UInt32                      inNumberFrames,
                                           AudioBufferList             *ioData);
    
    /** The RCB for the FilePlayerUnit . Friend of AUMRendererAudioSource
     \param inRefCon    An instance of this class as set in the AUMFilePlayerUnit
     */
    static OSStatus renderCallback(void                        *inRefCon,
                                   AudioUnitRenderActionFlags  *ioActionFlags,
                                   const AudioTimeStamp        *inTimeStamp,
                                   UInt32                      inBusNumber,
                                   UInt32                      inNumberFrames,
                                   AudioBufferList             *ioData
                                   );
};

/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////

OSStatus AUMUnitRendererAbstract::_processInputConnections(AudioUnitRenderActionFlags *ioActionFlags,
                                                       const AudioTimeStamp *inTimeStamp,
                                                       UInt32 inBusNumber,
                                                       UInt32 inNumberFrames,
                                                       AudioBufferList *ioData)
{
    return _processConnectionsMap(_inputConnectionMap,
                                  ioActionFlags,
                                  inTimeStamp,
                                  inBusNumber,
                                  inNumberFrames,
                                  ioData);
}

/////////////////////////////////////////////////////////////////////////

OSStatus AUMUnitRendererAbstract::_processOutputConnections(AudioUnitRenderActionFlags *ioActionFlags,
                                                           const AudioTimeStamp *inTimeStamp,
                                                           UInt32 inBusNumber,
                                                           UInt32 inNumberFrames,
                                                           AudioBufferList *ioData)
{
    return _processConnectionsMap(_outputConnectionMap,
                                  ioActionFlags,
                                  inTimeStamp,
                                  inBusNumber,
                                  inNumberFrames,
                                  ioData);
}

/////////////////////////////////////////////////////////////////////////


OSStatus AUMUnitRendererAbstract::_processConnectionsMap(std::map<NSUInteger, AURenderCallbackStruct> conxMap, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    // Check bus
    for (auto p=conxMap.begin(); p!=conxMap.end(); ++p) {
        
        // Collect the vars from the conx
        UInt32 conxBus = (*p).first;
        AURenderCallbackStruct& rcbStruct = (*p).second;
        void *inRefCon = rcbStruct.inputProcRefCon;
        AURenderCallback rcbFunc = rcbStruct.inputProc;
        
        // Only process if bus matches
        if (inBusNumber != conxBus)
            continue;
        
        // Manually call the conx's RCB
        OSStatus res = rcbFunc(inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
        
        // Abort if error...
        if (res != noErr) return res;
        
    }
    
    return noErr;
}





/// @}