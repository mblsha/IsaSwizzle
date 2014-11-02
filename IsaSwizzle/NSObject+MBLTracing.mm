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

@interface MBLTracer : NSObject {
}
@end

@implementation MBLTracer : NSObject
- (id)mbl_class {
  return [self mbl_originalClass];
}

- (void)mbl_dealloc {
  NSLog(@"dealloc");
  [super dealloc];
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
    
    IMP dealloc = class_getMethodImplementation([MBLTracer class],
                                                @selector(mbl_dealloc));
    class_addMethod(subclass, @selector(dealloc), dealloc, "v@:");

    IMP klass = class_getMethodImplementation([MBLTracer class],
                                                @selector(mbl_class));
    class_addMethod(subclass, @selector(class), klass, "v@:");

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
