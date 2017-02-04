//
//  LogDemoTests.m
//  LogDemoTests
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZFQLog.h"

@interface LogDemoTests : XCTestCase

@end

@implementation LogDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMsgNil
{
    [ZFQLog logMsg:nil];
}

- (void)testMsgEmpty
{
    [ZFQLog logMsg:@""];
}

- (void)testMsgNoramlA
{
    [ZFQLog logMsg:@"This is Test String"];
}

- (void)testMsgNoramlB
{
    [ZFQLog logMsg:@"This is Test String😬"];
}

- (void)testMsgNoramlC
{
    [ZFQLog logMsg:@"This is 测试 String😬"];
}

- (void)testLogFormatNil
{
    [ZFQLog logFormat:nil];
}

- (void)testLogFormatString
{
    [ZFQLog logFormat:@"This is 测试 String😬"];
}

- (void)testLogFormatNoraml
{
    [ZFQLog logFormat:@"This is %d and %s",123,@"你好"];
}

- (void)testPerformanceLogFormat
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        [ZFQLog logFormat:@"This is %d and %s",123,@"你好"];
    }];
}

- (void)testPerformanceLogMsg
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        [ZFQLog logMsg:@"This is Test String"];
    }];
}

- (void)testPerformanceLogMsgLongStr
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        [ZFQLog logMsg:@"This is Test String and it's very long , I'm so hungry i want go home early please get off work quickly hahahhah"];
    }];
}

@end
