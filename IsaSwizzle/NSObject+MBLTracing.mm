//
//  NSObject+Tracing.m
//  IsaSwizzle
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import "NSObject+MBLTracing.h"
#import "NSObject+MBLIsaSwizzle.h"
#import <objc/runtime.h>

#include <map>

@interface MBLTracer : NSObject {
}
@end

@implementation MBLTracer : NSObject
- (id)mbl_class {
  return [self mbl_originalClass];
}

- (id)mbl_retain {
  [self mbl_trace:@"retain"];
  return [super retain];
}

- (void)mbl_release {
  [self mbl_trace:@"release"];
  [super release];
}

- (id)mbl_autorelease {
  [self mbl_trace:@"autorelease"];
  return [super autorelease];
}

- (void)mbl_dealloc {
  [self mbl_trace:@"dealloc"];
  [super dealloc];
}

- (void)mbl_trace:(NSString*)message {
  NSLog(@"%@ %@\n%@", [self debugDescription], message,
        [NSThread callStackSymbols]);
}
@end

namespace {
NSString* const kTracingException = @"MBLTracingException";
const char* kTracingPrefix = "MBLTracing_";
}

@implementation NSObject (MBLTracing)

// copied from https://github.com/davedelong/CHLayoutManager/commit/8502777e6293d91bd4b9eb28c1034fcb16d66fd7#diff-723df1fcc7640170ab7827b75b66ccba
- (void)mbl_startTracing {
  if ([self mbl_hasCustomClass]) {
    [NSException raise:kTracingException format:@"[self mbl_hasCustomClass]"];
    return;
  }

  Class originalClass = [self class];
  NSString* className = NSStringFromClass(originalClass);
  if (strncmp(kTracingPrefix, [className UTF8String], strlen(kTracingPrefix)) ==
      0) {
    [NSException raise:kTracingException format:@"already has kTracingPrefix"];
    return;
  }

  NSString* subclassName =
      [NSString stringWithFormat:@"%s%@", kTracingPrefix, className];
  Class subclass = NSClassFromString(subclassName);

  if (subclass == nil) {
    subclass =
        objc_allocateClassPair(originalClass, [subclassName UTF8String], 0);
    NSAssert(subclass != nil, @"subclass != nil");

    // v@: -- void (id self, SEL _cmd)
    std::map<SEL, std::pair<SEL, const char*>> selectors{
        {@selector(class), {@selector(mbl_class), "@@:"}},
        {@selector(retain), {@selector(mbl_retain), "@@:"}},
        {@selector(release), {@selector(mbl_release), "v@:"}},
        {@selector(autorelease), {@selector(mbl_autorelease), "@@:"}},
        {@selector(dealloc), {@selector(mbl_dealloc), "v@:"}},

        {@selector(mbl_trace:), {@selector(mbl_trace:), "v@:@"}},
    };
    for (auto i : selectors) {
      SEL selector = i.first;
      SEL mbl_selector = i.second.first;
      const char* typeEncoding = i.second.second;

      IMP imp = class_getMethodImplementation([MBLTracer class], mbl_selector);
      class_addMethod(subclass, selector, imp, typeEncoding);
    }

    objc_registerClassPair(subclass);
  }

  NSAssert(subclass != nil, @"subclass != nil");
  [self mbl_setClass:subclass];
}

- (void)mbl_endTracing {
  if (![self mbl_hasCustomClass]) {
    [NSException raise:kTracingException format:@"![self mbl_hasCustomClass]"];
    return;
  }

  [self mbl_restoreOriginalClass];
}

@end
