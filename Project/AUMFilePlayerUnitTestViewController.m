/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 20/10/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */

#import "AUMFilePlayerUnitTestViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MarshmallowDebug.h"
#import "MarshmallowConcurrency.h"
#import "AudioMarshmallows.h"
#import "MarshmallowCocoa.h"

@implementation AUMFilePlayerUnitTestViewController
{
    AUMGraph *_aumGraph;
    AUMFilePlayerUnit *_aumFPU;
    __weak IBOutlet UISlider *playhead1Slider;
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
        [AUMAudioSession setCategory:AVAudioSessionCategoryPlayback];
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
        
        MCSimpleThreadProxy *thd = [[MCSimpleThreadProxy alloc] init];
        
        
        /////////////////////////////////////////
        // AU GRAPH SETUP
        /////////////////////////////////////////
        
        _aumGraph = [[AUMGraph alloc] init];
        _aumFPU = [[AUMFilePlayerUnit alloc] initWithDiskBufferSizeInFrame:32*1024 updateThread:thd updateInterval:0.25];
        
        // Load the file
        //        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SWHarp-C3-Medium" withExtension:@"wav"];
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"OngKarNirankar" withExtension:@"m4a"];
        
        DLOGs(fileURL);
        [_aumFPU loadAudioFileFromURL:fileURL];
        [_aumGraph addUnit:_aumFPU];
        [_aumGraph initialize];
        
        
        /////////////////////////////////////////
        // UI SETUP
        /////////////////////////////////////////
        playhead1Slider.minimumValue = 0;
        playhead1Slider.maximumValue = _aumFPU.audioFileLengthInFrames-10;
        playhead1Slider.value = 0;
        MMLogInfo(@"FILE LENGTH %u", _aumFPU.audioFileLengthInFrames);
        
        /////////////////////////////////////////
        // PLAY!
        /////////////////////////////////////////
        
        [AUMAudioSession setActive:YES];
        [thd start];
        [_aumGraph start];
        
        [_aumFPU play];
        
        
    } @catch (AUMException *e) {
        DLOGs(e);
        DLOGs(e.OSStatusAsNSString);
        
        if (e.name == kAUMAudioSessionException) {
            
        } else if (e.name == kAUMAudioUnitException) {
            
        } else if (e.name == kAUMAudioFileException) {
            
        }
    }    

}


- (IBAction)volume1Changed:(UISlider *)sender
{
    _aumFPU.volume = sender.value;
}

- (IBAction)playhead1Changed:(UISlider *)sender
{
    MMLogInfo(@"Updating playhead #1 to frame %u", (NSUInteger)sender.value);
    [_aumFPU seekToFrame:(NSUInteger)sender.value];
}


- (void)viewDidUnload
{
    playhead1Slider = nil;
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