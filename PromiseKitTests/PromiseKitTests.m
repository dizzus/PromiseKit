//
//  PromiseKitTests.m
//  PromiseKitTests
//
//  Created by Дмитрий Бахвалов on 19.07.15.
//  Copyright (c) 2015 Dmitry Bakhvalov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "CocoaPromise.h"

@interface PromiseKitTests : XCTestCase

@end

@implementation PromiseKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - 1. TERMINOLOGY

#pragma mark - 1.1 “promise” is an object or function with a then method whose behavior conforms to this specification

- (void) test_1_1 {
    CocoaPromise* p = [CocoaPromise new];
    XCTAssertTrue( [p respondsToSelector: @selector(then:)] );
}

# pragma mark 1.3 “value” is any legal value (including undefined or a promise).

- (void) test_1_3 {
    CocoaPromise* p = [CocoaPromise new];
    XCTAssertTrue( [p respondsToSelector: @selector(value)] );
}

#pragma mark 1.5 “reason” is a value that indicates why a promise was rejected.
- (void) test_1_5 {
    CocoaPromise* p = [CocoaPromise new];
    XCTAssertTrue( [p respondsToSelector: @selector(reason)] );
}

#pragma mark - 2 REQUIREMENTS
#pragma mark - 2.1 Promise states: A promise must be in one of three states: pending, fulfilled, or rejected

- (void) test_2_1 {
    CocoaPromise* p = [CocoaPromise new];
    XCTAssert(p.state == kCocoaPromisePendingState || p.state == kCocoaPromiseFulfilledState || p.state == kCocoaPromiseRejectedState);
}

#pragma mark 2.1.1.1 When pending, a promise may transition to fulfilled state

- (void) test_2_1_1_1_a {
    XCTestExpectation* test = [self expectationWithDescription: @"When pending, a promise may transition fulfilled state"];
    
    CocoaPromise* p = [CocoaPromise new];
    XCTAssertEqual(p.state, kCocoaPromisePendingState);
    
    [p then:^id(id value) {
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(value, @42);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
    }];
}

#pragma mark 2.1.1.1 When pending, a promise may transition to rejected state

- (void) test_2_1_1_1_b {
    XCTestExpectation* test = [self expectationWithDescription: @"When pending, a promise may transition to rejected state"];
    
    CocoaPromise* p = [CocoaPromise new];
    XCTAssertEqual(p.state, kCocoaPromisePendingState);
    
    [p catch:^id(NSError *err) {
        XCTAssert(p.state == kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssert(p.state == kCocoaPromiseRejectedState);
    }];
}

#pragma mark - 2.1.2 When fulfilled, a promise:
#pragma mark - 2.1.2.1 must not transition to any other state

- (void) test_2_1_2_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"When fulfilled, a promise must not transition to any other state"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p then:^id(id value) {
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
        
        XCTAssertThrows([p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]]);
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
        
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
    }];
}

#pragma mark 2.1.2.2 must have a value which must not change

- (void) test_2_1_2_2 {
    XCTestExpectation* test = [self expectationWithDescription: @"When fulfilled, a promise must have a value, which must not change"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p then:^id(id value) {
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
        
        XCTAssertThrows([p fulfill: @123]);
        XCTAssertEqualObjects(p.value, @42);
        
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssert(p.state == kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(p.value, @42);
    }];
}


#pragma mark - 2.1.3 When rejected, a promise:
#pragma mark 2.1.3.1 must not transition to any other state

- (void) test_2_1_3_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"When rejected, a promise must not transition to any other state"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p catch:^id(NSError *err) {
        XCTAssert(p.state == kCocoaPromiseRejectedState);
        
        XCTAssertThrows([p fulfill: @42]);
        XCTAssert(p.state == kCocoaPromiseRejectedState);
        
        [test fulfill];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssert(p.state == kCocoaPromiseRejectedState);
    }];
}

# pragma mark 2.1.3.2 must have a reason which must not change

