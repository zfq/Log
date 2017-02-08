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
    [ZFQLog log:__LINE__ msg:nil];
}

- (void)testMsgEmpty
{
    [ZFQLog log:__LINE__ msg:@""];
}

- (void)testMsgNoramlA
{
    [ZFQLog log:__LINE__ msg:@"This is Test String"];
}

- (void)testMsgNoramlB
{
    [ZFQLog log:__LINE__ msg:@"This is Test String😬"];
}

- (void)testMsgNoramlC
{
    [ZFQLog log:__LINE__ msg:@"This is 测试 String😬"];
}

- (void)testLogFormatNil
{
    [ZFQLog log:__LINE__ format:nil];
}

- (void)testLogFormatString
{
    [ZFQLog log:__LINE__ format:@"This is 测试 String😬"];
}

- (void)testLogMacro
{
    ZFQLog(@"你好啊，哈哈");
}

- (void)testLogMacro2
{
    ZFQLog(@"你好啊，哈哈%d,%@",123,@"呵呵");
}

- (void)testLogFormatNoraml
{
    [ZFQLog log:__LINE__ format:@"This is %d and %@",123,@"你好"];
}

- (void)testPerformanceLogFormat
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        [ZFQLog log:__LINE__ format:@"This is %d and %@",123,@"你好"];
    }];
}

- (void)testPerformanceLogMsg
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        [ZFQLog log:__LINE__ format:@"This is Test String"];
    }];
}

- (void)testPerformanceLogMsgLongStr
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        [ZFQLog log:__LINE__ format:@"This is Test String and it's very long , I'm so hungry i want go home early please get off work quickly hahahhah"];
    }];
}

@end
