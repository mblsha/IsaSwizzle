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
  NSLog(@"retain");
  return [super retain];
}

- (void)mbl_release {
  NSLog(@"release");
  [super release];
}

- (id)mbl_autorelease {
  NSLog(@"autorelease");
  return [super autorelease];
}

- (void)mbl_dealloc {
  NSLog(@"dealloc");
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
    std::map<SEL, const char*> selectors{
        {@selector(class), "@@:"},
        {@selector(retain), "@@:"},
        {@selector(release), "v@:"},
        {@selector(autorelease), "@@:"},
        {@selector(dealloc), "v@:"},
    };
    for (auto selector : selectors) {
      NSString* mbl_selectorName = [NSString
          stringWithFormat:@"mbl_%@", NSStringFromSelector(selector.first)];
      SEL mbl_selector = NSSelectorFromString(mbl_selectorName);

      IMP imp = class_getMethodImplementation([MBLTracer class], mbl_selector);
      // NB: watch out for type encodgng!
      class_addMethod(subclass, selector.first, imp, selector.second);
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
