//
//  LogDemoTests.m
//  LogDemoTests
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZFQLog.h"
#import "ZFQFileManager.h"

@interface LogDemoTests : XCTestCase
@property (nonatomic, strong) ZFQFileManager *fileManager;
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

- (ZFQFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[ZFQFileManager alloc] init];
    }
    return _fileManager;
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

- (void)testCreateTable
{
    XCTestExpectation *expect = [self expectationWithDescription:@"AAAAA"];
    NSString *sql = @"CREATE TABLE IF NOT EXISTS wifi_files (path TEXT, name TEXT);";
    [self.fileManager executeUpdate:sql].catch(^(NSError *error){
        NSLog(@"出错了");
        [expect fulfill];
    })
    .then(^(id value){
        NSLog(@"结果:%@",value);
        [expect fulfill];
    });
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"测试失败:%@",error);
        }
    }];
}

- (ZFQDBPromise *)promiseTest1
{
    ZFQDBPromise *promise = [ZFQDBPromise promiseWithAdapterBlock:^(ZFQDBPromiseAdapter *adapter) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            BOOL success = YES;
            if (success) {
                adapter.resolve(@"promiseTest1");
            } else {
                NSDictionary *dict = @{@"name":@"promiseTest1"};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:100 userInfo:dict];
                adapter.reject(error);
            }
        });
    }];
    
    return promise;
}

- (void)promiseTest2:(void (^)(id value))successBlk failureBlk:(void (^)(NSError *error))failureBlk
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        BOOL success = YES;
        if (success) {
            if (successBlk) {
                successBlk(@"promiseTest2");
            }
        } else {
            if (failureBlk) {
                NSDictionary *dict = @{@"name":@"promiseTest2"};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:100 userInfo:dict];
                
                failureBlk(error);
            }
            
        }
    });
}

- (void)promiseTest3:(void (^)(id value))successBlk failureBlk:(void (^)(NSError *error))failureBlk
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        BOOL success = YES;
        if (success) {
            if (successBlk) {
                successBlk(@"promiseTest3");
            }
        } else {
            if (failureBlk) {
                NSDictionary *dict = @{@"name":@"promiseTest3"};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:100 userInfo:dict];
                
                failureBlk(error);
            }
            
        }
    });
}

- (void)testPromiseThen
{
    XCTestExpectation *expect = [self expectationWithDescription:@"PromiseThen"];
    
    [self promiseTest1]
    .then(^(id value){
        NSLog(@"promiseTest1 then 结果为:%@",value);
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        [self promiseTest2:^(id value) {
            promise.adapter.resolve(value);
        } failureBlk:^(NSError *error) {
            promise.adapter.reject(error);
        }];
    })
    .then(^(id value){
        NSLog(@"promiseTest2 then 结果为:%@",value);
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        [self promiseTest3:^(id value) {
            promise.adapter.resolve(@"尼玛");
        } failureBlk:^(NSError *error) {
            promise.adapter.reject(error);
        }];
    })
    .then(^(id value){
        NSLog(@"promiseTest3 then 结果为:%@",value);
        [expect fulfill];
    })
    .catch(^(NSError *error){
        NSLog(@"失败结果为:%@",error);
        [expect fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"测试失败:%@",error);
        }
    }];
}

- (void)testPromiseThen2
{
    XCTestExpectation *expect = [self expectationWithDescription:@"PromiseThen"];
    
    ZFQDBPromise *p = [self promiseTest1]
    .then(^(id value){
        NSLog(@"promiseTest1 then 结果为:%@",value);
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        promise.adapter.resolve(@"执行第一个thenOn接口");
    })
    .then(^(id value){
        NSLog(@"promiseTest2 then 结果为:%@",value);
    })
    .thenOn(^(id value,ZFQDBPromise *promise){
        promise.adapter.resolve(@"尼玛");
    });
    
    p.then(^(id value){
        NSLog(@"结束:%@",value);
        [expect fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"测试失败:%@",error);
        }
    }];
}

- (void)testRemoveFile
{
    XCTestExpectation *expect = [self expectationWithDescription:@"testRemoveFile"];
    [self.fileManager removeFileWithFileId:@"3"].then(^(id value){
        NSLog(@"删除成功");
        [expect fulfill];
    });
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"测试失败:%@",error);
        }
    }];
}

@end
