/**
 \addtogroup Marshmallows
 \author     Created by Hari Karam Singh on 14/08/2012.
 \copyright  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 @{
 */
/// \file MCAtomicType.h

#ifndef MM_ATOMIC_TYPE
#define MM_ATOMIC_TYPE 1

#import <libkern/OSAtomic.h>


namespace Marshmallow
{
    
    /////////////////////////////////////////////////////////////////////////
    #pragma mark - AtomicType32
    /////////////////////////////////////////////////////////////////////////
    /**
     Create POD-like vars and propertes in C++ which use an OSAtomic setting plus memory barrier for time-critical thread safe applications.  Note, assignment of primitives combined with declaration doesnt work at the mo'.  Just declare, then assign.
     */
    template <typename T> class AtomicType32
    {
    public:
        AtomicType32(T v=0) { _val = *( (int32_t *)&v ); };
        ~AtomicType32() {};

        /////////////////////////////////////////////////////////////////////////

        /** Copy constructor  (for AtomicType32<T> x = anotherAtomicType32) */
        AtomicType32<T>(const AtomicType32<T>& t)
        {
            *this = t;
        };

        /////////////////////////////////////////////////////////////////////////
        
        /** Primitive assignment operator (eg. myAtomicVar = 5) */
        inline AtomicType32<T>& operator=(const T& val)
        {
            // Cast to internal int type
            int32_t tmp = *( (int32_t *)&val );
            
            // Update our property
            int c = -1;
            while (not OSAtomicCompareAndSwap32Barrier(_val, tmp, &_val)) {
                if (c++ > 10000) {
                    [NSException raise:NSInternalInconsistencyException format:@"Atomic op not completed in %i attempts", c];
                };
            }
            
            return *this;
        };

        /////////////////////////////////////////////////////////////////////////
        
        /** Object assignment operator (eg. myAtomicVar = anotherAtomicType) */
        inline AtomicType32<T>& operator=(const AtomicType32<T>& obj)
        {
            *this = T(obj);
            return *this;
        };

        
        /////////////////////////////////////////////////////////////////////////
        
        /** Casting operator to the type T */
        inline operator T() const
        {
            return _toType();
        };

        /////////////////////////////////////////////////////////////////////////
        
        inline T operator+=(int arg)
        {
            *this = *this + arg;
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator-=(int arg)
        {
            *this = *this - arg;
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator++(void)
        {
            *this = *this + T(1);
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator--(void)
        {
            *this = *this - T(1);
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
    protected:
        int32_t _val;
        
        inline const T _toType() const { return *( (T *)&_val ); }
    };



    /////////////////////////////////////////////////////////////////////////
    #pragma mark - AtomicType64
    /////////////////////////////////////////////////////////////////////////

    /**
     Same as 32 type but witih 64 bit interval storage
     */
    template <typename T> class AtomicType64
    {
    public:
        AtomicType64(T v=0) { _val = *( (int64_t *)&v ); };
        ~AtomicType64() {};
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Copy constructor  (for AtomicType32<T> x = anotherAtomicType32) */
        AtomicType64<T>(const AtomicType32<T>& t)
        {
            *this = t;
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Primitive assignment operator (eg. myAtomicVar = 5) */
        inline AtomicType64<T>& operator=(const T& val)
        {
            // Cast to internal int type
            int64_t tmp = *( (int64_t *)&val );
            
            // Update our property
            int c = -1;
            while (not OSAtomicCompareAndSwap32Barrier(_val, tmp, &_val)) {
                if (c++ > 10000) {
                    [NSException raise:NSInternalInconsistencyException format:@"Atomic op not completed in %i attempts", c];
                };
            }
            
            return *this;
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Object assignment operator (eg. myAtomicVar = anotherAtomicType) */
        inline AtomicType64<T>& operator=(const AtomicType64<T>& obj)
        {
            *this = T(obj);
            return *this;
        };
        
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Casting operator to the type T */
        inline operator T() const
        {
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator+=(int arg)
        {
            *this = *this + arg;
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator-=(int arg)
        {
            *this = *this - arg;
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator++(void)
        {
            *this = *this + T(1);
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        inline T operator--(void)
        {
            *this = *this - T(1);
            return _toType();
        };
        
        /////////////////////////////////////////////////////////////////////////
        
    protected:
        int64_t _val;
        
        inline const T _toType() const { return *( (T *)&_val ); }
    };

    /////////////////////////////////////////////////////////////////////////
    #pragma mark - AtomicBool
    /////////////////////////////////////////////////////////////////////////

    /**
     
     */
    class AtomicBool
    {
    public:
        AtomicBool(bool v=false) { int32_t bInt = v; _val = *( (int32_t *)&bInt ); };   // Cast to 32bit size first as bool is likely to be smaller
        ~AtomicBool() {};
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Copy constructor  (for AtomicType32<T> x = anotherAtomicType32) */
        AtomicBool(const AtomicBool& t)
        {
            *this = t;
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Primitive assignment operator (eg. myAtomicVar = 5) */
        inline AtomicBool& operator=(const bool& val)
        {
            // Explcit conversion to 0/1 to prevent size issues
            int32_t intVal = int32_t(val);
            
            // Update our property
            int c = -1;
            while (not OSAtomicCompareAndSwap32Barrier(_val, intVal, &_val)) {
                if (c++ > 10000) {
                    [NSException raise:NSInternalInconsistencyException format:@"Atomic op not completed in %i attempts", c];
                };
            }
            
            return *this;
        };
        
        /////////////////////////////////////////////////////////////////////////
        
        /** Object assignment operator (eg. myAtomicVar = anotherAtomicType) */
        inline AtomicBool& operator=(const AtomicBool& obj)
        {
            *this = bool(obj);
            return *this;
        };
        
        /////////////////////////////////////////////////////////////////////////

        /** Casting operator to the type bool */
        inline operator bool() const { return _toType(); };

        
        /////////////////////////////////////////////////////////////////////////

        // Should really disallow the other operators

    protected:
        int32_t _val;
        
        inline const bool _toType() const
        {
            return bool(_val);
        }
    };


    /////////////////////////////////////////////////////////////////////////
    #pragma mark - Convenience Typedefs 
    /////////////////////////////////////////////////////////////////////////

    typedef AtomicType32<Float32> AtomicFloat32;
    typedef AtomicType64<Float64> AtomicFloat64;
    typedef AtomicType32<UInt32> AtomicInt32;
    typedef AtomicType32<UInt64> AtomicInt64;
    typedef AtomicType32<UInt32> AtomicUInt32;
    typedef AtomicType32<UInt64> AtomicUInt64;


    #endif

}

/// @}