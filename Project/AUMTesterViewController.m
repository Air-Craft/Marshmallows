/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 20/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "AUMTesterViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MarshmallowDebug.h"
#import "MarshmallowConcurrency.h"
#import "AudioMarshmallows.h"
#import "MarshmallowCocoa.h"

@implementation AUMTesterViewController
{
    AUMGraph *_aumGraph;
    AUMFilePlaybackGenerator *_aumFPU1;
    AUMFilePlaybackGenerator *_aumFPU2;
    AUMMultichannelMixerUnit *_aumMixer;
    AUMRemoteIOUnit *_aumOutputUnit;
    
    AUMFileRecordingProcessor *_aumRecorder;
    

    __weak IBOutlet UISlider *_track1SeekSlider;
    __weak IBOutlet UISlider *_track2SeekSlider;
    __weak IBOutlet UISwitch *_track2PlaySwitch;
    __weak IBOutlet UISwitch *_recordSwitch;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MarshmallowDebugLogLevel = kMarshmallowDebugLogLevelAll;
    
    @try {
        /////////////////////////////////////////
        // AUDIO SESSION SETUP
        /////////////////////////////////////////
        
        [AUMAudioSession setPreferredHardwareSampleRate: 44100.0];
        [AUMAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord];
        [AUMAudioSession setPreferredIOBufferDuration:0.005];
        [AUMAudioSession setMixWithOthers:YES];
        NSTimeInterval sampleRate = 0;;
        sampleRate = AUMAudioSession.currentHardwareSampleRate;
        NSTimeInterval ioBufferDuration = 0;
        ioBufferDuration = AUMAudioSession.IOBufferDuration;
        
        DLOG("SR & IO Buffer: %f %f", sampleRate, ioBufferDuration);
        
        
        /////////////////////////////////////////
        // CONTROL THREAD
        /////////////////////////////////////////
        
        MPerformanceThread *thd = [MPerformanceThread thread];
        thd.timingResolution = 0.0005;
        
        /////////////////////////////////////////
        // AU GRAPH SETUP
        /////////////////////////////////////////
        
        _aumGraph = [[AUMGraph alloc] init];
        
        _aumMixer = [[AUMMultichannelMixerUnit alloc] init];
        [_aumGraph addUnit:_aumMixer];
        
        _aumOutputUnit = [[AUMRemoteIOUnit alloc] init];
        [_aumGraph addUnit:_aumOutputUnit];

        _aumFPU1 = [[AUMFilePlaybackGenerator alloc] initWithDiskBufferSizeInBytes:128*1024 updateThread:thd updateInterval:0.25];
        _aumFPU2 = [[AUMFilePlaybackGenerator alloc] initWithDiskBufferSizeInBytes:128*1024 updateThread:thd updateInterval:0.25];
        
        _aumRecorder = [[AUMFileRecordingProcessor alloc] init];
        
        // Link up...
        [_aumGraph connectOutputBus:0 ofUnit:_aumMixer toInputBus:0 ofUnit:_aumOutputUnit];
        _aumMixer.inputBusCount = 2;
        [_aumMixer attachGenerator:_aumFPU1 toInputBus:0];
        [_aumMixer attachGenerator:_aumFPU2 toInputBus:1];
        
        [_aumOutputUnit addProcessor:_aumRecorder];
        
        //kAUGraphErr_OutputNodeErr
        
        // Stereo pan
        [_aumGraph initialize];
        
        
        /////////////////////////////////////////
        // PREPARE AUDIO FILES
        /////////////////////////////////////////

        // Load the file
        //        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SWHarp-C3-Medium" withExtension:@"wav"];
        NSURL *file1URL = [[NSBundle mainBundle] URLForResource:@"Bach-Great-Organ-Works-1" withExtension:@"mp3"];
        NSURL *file2URL = [[NSBundle mainBundle] URLForResource:@"SWHarp-Eb4-Medium" withExtension:@"wav"];
        NSURL *outFileURL = [NSURL URLForDocumentDirectoryWithAppendedPath:@"something.caf"];
        DLOGs(outFileURL);
        
        [_aumFPU1 loadAudioFileFromURL:file1URL];
        [_aumFPU2 loadAudioFileFromURL:file2URL];
        
        _aumFPU2.cbPlaybackDidOccur = ^(id sender, NSUInteger frame, NSTimeInterval time) {
            DLOG(@"Playing frame %u at time %.2f", frame, time);
        };
        
//        __weak id wSelf = self;
        _aumFPU2.cbPlaybackFinished = ^(AUMFilePlaybackGenerator *sender){
          if (!sender.loop) {
                [_track2PlaySwitch setOn:NO animated:YES];
            }
        };
        
        [_aumRecorder newOutputFileWithURL:outFileURL withFileFormat:kAUMFileFormat_CAF_IMA4_Stereo_SoftwareCodec];
        [_aumRecorder queue];
        
        /////////////////////////////////////////
        // PLAY!
        /////////////////////////////////////////
        
        [AUMAudioSession setActive:YES];
        [thd start];
        [_aumGraph start];

        
        [_aumFPU1 play];
        
        
    } @catch (AUMException *e) {
        DLOGs(e);
        DLOGi(e.OSStatus);
        DLOGs(e.OSStatusAsNSString);
        
        if (e.name == kAUMAudioSessionException) {
            
        } else if (e.name == kAUMAudioUnitException) {
            
        } else if (e.name == kAUMAudioFileException) {
            
        }
    }    

}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Track 1
/////////////////////////////////////////////////////////////////////////

