/** 
 \addtogroup Marshmallows
 \author     Created by  on 24/03/2012.
 \copyright  Copyright (c) 2012 Club 15CC. All rights reserved.
 @{ 
 */

#import "MRUncaughtExceptions.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Forward declarations
/////////////////////////////////////////////////////////////////////////

/// We need C funcs to install the exception handling.  These wrap the ObjC class methods which in turn wrap the block.
void MRUE_SignalHandler(int signal);
void MRUE_HandleException(NSException *exception);


/////////////////////////////////////////////////////////////////////////
#pragma mark - Consts
/////////////////////////////////////////////////////////////////////////

/// Externs
NSString * const MRUncaughtExceptionSignalException = @"MRUncaughtExceptionSignalException";
NSString * const kMRUncaughtExceptionsSignalKey = @"kMRUncaughtExceptionsSignalKey";
NSString * const kMRUncaughtExceptionsAddressesKey = @"kMRUncaughtExceptionsAddressesKey";


/// Internal
/// Skip the first number of backtraces and report the second number more.  
static const NSInteger MRUESkipAddressCount = 7;
static const NSInteger MRUEReportAddressCount = 10;
static BOOL MRUEAlertViewDismissed = NO;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Static "Class" vars
/////////////////////////////////////////////////////////////////////////

static volatile int32_t MRUncaughtExceptionsCount = 0;
static int32_t MRUncaughtExceptionsMaximum = 5;
static MRUncaughtExceptionsBlock MRUncaughtExceptionsBlockHandler = nil;


/////////////////////////////////////////////////////////////////////////
#pragma mark - MRSUncaughtExceptions()
/////////////////////////////////////////////////////////////////////////
/**
 \private
 */
@interface MRUncaughtExceptions()

+ (void)processNormalException:(NSException *)exception;
+ (void)processSignalException:(int)signal;
+ (void)processExceptionCommon:(NSException *)exception;
+ (NSArray *)backtrace;

@end


/////////////////////////////////////////////////////////////////////////
#pragma mark - MRUncaughtExceptions
/////////////////////////////////////////////////////////////////////////

@implementation MRUncaughtExceptions

+ (void)installHandlerBlock:(MRUncaughtExceptionsBlock)handlerBlock 
{
    MRUncaughtExceptionsBlockHandler = handlerBlock;
    
    NSSetUncaughtExceptionHandler(&MRUE_HandleException);
	signal(SIGABRT, MRUE_SignalHandler);
	signal(SIGILL, MRUE_SignalHandler);
	signal(SIGSEGV, MRUE_SignalHandler);
	signal(SIGFPE, MRUE_SignalHandler);
	signal(SIGBUS, MRUE_SignalHandler);
	signal(SIGPIPE, MRUE_SignalHandler);
    
}

/////////////////////////////////////////////////////////////////////////

+ (void)setUncaughtExceptionMaximum:(NSUInteger)max
{
    MRUncaughtExceptionsMaximum = max;
}

/////////////////////////////////////////////////////////////////////////

+ (void)processNormalException:(NSException *)exception
{
    // Prevent exception abuse
    int32_t exceptionCount = OSAtomicIncrement32(&MRUncaughtExceptionsCount);
	if (exceptionCount > MRUncaughtExceptionsMaximum) {
		return;
	}

    [[self class] performSelectorOnMainThread:@selector(processExceptionCommon:) withObject:exception waitUntilDone:YES];
}

/////////////////////////////////////////////////////////////////////////

+ (void)processSignalException:(int)signal
{
    int32_t exceptionCount = OSAtomicIncrement32(&MRUncaughtExceptionsCount);
	if (exceptionCount > MRUncaughtExceptionsMaximum) {
		return;
	}
    
    // Create an exception with the signal info
    NSException *exception = [NSException 
                              exceptionWithName:MRUncaughtExceptionSignalException
                              reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil), signal]
                              userInfo:[NSDictionary
                                       dictionaryWithObject:[NSNumber numberWithInt:signal]
                                       forKey:kMRUncaughtExceptionsSignalKey] 
                             ];
    
    [[self class] performSelectorOnMainThread:@selector(processExceptionCommon:) withObject:exception waitUntilDone:YES];
}

/////////////////////////////////////////////////////////////////////////

+ (void)processExceptionCommon:(NSException *)exception
{
    // No block?  What to do?  Throw an exception!
    if (!MRUncaughtExceptionsBlockHandler) {
        @throw exception;
    }
    
    // Add the backtrack to the userInfo dict
    NSArray *callStack = [MRUncaughtExceptions backtrace];
	NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
     setObject:callStack
     forKey:kMRUncaughtExceptionsAddressesKey];
	
    // And call block on the main thread
    //dispatch_sync(dispatch_get_main_queue(), ^{
        MRUncaughtExceptionsBlockHandler([NSException
                                          exceptionWithName:[exception name]
                                          reason:[exception reason]
                                          userInfo:userInfo]);
   // });
}

/////////////////////////////////////////////////////////////////////////

+ (void)handleExceptionWithAlertView:(NSException *)exception
{
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
     message:[NSString stringWithFormat:NSLocalizedString(
                                                          @"You can try to continue but the application may be unstable.\n\n"
                                                          @"Debug details follow:\n%@\n%@", nil),
              [exception reason],
              [[exception userInfo] objectForKey:kMRUncaughtExceptionsAddressesKey]]
     delegate:self
     cancelButtonTitle:NSLocalizedString(@"Quit", nil)
     otherButtonTitles:NSLocalizedString(@"Continue", nil), nil];
	[alert show];
	
    
    // Keep turning the crank on the run loop for the alert view
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
	while (!MRUEAlertViewDismissed)
	{
		for (NSString *mode in (__bridge NSArray *)allModes)
		{
			CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
		}
	}
	CFRelease(allModes);
    
    [self rethrowException:exception];
}

/////////////////////////////////////////////////////////////////////////

/// Delegate for the alert view
+ (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
		MRUEAlertViewDismissed = YES;
	}
}

/////////////////////////////////////////////////////////////////////////

+ (void)rethrowException:(NSException *)exception
{
    // Deregister exception handler and 
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	
	if ([[exception name] isEqual:MRUncaughtExceptionSignalException])
	{
		kill(getpid(), [[[exception userInfo] objectForKey:kMRUncaughtExceptionsSignalKey] intValue]);
	}
	else
	{
		[exception raise];
	}

}

/////////////////////////////////////////////////////////////////////////

/// Many thank to Matt Gallagher, UncaughtExceptionHandler
+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    int start = MRUESkipAddressCount >= frames ? frames - 1 : MRUESkipAddressCount;
    int stop = start + MRUEReportAddressCount;
    stop = stop > frames ? frames : stop;
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:stop - start];

    for (i = start; i < stop; i++) {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

@end


/////////////////////////////////////////////////////////////////////////
#pragma mark - Internal Functions
/////////////////////////////////////////////////////////////////////////

void MRUE_HandleException(NSException *exception)
{
    [MRUncaughtExceptions processNormalException:exception];
}

void MRUE_SignalHandler(int signal)
{
	[MRUncaughtExceptions processSignalException:signal];
}



/// @}