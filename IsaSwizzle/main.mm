#import "NSObject+IsaSwizzle.h"

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
