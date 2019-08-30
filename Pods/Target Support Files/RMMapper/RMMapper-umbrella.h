#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSObject+RMArchivable.h"
#import "NSObject+RMCopyable.h"
#import "NSUserDefaults+RMSaveCustomObject.h"
#import "RMMapper.h"

FOUNDATION_EXPORT double RMMapperVersionNumber;
FOUNDATION_EXPORT const unsigned char RMMapperVersionString[];

