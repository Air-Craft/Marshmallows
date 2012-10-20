//
//  MMAppDelegate.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 03/01/2012.
//  Copyright (c) 2012 Amritvela / Club 15CC.  MIT License.
//

#import <AVFoundation/AVFoundation.h>
#import "MMAppDelegate.h"
#import "MarshmallowDebug.h"
#import "MarshmallowConcurrency.h"
#import "AudioMarshmallows.h"
#import "MarshmallowCocoa.h"


@implementation MMAppDelegate
{
    AUMGraph *_aumGraph;
    AUMFilePlayerUnit *_aumFPU;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
        @try {
            sampleRate = AUMAudioSession.currentHardwareSampleRate;
        } @catch (NSException *e) {
            ;
        }
        NSTimeInterval ioBufferDuration = 0;
        @try {
            ioBufferDuration = AUMAudioSession.IOBufferDuration;
        } @catch (NSException *e) {
            ;
        }
        
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
        
        [thd start];
        
        // Load the file
//        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SWHarp-C3-Medium" withExtension:@"wav"];
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"OngKarNirankar" withExtension:@"m4a"];
        
        DLOGs(fileURL);
        [_aumFPU loadAudioFileFromURL:fileURL];
        
        [_aumGraph addUnit:_aumFPU];
        [_aumGraph initialize];
        [AUMAudioSession setActive:YES];
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
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
