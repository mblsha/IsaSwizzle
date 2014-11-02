//
//  IsaSwizzleTest.m
//  IsaSwizzleTest
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSObject+MBLIsaSwizzle.h"
#import "NSObject+MBLTracing.h"
#import <objc/runtime.h>

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
@property(retain) NSString* firstName;
@property(retain) NSString* lastName;
@end

@implementation Person
- (void)dealloc {
  self.firstName = nil;
  self.lastName = nil;
  [super dealloc];
}
@end

@interface PersonWatcher : NSObject {
}
@end

@implementation PersonWatcher
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
  //  if ([keyPath isEqual:@"openingBalance"]) {
  //    [openingBalanceInspectorField setObjectValue:
  //     [change objectForKey:NSKeyValueChangeNewKey]];
  //  }

  [super observeValueForKeyPath:keyPath
                       ofObject:object
                         change:change
                        context:context];
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
  XCTAssertEqual([s mbl_hasCustomClass], NO);

  [s mbl_setClass:[Foo class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Foo"]);
  XCTAssertEqual([s mbl_hasCustomClass], YES);

  [s mbl_setClass:[Bar class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Bar"]);
  XCTAssertEqual([s mbl_hasCustomClass], YES);

  [s mbl_setClass:[FooBar class]];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"FooBar"]);
  XCTAssertEqual([s mbl_hasCustomClass], YES);

  @try {
    [s length];
  }
  @catch (NSException* e) {
    XCTAssert([[e name] isEqual:@"NSInvalidArgumentException"]);
    XCTAssert([[e reason]
        hasPrefix:@"-[FooBar length]: unrecognized selector sent to instance"]);
  }

  [s mbl_restoreClass];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"Bar"]);
  XCTAssertEqual([s mbl_hasCustomClass], YES);

  [s mbl_restoreOriginalClass];
  XCTAssert([NSStringFromClass([s class]) isEqual:@"__NSCFConstantString"]);
  XCTAssertEqual([s mbl_hasCustomClass], NO);
}

- (void)testKVO {
  PersonWatcher* watcher = [[[PersonWatcher alloc] init] autorelease];
  Person* person = [[Person alloc] init];
  person.firstName = @"First";
  person.lastName = @"Last";
  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([NSStringFromClass(object_getClass(person)) isEqual:@"Person"]);
  XCTAssert([person.firstName isEqual:@"First"]);
  XCTAssert([person.lastName isEqual:@"Last"]);

  [person
      addObserver:watcher
       forKeyPath:@"firstName"
          options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
          context:NULL];

  // adding KVO observer changes the isa pointer on the observed class
  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([NSStringFromClass(object_getClass(person))
      isEqual:@"NSKVONotifying_Person"]);

  [person removeObserver:watcher forKeyPath:@"firstName"];

  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([NSStringFromClass(object_getClass(person)) isEqual:@"Person"]);

  [person release];
}

- (void)testTracing {
  Person* person = [[Person alloc] init];
  person.firstName = @"First";
  person.lastName = @"Last";
  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([NSStringFromClass(object_getClass(person)) isEqual:@"Person"]);

  [person mbl_startTracing];
  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([NSStringFromClass(object_getClass(person))
      isEqual:@"MBLTracing_Person"]);

  // tracer must forward selectors
  XCTAssert([person.firstName isEqual:@"First"]);
  XCTAssert([person.lastName isEqual:@"Last"]);

  [person mbl_endTracing];
  XCTAssert([NSStringFromClass([person class]) isEqual:@"Person"]);
  XCTAssert([NSStringFromClass(object_getClass(person)) isEqual:@"Person"]);

  [person release];
}

@end
