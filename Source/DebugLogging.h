#define DEBUG_LOG_CHANNEL_1     0       // General info about goings on...
#define DEBUG_LOG_CHANNEL_2     0       // PluckDetector nitty-gritty
#define DEBUG_LOG_CHANNEL_3     0       // AudioEngine nitty-gritty (high detail!)
#define DEBUG_LOG_CHANNEL_4     0       // SamplerEngine Info
#define DEBUG_LOG_CHANNEL_5     0       // InstrumentView
#define DEBUG_LOG_CHANNEL_6     0       // SWInstrumentPlayController
#define DEBUG_LOG_CHANNEL_7     1
#define DEBUG_LOG_CHANNEL_8     1
#define DEBUG_LOG_CHANNEL_9     1


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



#if defined(DEBUG_LOG_CHANNEL_1) && DEBUG_LOG_CHANNEL_1 !=0
#   define DLOG1(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG1(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_2) && DEBUG_LOG_CHANNEL_2 != 0
#   define DLOG2(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG2(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_3) && DEBUG_LOG_CHANNEL_3 != 0
#   define DLOG3(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG3(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_4) && DEBUG_LOG_CHANNEL_4 != 0
#   define DLOG4(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG4(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_5) && DEBUG_LOG_CHANNEL_5 != 0
#   define DLOG5(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG5(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_6) && DEBUG_LOG_CHANNEL_6 != 0
#   define DLOG6(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG6(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_7) && DEBUG_LOG_CHANNEL_7 != 0
#   define DLOG7(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG7(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_8) && DEBUG_LOG_CHANNEL_8 != 0
#   define DLOG8(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG8(...)
#endif

#if defined(DEBUG_LOG_CHANNEL_9) && DEBUG_LOG_CHANNEL_9 != 0
#   define DLOG9(fmt, ...)      DLOG(fmt, ##__VA_ARGS__)
#else
#   define DLOG9(...)
#endif