- (void) test_2_1_3_2 {
    XCTestExpectation* test = [self expectationWithDescription: @"When fulfilled, a promise must have a reason, which must not change"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p catch:^id(NSError *err) {
        XCTAssert(p.state == kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(p.reason, [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]);
        
        XCTAssertThrows([p reject: [NSError errorWithDomain: @"Other error" code:0 userInfo:nil]]);
        XCTAssert(p.state == kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(p.reason, [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]);
        
        [test fulfill];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssert(p.state == kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(p.reason, [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]);
    }];
}

#pragma mark - 2.2 THE 'THEN' METHOD
#pragma mark - 2.2.1 Both onFulfilled and onRejected are optional arguments

- (void) test_2_2_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"Both onFulfilled and onRejected are optional arguments"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p onFulfill:nil onReject:nil];
    
    [p fulfill: @42];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(p.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(p.value, @42);
    }];
}

#pragma mark 2.2.1.1 if onFulfilled is not a function it must be ignored

- (void) test_2_2_1_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"if onFulfilled is not a function it must be ignored"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p onFulfill:nil onReject:^id(NSError *err) {
        XCTFail(@"Should not be called");
        return nil;
    }];
    
    [p fulfill: @42];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(p.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(p.value, @42);
    }];
}

#pragma mark 2.2.1.2 if onRejected is not a function it must be ignored

- (void) test_2_2_1_2 {
    XCTestExpectation* test = [self expectationWithDescription: @"if onRejected is not a function it must be ignored"];
    
    CocoaPromise* p = [CocoaPromise new];
    [p onFulfill:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    } onReject:nil];
    
    [p reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(p.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(p.reason, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
    }];
}

#pragma mark - 2.2.2 If onFulfilled is a function:
#pragma mark 2.2.2.1 it must be called after promise is fulfilled, with promise’s value as its first argument.

- (void) test_2_2_2_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onFulfilled is a function it must be called after promise is fulfilled, with promise’s value as its first argument."];
    
    CocoaPromise* p = [CocoaPromise new];
    
    __block BOOL onFulfillCalled = NO;
    
    [p onFulfill:^id(id value) {
        onFulfillCalled = YES;
        XCTAssertEqualObjects(value, @42);
        [test fulfill];
        return nil;
    } onReject:nil];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertTrue(onFulfillCalled);
    }];
}

#pragma mark 2.2.2.2 it must not be called before promise is fulfilled

- (void) test_2_2_2_2 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onFulfilled is a function it it must not be called before promise is fulfilled"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    __block uint64_t onFulfillTime = 0;
    
    [p onFulfill:^id(id value) {
        onFulfillTime = mach_absolute_time();
        [test fulfill];
        return nil;
    } onReject:nil];
    
    uint64_t fulfillTime = mach_absolute_time();
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertGreaterThan(onFulfillTime, fulfillTime);
    }];
}

#pragma mark 2.2.2.3 it must not be called more than once

- (void) test_2_2_2_3 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onFulfilled is a function it must not be called more than once"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    __block NSUInteger callCounter = 0;
    
    [p onFulfill:^id(id value) {
        ++callCounter;
        return nil;
    } onReject:nil];
    
    [p fulfill: @42];
    XCTAssertThrows([p fulfill: @123]);
    XCTAssertThrows([p fulfill: @"Hello, world"]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(callCounter, 1);
    }];
}


#pragma mark - 2.2.3 If onRejected is a function
#pragma mark 2.2.3.1 it must be called after promise is rejected, with promise’s reason as its first argument.

- (void) test_2_2_3_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onRejected is a function it must be called after promise is rejected, with promise’s reason as its first argument."];
    
    CocoaPromise* p = [CocoaPromise new];
    
    __block BOOL onRejectedCalled = NO;
    
    [p onFulfill:nil onReject:^id(NSError *err) {
        onRejectedCalled = YES;
        XCTAssertEqualObjects(err, [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertTrue(onRejectedCalled);
    }];
}

#pragma mark 2.2.3.2 it must not be called before promise is rejected.

- (void) test_2_2_3_2 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onRejected is a function it must not be called before promise is rejected"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    __block uint64_t onRejectedTime = 0;
    
    [p onFulfill:nil onReject:^id(NSError *err) {
        onRejectedTime = mach_absolute_time();
        [test fulfill];
        return nil;
    }];
    
    uint64_t rejectTime = mach_absolute_time();
    [p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertGreaterThanOrEqual(onRejectedTime, rejectTime);
    }];
}

