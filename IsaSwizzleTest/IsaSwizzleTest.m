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
  XCTAssertEqual([s hasCustomClass], NO);

  [s setClass:[Foo class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Foo"]);
  XCTAssertEqual([s hasCustomClass], YES);

  [s setClass:[Bar class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Bar"]);
  XCTAssertEqual([s hasCustomClass], YES);

  [s setClass:[FooBar class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"FooBar"]);
  XCTAssertEqual([s hasCustomClass], YES);

  @try {
    [s length];
  }
  @catch (NSException* e) {
    XCTAssert([[e name] isEqual:@"NSInvalidArgumentException"]);
    XCTAssert([[e reason] hasPrefix:@"-[FooBar length]: unrecognized selector sent to instance"]);
  }

  [s restoreClass];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Bar"]);
  XCTAssertEqual([s hasCustomClass], YES);

  [s restoreOriginalClass];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"__NSCFConstantString"]);
  XCTAssertEqual([s hasCustomClass], NO);
}

@end
