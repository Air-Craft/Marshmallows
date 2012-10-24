/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 16/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file MarhsmallowDebug.h

#ifndef Marshmallows_MarshmallowDebug_h
#define Marshmallows_MarshmallowDebug_h


/////////////////////////////////////////////////////////////////////////
#pragma mark - Variable dump macros
/////////////////////////////////////////////////////////////////////////

/** @name  md1 Variable dump macros */

// DLOG is almost a drop-in replacement for NSLog
// DLOG();
// DLOG(@"here");
// DLOG(@"value: %d", x);
// DLOGs(myNSString);
// DLOGi(myInt);
// DLOGvf("var name", myDoubleOrFloat)
#ifdef DEBUG
#	define DLOG(fmt, ...) NSLog((@"%s [L%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DLOGi(val) NSLog((@"%s [L%d] %i"), __PRETTY_FUNCTION__, __LINE__, (int)val);
#   define DLOGf(val) NSLog((@"%s [L%d] %f"), __PRETTY_FUNCTION__, __LINE__, (float)val);
#   define DLOGs(val) NSLog((@"%s [L%d] %@"), __PRETTY_FUNCTION__, __LINE__, val);
#   define DLOGvi(varname, val) NSLog((@"%s [L%d] %s=%i"), __PRETTY_FUNCTION__, __LINE__, varname, (int)val);
#   define DLOGvf(varname, val) NSLog((@"%s [L%d] %s=%f"), __PRETTY_FUNCTION__, __LINE__, varname, (float)val);
#   define DLOGvs(varname, val) NSLog((@"%s [L%d] %s=%@"), __PRETTY_FUNCTION__, __LINE__, varname, val);
#else
#	define DLOG(...)
#	define DLOGi(...)
#	define DLOGf(...)
#	define DLOGs(...)
#	define DLOGvi(...)
#	define DLOGvf(...)
#	define DLOGvs(...)
#endif

/// @}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Debug channel macros
/////////////////////////////////////////////////////////////////////////

/** @name  md2 Debug channel macros */

/*
 // Use these lines in your project to engage debug logging channels
 #define DEBUG_LOG_CHANNEL_1     0
 #define DEBUG_LOG_CHANNEL_2     0
 #define DEBUG_LOG_CHANNEL_3     0
 #define DEBUG_LOG_CHANNEL_4     0
 #define DEBUG_LOG_CHANNEL_5     0
 #define DEBUG_LOG_CHANNEL_6     0
 #define DEBUG_LOG_CHANNEL_7     1
 #define DEBUG_LOG_CHANNEL_8     1
 #define DEBUG_LOG_CHANNEL_9     1
 */

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_1) && DEBUG_LOG_CHANNEL_1 !=0
#   define DLOG1(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG1(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_2) && DEBUG_LOG_CHANNEL_2 != 0
#   define DLOG2(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG2(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_3) && DEBUG_LOG_CHANNEL_3 != 0
#   define DLOG3(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG3(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_4) && DEBUG_LOG_CHANNEL_4 != 0
#   define DLOG4(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG4(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_5) && DEBUG_LOG_CHANNEL_5 != 0
#   define DLOG5(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG5(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_6) && DEBUG_LOG_CHANNEL_6 != 0
#   define DLOG6(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG6(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_7) && DEBUG_LOG_CHANNEL_7 != 0
#   define DLOG7(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG7(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_8) && DEBUG_LOG_CHANNEL_8 != 0
#   define DLOG8(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG8(...)
#endif

#if defined(DEBUG) && defined(DEBUG_LOG_CHANNEL_9) && DEBUG_LOG_CHANNEL_9 != 0
#   define DLOG9(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG9(...)
#endif

/// @}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Marshmallow Debug Output Control
/////////////////////////////////////////////////////////////////////////
/** @name  md3 Marshmallow Debug Output Control 
 
    Extern constants for controlling internal log output.  Defaults to none but can be set in a separate linkage unit via the extern MarshmallowDebugLogLevel.  Constants are bitwise, ie you can have RealTime w/o Info and Details
 */


typedef enum {
    kMarshmallowDebugLogLevelNone = 0,
    kMarshmallowDebugLogLevelWarn = 1 << 0,
    kMarshmallowDebugLogLevelInfo = 1 << 1,
    kMarshmallowDebugLogLevelDetail = 1 << 2,
    kMarshmallowDebugLogLevelRealTime = 1 << 3,
    kMarshmallowDebugLogLevelAll = kMarshmallowDebugLogLevelWarn |
                                   kMarshmallowDebugLogLevelInfo |
                                   kMarshmallowDebugLogLevelDetail |
                                   kMarshmallowDebugLogLevelRealTime
} MarshmallowDebugLogLevelType;

extern MarshmallowDebugLogLevelType MarshmallowDebugLogLevel;



/**
 These are for internal use primarily
 */
#ifdef DEBUG
    #define MMLogWarn(fmt, ...) { \
        if (MarshmallowDebugLogLevel & kMarshmallowDebugLogLevelWarn) { \
            DLOG(@"[!! MM_WARN] " fmt, ##__VA_ARGS__);    \
        } \
    }

    #define MMLogInfo(fmt, ...) { \
        if (MarshmallowDebugLogLevel & kMarshmallowDebugLogLevelInfo) { \
            DLOG(@"[MM_INFO] " fmt, ##__VA_ARGS__);    \
        } \
    }

    #define MMLogDetail(fmt, ...) { \
        if (MarshmallowDebugLogLevel & kMarshmallowDebugLogLevelDetail) { \
            DLOG(@"[MM_DETAIL] " fmt, ##__VA_ARGS__);    \
        } \
    }

    #define MMLogRealTime(fmt, ...) { \
        if (MarshmallowDebugLogLevel & kMarshmallowDebugLogLevelRealTime) { \
            DLOG(@"[MM_REALTIME] " fmt, ##__VA_ARGS__);    \
        } \
    }
#else

#define MMLogWarn(fmt, ...)
#define MMLogInfo(fmt, ...)
#define MMLogDetail(fmt, ...)
#define MMLogRealTime(fmt, ...)

#endif


/// @}



#endif

/// @}