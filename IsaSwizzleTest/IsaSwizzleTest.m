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

// MARK: - testIsaSwizzle classes
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

// MARK: - testKVO classes
@interface Person : NSObject {
}
@property (retain) NSString* firstName;
@property (retain) NSString* lastName;
@end

@implementation Person
- (void)dealloc {
  self.firstName = nil;
  self.lastName = nil;
  [super dealloc];
}
@end

// MARK: - testing code
@interface IsaSwizzleTest : XCTestCase
@end

@implementation IsaSwizzleTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIsaSwizzle {
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

- (void)testKVO {
  Person* person = [[Person alloc] init];
  person.firstName = @"First";
  person.lastName = @"Last";
  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([person.firstName isEqual:@"First"]);
  XCTAssert([person.lastName isEqual:@"Last"]);

  [person release];
}

@end
