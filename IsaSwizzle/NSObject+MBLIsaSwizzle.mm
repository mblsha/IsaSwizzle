//
//  NSObject+IsaSwizzle.m
//  IsaSwizzle
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

// copied from https://github.com/macmade/Code-Tests/blob/master/Objective-C/isa-swizzle.m

#import "NSObject+MBLIsaSwizzle.h"

#import <objc/runtime.h>

namespace {
  NSString* const kAssocKey = @"ISASwizzle_NSObject_SetClass";
  NSString* const kAssocKeyOriginalClass = @"ISASwizzle_NSObject_OriginalClass";
  NSString* const kAssocKeyClasses = @"ISASwizzle_NSObject_Classes";
}

@implementation NSObject (MBLISASwizzle)
- (void)mbl_setClass:(Class)cls {
  NSMutableDictionary* infos = objc_getAssociatedObject(self, kAssocKey);
  if (infos == nil) {
    infos = [[@{
                kAssocKeyOriginalClass : [self class],
                kAssocKeyClasses : [NSMutableArray arrayWithCapacity:10]
                } mutableCopy] autorelease];

    objc_setAssociatedObject(self, kAssocKey, infos, OBJC_ASSOCIATION_RETAIN);
  }

  NSMutableArray* classes = [infos objectForKey:kAssocKeyClasses];
  Class originalClass = [infos objectForKey:kAssocKeyOriginalClass];

  if (classes.count > 0 || object_getClass(self) != originalClass) {
    [classes addObject:object_getClass(self)];
  }

  object_setClass(self, cls);
}

- (Class)mbl_originalClass {
  NSMutableDictionary* infos = objc_getAssociatedObject(self, kAssocKey);
  if (infos == nil) {
    return object_getClass(self);
  }

  Class originalClass = [infos objectForKey:kAssocKeyOriginalClass];
  if (originalClass == nil) {
    return object_getClass(self);
  }

  return originalClass;
}

- (void)mbl_restoreClass {
  NSMutableDictionary* infos = objc_getAssociatedObject(self, kAssocKey);
  if (infos == nil) {
    return;
  }

  NSMutableArray* classes = [infos objectForKey:kAssocKeyClasses];
  Class originalClass = [infos objectForKey:kAssocKeyOriginalClass];

  if (classes.count == 0) {
    object_setClass(self, originalClass);
  } else if (classes.count == 0) {
    object_setClass(self, originalClass);
  } else {
    object_setClass(self, [classes lastObject]);

    [classes removeLastObject];
  }
}

- (void)mbl_restoreOriginalClass {
  NSMutableDictionary* infos = objc_getAssociatedObject(self, kAssocKey);
  if (infos == nil) {
    return;
  }

  NSMutableArray* classes = [infos objectForKey:kAssocKeyClasses];
  Class originalClass = [infos objectForKey:kAssocKeyOriginalClass];
  [classes removeAllObjects];

  object_setClass(self, originalClass);
}

- (BOOL)mbl_hasCustomClass {
  NSMutableDictionary* infos = objc_getAssociatedObject(self, kAssocKey);
  if (infos == nil) {
    return NO;
  }

  NSMutableArray* classes = [infos objectForKey:kAssocKeyClasses];
  Class originalClass = [infos objectForKey:kAssocKeyOriginalClass];

  if (classes.count > 0 && [classes lastObject] != originalClass) {
    return YES;
  } else if (object_getClass(self) != originalClass) {
    return YES;
  }
  
  return NO;
}
@end