#pragma mark 2.2.3.3 it must not be called more than once.

- (void) test_2_2_3_3 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onRejected is a function it must not be called more than once"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    __block NSUInteger callCounter = 0;
    
    [p onFulfill:nil onReject:^id(NSError *err) {
        ++callCounter;
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain: @"Dummy" code:0 userInfo:nil]];
    XCTAssertThrows([p reject: [NSError errorWithDomain: @"Other error" code:0 userInfo:nil]]);
    XCTAssertThrows([p reject: [NSError errorWithDomain: @"Another error" code:0 userInfo:nil]]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(callCounter, 1);
    }];
}

#pragma mark - 2.2.6 'then' maybe called multiple times
#pragma mark 2.2.6.1 if/when promise is fulfilled, all respective onFulfilled callbacks must execute in the order of their originating calls to then

- (void) test_2_2_6_1 {
    XCTestExpectation* test = [self expectationWithDescription: @"If/when promise is fulfilled, all respective onFulfilled callbacks must execute in the order of their originating calls to then"];
    
    NSMutableArray* results = [NSMutableArray new];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [p onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @"Dummy");
        [results addObject: @1];
        return nil;
    } onReject:nil];
    
    [p onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @"Dummy");
        [results addObject: @2];
        return nil;
    } onReject:nil];
    
    [p onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @"Dummy");
        [results addObject: @3];
        return nil;
    } onReject:nil];
    
    [p fulfill:@"Dummy"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        NSArray* shouldBe = @[ @1, @2, @3 ];
        XCTAssertEqualObjects(results, shouldBe);
    }];
}

#pragma mark 2.2.6.2 If/when promise is rejected, all respective onRejected callbacks must execute in the order of their originating calls to then

- (void) test_2_2_6_2 {
    XCTestExpectation* test = [self expectationWithDescription: @"If/when promise is rejected, all respective onRejected callbacks must execute in the order of their originating calls to then"];
    
    NSMutableArray* results = [NSMutableArray new];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [p onFulfill:nil onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [results addObject: @1];
        return nil;
    }];
    
    [p onFulfill:nil onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [results addObject: @2];
        return nil;
    }];
    
    [p onFulfill:nil onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [results addObject: @3];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        NSArray* shouldBe = @[ @1, @2, @3 ];
        XCTAssertEqualObjects(results, shouldBe);
    }];
}


#pragma mark - 2.2.7 'then' must return a promise

- (void) test_2_2_7 {
    CocoaPromise* p = [CocoaPromise new];
    
    id result = [p onFulfill:nil onReject:nil];
    XCTAssertTrue( [result isKindOfClass: [CocoaPromise class]] );
    
    result = [p then: nil];
    XCTAssertTrue( [result isKindOfClass: [CocoaPromise class]] );
    
    result = [p catch:nil];
    XCTAssertTrue( [result isKindOfClass: [CocoaPromise class]] );
}


# pragma mark 2.2.7.1 If either onFulfilled or onRejected returns a value x, run the Promise Resolution Procedure [[Resolve]](promise2, x)

- (void) test_2_2_7_1_a {
    XCTestExpectation* test = [self expectationWithDescription: @"If onFulfilled returns a value x, run the Promise Resolution Procedure [[Resolve]](promise2, x)."];
    
    CocoaPromise* p = [CocoaPromise new];
    
    CocoaPromise* promise2 = [p onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [test fulfill];
        });
        return @123;
    } onReject:nil];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(promise2.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(promise2.value, @123);
    }];
}

- (void) test_2_2_7_1_b {
    XCTestExpectation* test = [self expectationWithDescription: @"If onRejected returns a value x, run the Promise Resolution Procedure [[Resolve]](promise2, x)."];
    
    CocoaPromise* p = [CocoaPromise new];
    
    CocoaPromise* promise2 = [p onFulfill:nil onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [test fulfill];
        });
        return @123;
    }];
    
    [p reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(promise2.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(promise2.value, @123);
    }];
}

#pragma mark 2.2.7.2 If either onFulfilled or onRejected throws an exception e, promise2 must be rejected with e as the reason

