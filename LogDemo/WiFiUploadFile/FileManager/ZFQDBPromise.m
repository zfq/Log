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
@property (nonatomic, readwrite) ZFQDBPromiseAdapter *adapter;
@property (nonatomic, strong) NSMutableArray *thenBlkArray;   //考虑使用串行队列
@property (nonatomic, strong) NSMutableArray *thenOnBlkArray;

@end

@implementation ZFQDBPromise

+ (instancetype )promiseWithAdapterBlock:(void (^)(ZFQDBPromiseAdapter *adapter))adapterBlk
{
    ZFQDBPromise *promise = [[ZFQDBPromise alloc] init];
    ZFQDBPromiseAdapter *adapter = [[ZFQDBPromiseAdapter alloc] init];
    promise.adapter = adapter;
    
    adapter.resolve = ^(id value) {
        //调用then
        if (promise.thenBlkArray.count > 0) {
            id blkObj = promise.thenBlkArray.firstObject;
            [promise.thenBlkArray removeObjectAtIndex:0];
            if ([blkObj isKindOfClass:[NSNull class]] == NO) {
                void (^tmpThenBlk)(id value) = blkObj;
                tmpThenBlk(value);
            }
        }
        
        //调用thenOn
        if (promise.thenOnBlkArray.count > 0) {
            id thenOnBlkObj = promise.thenOnBlkArray.firstObject;
            [promise.thenOnBlkArray removeObjectAtIndex:0];
            if ([thenOnBlkObj isKindOfClass:[NSNull class]] == NO) {
                void (^tmpThenOnBlk)(id value, ZFQDBPromise *promiseParam) = thenOnBlkObj;
                tmpThenOnBlk(value,promise);
            }
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
            [self.thenBlkArray addObject:blk];
        }
        return self;
    };
}

- (ZFQDBPromiseThenOnBlk)thenOn
{
    return ^(void (^blk)(id value, ZFQDBPromise *promise)) {
        if (blk) {
            [self.thenOnBlkArray addObject:blk];
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

- (NSMutableArray *)thenBlkArray
{
    if (!_thenBlkArray) {
        _thenBlkArray = [[NSMutableArray alloc] init];
    }
    return _thenBlkArray;
}

- (NSMutableArray *)thenOnBlkArray
{
    if (!_thenOnBlkArray) {
        _thenOnBlkArray = [[NSMutableArray alloc] init];
    }
    return _thenOnBlkArray;
}

@end