- (IBAction)volume1Changed:(UISlider *)sender
{
    _aumFPU1.volume = sender.value;
}
- (IBAction)pan1Changed:(UISlider *)sender {
    [_aumMixer setPan:sender.value onBus:0];
}
- (IBAction)playhead1Slid:(UISlider *)sender
{
    static NSDate *prevNow;
    if (!prevNow) prevNow = [NSDate date];
    
    NSDate *now = [NSDate date];
    if ([now timeIntervalSinceDate:prevNow] < 0.5) {
        return;
    }
    
    prevNow = now;
    
    NSUInteger toFrame = sender.value * (_aumFPU1.audioFileLengthInFrames - 1);
    MMLogInfo(@"Updating playhead #1 to frame %u", toFrame);
    [_aumFPU1 seekToFrame:toFrame];
}

- (IBAction)playhead1ChangeDone:(UISlider *)sender {
    NSUInteger toFrame = sender.value * (_aumFPU1.audioFileLengthInFrames - 1);
    MMLogInfo(@"Updating playhead #1 to frame %u [final]", toFrame);
    [_aumFPU1 seekToFrame:toFrame];

}
/////////////////////////////////////////////////////////////////////////
#pragma mark - Track 2
/////////////////////////////////////////////////////////////////////////

- (IBAction)volume2Changed:(UISlider *)sender
{
    [_aumMixer setVolume:sender.value onBus:1];
}
- (IBAction)pan2Changed:(UISlider *)sender {
    [_aumMixer setPan:sender.value onBus:1];
}
- (IBAction)playhead2Slid:(UISlider *)sender
{
    static NSDate *prevNow;
    if (!prevNow) prevNow = [NSDate date];
    
    NSDate *now = [NSDate date];
    if ([now timeIntervalSinceDate:prevNow] < 0.5) {
        return;
    }
    
    prevNow = now;
    
    NSUInteger toFrame = sender.value * (_aumFPU2.audioFileLengthInFrames - 1);
    MMLogInfo(@"Updating playhead #2 to frame %u", toFrame);
    [_aumFPU2 seekToFrame:toFrame];
}
- (IBAction)playhead2ChangeDone:(UISlider *)sender {
    NSUInteger toFrame = sender.value * (_aumFPU2.audioFileLengthInFrames - 1);
    MMLogInfo(@"Updating playhead #2 to frame %u [final]", toFrame);
    [_aumFPU2 seekToFrame:toFrame];
}

- (IBAction)track2PlayStateChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [_aumFPU2 play];
    } else {
        [_aumFPU2 stop];
    }
}

- (IBAction)track2LoopStateChanged:(UISwitch *)sender {
    _aumFPU2.loop = sender.isOn;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Recording
/////////////////////////////////////////////////////////////////////////

- (IBAction)recordingStateChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [_aumRecorder record];
    } else {
        [_aumRecorder stop];
    }
}

- (IBAction)queueRecordedTrackOntoTrack2
{
    [_aumRecorder stop];
    [_aumFPU1 stop];
    [_aumFPU2 stop];
    
    [_recordSwitch setOn:NO animated:YES];
    [_track2PlaySwitch setOn:NO animated:YES];
    [_track2SeekSlider setValue:0 animated:YES];
    
    [_aumFPU2 loadAudioFileFromURL:_aumRecorder.outputFileURL];
    DLOG("RECORDING ==> TRACK 2");
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Misc
/////////////////////////////////////////////////////////////////////////




- (void)viewDidUnload
{
    _track2PlaySwitch = nil;
    _recordSwitch = nil;
    _track1SeekSlider = nil;
    _track2SeekSlider = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

///@}