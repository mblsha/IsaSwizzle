//
//  IsaSwizzleTest.m
//  IsaSwizzleTest
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "NSObject+IsaSwizzle.h"

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

@interface IsaSwizzleTest : XCTestCase
@end

@implementation IsaSwizzleTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testExample {
  XCTAssert(YES, @"Pass");

  NSString* s = @"hello, world";
  XCTAssert([NSStringFromClass([s class]) isEqual:@"__NSCFConstantString"]);

  [s setClass:[Foo class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Foo"]);

  [s setClass:[Bar class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Bar"]);

  [s setClass:[FooBar class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"FooBar"]);

  @try {
    NSLog(@"Trying to call a no longer valid selector...");

    [s length];
  }
  @catch (NSException* e) {
    NSLog(@"Caught expected exception: %@ - %@", [e name], [e reason]);
  }

  [s restoreClass];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Bar"]);

  [s restoreOriginalClass];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"__NSCFConstantString"]);
}

@end