- (void) test_2_2_7_2_a {
    XCTestExpectation* test = [self expectationWithDescription: @"If onFulfilled throws an exception e, promise2 must be rejected with e as the reason"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    CocoaPromise* promis2 = [p onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [test fulfill];
        });
        @throw [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil];
    } onReject: nil];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(promis2.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(promis2.reason, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
    }];
}

- (void) test_2_2_7_2_b {
    XCTestExpectation* test = [self expectationWithDescription: @"If onRejected throws an exception e, promise2 must be rejected with e as the reason"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    CocoaPromise* promise2 = [p onFulfill:nil onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [test fulfill];
        });
        @throw [NSError errorWithDomain:@"Other error" code:0 userInfo:nil];
    }];
    
    [p reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(promise2.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(promise2.reason, [NSError errorWithDomain:@"Other error" code:0 userInfo:nil]);
    }];
}

#pragma mark 2.2.7.3 If onFulfilled is not a function and promise1 is fulfilled, promise2 must be fulfilled with the same value as promise1

- (void) test_2_2_7_3 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onFulfilled is not a function and promise1 is fulfilled, promise2 must be fulfilled with the same value as promise1"];
    
    CocoaPromise* promise1 = [CocoaPromise new];
    
    CocoaPromise* promise2 = [promise1 onFulfill:nil onReject:^id(NSError *err) {
        XCTFail(@"Should not be called");
        return nil;
    }];
    
    [promise1 fulfill: @42];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(promise2.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(promise2.value, @42);
    }];
}

#pragma mark 2.2.7.4 If onRejected is not a function and promise1 is rejected, promise2 must be rejected with the same reason as promise1

- (void) test_2_2_7_4 {
    XCTestExpectation* test = [self expectationWithDescription: @"If onRejected is not a function and promise1 is rejected, promise2 must be rejected with the same reason as promise1"];
    
    CocoaPromise* promise1 = [CocoaPromise new];
    
    CocoaPromise* promise2 = [promise1 onFulfill:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    } onReject:nil];
    
    [promise1 reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(promise2.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(promise2.reason, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
    }];
}

#pragma mark - 2.3 THE PROMISE RESOLUTION PROCEDURE
#pragma mark - 2.3.1 If promise and x refer to the same object, reject promise with a TypeError as the reason.

- (void) test_2_3_1 {
    CocoaPromise* p = [CocoaPromise new];
    
    [p onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @42);
    } onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Other error" code:0 userInfo:nil]);
    }];
    
    XCTAssertThrows( [p fulfill: p] );
}

#pragma mark - 2.3.2 If x is a promise, adopt its state
#pragma mark 2.3.2.1 If x is pending, promise must remain pending until x is fulfilled or rejected

- (void) test_2_3_2_1_a {
    XCTestExpectation* test = [self expectationWithDescription: @"If x is pending, promise must remain pending"];
    
    CocoaPromise* promise = [CocoaPromise new];
    
    [promise onFulfill:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    } onReject:^id(NSError *err) {
        XCTFail(@"Should not be called");
        return nil;
    }];
    
    CocoaPromise* x = [CocoaPromise new];
    [promise fulfill: x];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(x.state, kCocoaPromisePendingState);
        XCTAssertEqual(promise.state, kCocoaPromisePendingState);
        
        [test fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqual(x.state, kCocoaPromisePendingState);
        XCTAssertEqual(promise.state, kCocoaPromisePendingState);
    }];
}

- (void) test_2_3_2_1_b {
    XCTestExpectation* test = [self expectationWithDescription: @"If x is pending, promise must remain pending until x is fulfilled"];
    
    CocoaPromise* promise = [CocoaPromise new];
    
    [promise onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        [test fulfill];
        return nil;
    } onReject: nil];
    
    CocoaPromise* x = [CocoaPromise new];
    [promise fulfill: x];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(x.state, kCocoaPromisePendingState);
        XCTAssertEqual(promise.state, kCocoaPromisePendingState);
        
        [x fulfill: @42];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqual(x.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(x.value, @42);
        
        XCTAssertEqual(promise.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(promise.value, @42);
    }];
}

