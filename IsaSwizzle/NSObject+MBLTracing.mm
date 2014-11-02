//
//  NSObject+Tracing.m
//  IsaSwizzle
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import "NSObject+MBLTracing.h"
#import "NSObject+MBLIsaSwizzle.h"

@interface MBLTracer : NSObject {
  
}
@end

@implementation MBLTracer : NSObject
@end

namespace {
NSString* const kTracingException = @"MBLTracingException";
}

@implementation NSObject (MBLTracing)

- (void)mbl_startTracing {
  if ([self mbl_hasCustomClass]) {
    [NSException raise:kTracingException format:@"[self mbl_hasCustomClass]"];
    return;
  }

  [self mbl_setClass:[MBLTracer class]];
}

- (void)mbl_endTracing {
  if (![self mbl_hasCustomClass]) {
    [NSException raise:kTracingException format:@"![self mbl_hasCustomClass]"];
    return;
  }

  [self mbl_restoreOriginalClass];
}

@end
