#ifndef DEF_H_
#define DEF_H_

#include <MpinCoreLib/mpin_sdk_base.h>

#define RELEASE(pointer)  \
    if ((pointer) != NULL ) { \
        delete (pointer);    \
        (pointer) = NULL;    \
    } \

#define RELEASE_JNIREF(env , ref)  \
    if ((ref) != NULL ) { \
        (env)->DeleteGlobalRef((ref)); \
        (ref) = NULL;    \
    } \

/// input output parameter
#define IN
#define OUT

typedef MPinSDKBase::String String;
typedef MPinSDKBase::IContext IContext;
typedef MPinSDKBase::IHttpRequest IHttpRequest;
typedef MPinSDKBase::IStorage IStorage;
typedef MPinSDKBase::StringMap StringMap;
typedef IHttpRequest::Method Method;
typedef MPinSDKBase::CryptoType CryptoType;

static const String kEmptyString = "";
static const String kNegativeString = "-1";

/*
 * Macro to get the elements count in an array. Don't use it on zero-sized arrays
 */
#define ARR_LEN(x) ((int)(sizeof(x) / sizeof((x)[0])))

#endif /* DEF_H_ */
