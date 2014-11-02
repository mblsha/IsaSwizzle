// copied from https://github.com/macmade/Code-Tests/blob/master/Objective-C/isa-swizzle.m

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (ISASwizzle)
- (void)setClass:(Class)cls;
- (Class)originalClass;
- (void)restoreClass;
- (void)restoreOriginalClass;
- (BOOL)hasCustomClass;
@end

namespace {
NSString* const kAssocKey = @"ISASwizzle_NSObject_SetClass";
NSString* const kAssocKeyOriginalClass = @"ISASwizzle_NSObject_OriginalClass";
NSString* const kAssocKeyClasses = @"ISASwizzle_NSObject_Classes";
}

@implementation NSObject (ISASwizzle)
- (void)setClass:(Class)cls {
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

- (Class)originalClass {
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

- (void)restoreClass {
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

- (void)restoreOriginalClass {
  NSMutableDictionary* infos = objc_getAssociatedObject(self, kAssocKey);
  if (infos == nil) {
    return;
  }

  NSMutableArray* classes = [infos objectForKey:kAssocKeyClasses];
  Class originalClass = [infos objectForKey:kAssocKeyOriginalClass];
  [classes removeAllObjects];

  object_setClass(self, originalClass);
}

- (BOOL)hasCustomClass {
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

/****************************************************************************
 * TESTING
 ****************************************************************************/

@interface Foo : NSObject {
}
@end

@interface Bar : NSObject {
}
@end

@interface FooBar : NSObject {
}
@end

@implementation Foo
@end

@implementation Bar
@end

@implementation FooBar
@end

int main(void) {
  NSString* s;

  @autoreleasepool {
    s = @"hello, world";
    NSLog(@"Object is now: %@", NSStringFromClass([s class]));

    [s setClass:[Foo class]];
    NSLog(@"Object is now: %@", NSStringFromClass([s class]));

    [s setClass:[Bar class]];
    NSLog(@"Object is now: %@", NSStringFromClass([s class]));

    [s setClass:[FooBar class]];
    NSLog(@"Object is now: %@", NSStringFromClass([s class]));

    @try {
      NSLog(@"Trying to call a no longer valid selector...");

      [s length];
    }
    @catch (NSException* e) {
      NSLog(@"Caught expected exception: %@ - %@", [e name], [e reason]);
    }

    [s restoreClass];
    NSLog(@"Object is now: %@", NSStringFromClass([s class]));

    [s restoreOriginalClass];
    NSLog(@"Object is now: %@", NSStringFromClass([s class]));
  }

  return EXIT_SUCCESS;
}
