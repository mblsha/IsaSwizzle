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
  NSString* const kAssocKeyOriginalClass =
  @"ISASwizzle_NSObject_OriginalClass";
  NSString* const kAssocKeyClasses = @"ISASwizzle_NSObject_Classes";
}

@interface NSObject (ISASwizzle_Private)
- (void)ddna_dealloc;
@end

@implementation NSObject (ISASwizzle_Private)
- (void)ddna_dealloc {
  objc_setAssociatedObject(self, kAssocKey, nil, OBJC_ASSOCIATION_ASSIGN);

  [self ddna_dealloc];
}
@end

static void __init(void) __attribute__((constructor));
static void __init(void) {
  Class cls;
  Method m1;
  Method m2;

  cls = [NSObject class];
  m1 = class_getInstanceMethod(cls, @selector(dealloc));
  m2 = class_getInstanceMethod(cls, @selector(ddna_dealloc));

  method_exchangeImplementations(m1, m2);
}

@implementation NSObject (ISASwizzle)
- (void)setClass:(Class)cls {
  NSMutableDictionary* infos;
  NSMutableArray* classes;
  Class originalClass;

  infos = objc_getAssociatedObject(self, kAssocKey);

  if (infos == nil) {
    infos = [NSMutableDictionary
             dictionaryWithObjectsAndKeys:[self class],
             kAssocKeyOriginalClass,
             [NSMutableArray arrayWithCapacity:10],
             kAssocKeyClasses,
             nil];

    [infos setObject:[self class] forKey:kAssocKeyOriginalClass];

    objc_setAssociatedObject(self, kAssocKey, infos, OBJC_ASSOCIATION_RETAIN);
  }

  classes = [infos objectForKey:kAssocKeyClasses];
  originalClass = [infos objectForKey:kAssocKeyOriginalClass];

  if (classes.count > 0 || object_getClass(self) != originalClass) {
    [classes addObject:object_getClass(self)];
  }

  object_setClass(self, cls);
}

- (Class)originalClass {
  NSMutableDictionary* infos;
  Class originalClass;

  infos = objc_getAssociatedObject(self, kAssocKey);

  if (infos == nil) {
    return object_getClass(self);
  }

  originalClass = [infos objectForKey:kAssocKeyOriginalClass];

  if (originalClass == nil) {
    return object_getClass(self);
  }

  return originalClass;
}

- (void)restoreClass {
  NSMutableDictionary* infos;
  NSMutableArray* classes;
  Class originalClass;

  infos = objc_getAssociatedObject(self, kAssocKey);

  if (infos == nil) {
    return;
  }

  classes = [infos objectForKey:kAssocKeyClasses];
  originalClass = [infos objectForKey:kAssocKeyOriginalClass];

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
  NSMutableDictionary* infos;
  NSMutableArray* classes;
  Class originalClass;

  infos = objc_getAssociatedObject(self, kAssocKey);

  if (infos == nil) {
    return;
  }

  classes = [infos objectForKey:kAssocKeyClasses];
  originalClass = [infos objectForKey:kAssocKeyOriginalClass];

  [classes removeAllObjects];

  object_setClass(self, originalClass);
}

- (BOOL)hasCustomClass {
  NSMutableDictionary* infos;
  NSMutableArray* classes;
  Class originalClass;

  infos = objc_getAssociatedObject(self, kAssocKey);

  if (infos == nil) {
    return NO;
  }

  classes = [infos objectForKey:kAssocKeyClasses];
  originalClass = [infos objectForKey:kAssocKeyOriginalClass];

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