- (void) test_2_3_2_1_c {
    XCTestExpectation* test = [self expectationWithDescription: @"If x is pending, promise must remain pending until x is rejected"];
    
    CocoaPromise* promise = [CocoaPromise new];
    
    [promise onFulfill:nil onReject:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    CocoaPromise* x = [CocoaPromise new];
    [promise fulfill: x];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(x.state, kCocoaPromisePendingState);
        XCTAssertEqual(promise.state, kCocoaPromisePendingState);
        
        [x reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqual(x.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(x.value, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        
        XCTAssertEqual(promise.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(promise.value, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
    }];
}

#pragma mark 2.3.4 If x is not an object or function, fulfill promise with x

- (void) test_2_3_4 {
    XCTestExpectation* test = [self expectationWithDescription: @"If x is not an object or function, fulfill promise with x"];
    
    CocoaPromise* promise = [CocoaPromise new];
    
    [promise onFulfill:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        [test fulfill];
        return nil;
    } onReject: nil];
    
    [promise fulfill: @42];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqual(promise.state, kCocoaPromiseFulfilledState);
        XCTAssertEqualObjects(promise.value, @42);
    }];
}

#pragma mark - CHAINING

- (void) test_simple_chaining {
    XCTestExpectation* test = [self expectationWithDescription: @"Simple then chaining"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[[[[p then:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        return @123;
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @123);
        return @"Hello, world";
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @"Hello, world");
        return @YES;
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @YES);
        return nil;
    }] then:^id(id value) {
        XCTAssertNil(value);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_chaining_with_promises {
    XCTestExpectation* test = [self expectationWithDescription: @"Chaining with promises"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[p then:^id(id value) {
        CocoaPromise* x = [CocoaPromise new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [x fulfill: @"Hello, world"];
        });
        return x;
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @"Hello, world");
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_chaining_with_nested_promises {
    XCTestExpectation* test = [self expectationWithDescription: @"Chaining with nested promises"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[[p then:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        
        CocoaPromise* x = [CocoaPromise new];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CocoaPromise* y = [CocoaPromise new];
            [x fulfill: y];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [y fulfill: @"Hello, world"];
            });
        });
        
        return x;
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @"Hello, world");
        CocoaPromise* z = [CocoaPromise new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [z fulfill: @789];
        });
        return z;
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @789);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_reject_and_catch {
    XCTestExpectation* test = [self expectationWithDescription: @"Reject and catch"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[p then:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    }] catch:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(p.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(p.reason, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
    }];
}

- (void) test_return_error_from_then {
    XCTestExpectation* test = [self expectationWithDescription: @"Return error from then"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[p then:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        return [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil];
    }] catch:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_return_error_from_then2 {
    XCTestExpectation* test = [self expectationWithDescription: @"Return error from then2"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[[p then:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        return [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil];
    }] then:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    }] catch:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_throw_error_from_then {
    XCTestExpectation* test = [self expectationWithDescription: @"Throw error from then"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[p then:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        @throw [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil];
    }] catch:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_throw_error_from_then2 {
    XCTestExpectation* test = [self expectationWithDescription: @"Throw error from then"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[[p then:^id(id value) {
        XCTAssertEqualObjects(value, @42);
        @throw [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil];
    }] then:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    }] catch:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        [test fulfill];
        return nil;
    }];
    
    [p fulfill: @42];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqualObjects(p.value, @42);
    }];
}

- (void) test_return_value_from_catch {
    XCTestExpectation* test = [self expectationWithDescription: @"Return value from catch"];
    
    CocoaPromise* p = [CocoaPromise new];
    
    [[[p then:^id(id value) {
        XCTFail(@"Should not be called");
        return nil;
    }] catch:^id(NSError *err) {
        XCTAssertEqualObjects(err, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
        return @"Hello, world";
    }] then:^id(id value) {
        XCTAssertEqualObjects(value, @"Hello, world");
        [test fulfill];
        return nil;
    }];
    
    [p reject: [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]];
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertEqual(p.state, kCocoaPromiseRejectedState);
        XCTAssertEqualObjects(p.reason, [NSError errorWithDomain:@"Dummy" code:0 userInfo:nil]);
    }];
}


@end
