//
//  MMAppDelegate.m
//  Marshmallows
//
//  Created by Hari Karam Singh on 03/01/2012.
//  Copyright (c) 2012 Amritvela / Club 15CC.  MIT License.
//

#import "MMAppDelegate.h"
#import "AUMTesterViewController.h"
#import "AudioMarshmallows.h"

@implementation MMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"********* CAF ***********");
    AUM_printAvailableStreamFormatsForId(kAudioFileCAFType, kAudioFormatLinearPCM);
    AUM_printAvailableStreamFormatsForId(kAudioFileCAFType, kAudioFormatAppleIMA4);
    AUM_printAvailableStreamFormatsForId(kAudioFileCAFType, kAudioFormatAC3);
    AUM_printAvailableStreamFormatsForId(kAudioFileCAFType, kAudioFormatMPEG4AAC);
    AUM_printAvailableStreamFormatsForId(kAudioFileCAFType, kAudioFormatAppleLossless);
    
    NSLog(@"********* AIFF ***********");
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFFType, kAudioFormatLinearPCM);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFFType, kAudioFormatAppleIMA4);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFFType, kAudioFormatAC3);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFFType, kAudioFormatMPEG4AAC);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFFType, kAudioFormatAppleLossless);
    
    NSLog(@"********* M4A ***********");
    AUM_printAvailableStreamFormatsForId(kAudioFileM4AType, kAudioFormatLinearPCM);
    AUM_printAvailableStreamFormatsForId(kAudioFileM4AType, kAudioFormatAppleIMA4);
    AUM_printAvailableStreamFormatsForId(kAudioFileM4AType, kAudioFormatAC3);
    AUM_printAvailableStreamFormatsForId(kAudioFileM4AType, kAudioFormatMPEG4AAC);
    AUM_printAvailableStreamFormatsForId(kAudioFileM4AType, kAudioFormatAppleLossless);
    
    NSLog(@"********* AAC_ADTS ***********");
    AUM_printAvailableStreamFormatsForId(kAudioFileAAC_ADTSType, kAudioFormatLinearPCM);
    AUM_printAvailableStreamFormatsForId(kAudioFileAAC_ADTSType, kAudioFormatAppleIMA4);
    AUM_printAvailableStreamFormatsForId(kAudioFileAAC_ADTSType, kAudioFormatAC3);
    AUM_printAvailableStreamFormatsForId(kAudioFileAAC_ADTSType, kAudioFormatMPEG4AAC);
    AUM_printAvailableStreamFormatsForId(kAudioFileAAC_ADTSType, kAudioFormatAppleLossless);
    
    NSLog(@"********* AIFC ***********");
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFCType, kAudioFormatLinearPCM);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFCType, kAudioFormatAppleIMA4);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFCType, kAudioFormatAC3);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFCType, kAudioFormatMPEG4AAC);
    AUM_printAvailableStreamFormatsForId(kAudioFileAIFCType, kAudioFormatAppleLossless);

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[AUMTesterViewController alloc] initWithNibName:@"AUMTesterView" bundle:nil];
    
    [self.window makeKeyAndVisible];
    
    
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
