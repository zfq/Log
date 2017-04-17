//
//  ZFQDBPromise.m
//  LogDemo
//
//  Created by _ on 17/4/17.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQDBPromise.h"

@implementation ZFQDBPromiseAdapter

@end

@interface ZFQDBPromise()

@property (nonatomic, copy) void (^resolve)(id value);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation ZFQDBPromise

+ (instancetype )promiseWithAdapterBlock:(void (^)(ZFQDBPromiseAdapter *adapter))adapterBlk
{
    ZFQDBPromise *promise = [[ZFQDBPromise alloc] init];
    ZFQDBPromiseAdapter *adapter = [[ZFQDBPromiseAdapter alloc] init];

    adapter.resolve = ^(id value) {
        if (promise.resolve) {
            promise.resolve(value);
        }
    };
    adapter.reject = ^(NSError *error) {
        if (promise.reject) {
            promise.reject(error);
        }
    };
    
    adapterBlk(adapter);
    return promise;
}

- (ZFQDBPromiseBlk)then
{
    return ^(void (^blk)(id value)) {
        if (blk) {
            self.resolve = blk;
        }
        return self;
    };
}

- (ZFQDBPromiseCatchBlk)catch
{
    return ^(void (^blk)(NSError *error)) {
        if (blk) {
            self.reject = blk;
        }
        return self;
    };
}

@end
