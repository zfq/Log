//
//  ZFQDBPromise.h
//  LogDemo
//
//  Created by _ on 17/4/17.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFQDBPromiseAdapter : NSObject

@property (nonatomic, copy) void (^resolve)(id value);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@class ZFQDBPromise;

typedef ZFQDBPromise * (^ZFQDBPromiseBlk)(void (^blk)(id value));
typedef ZFQDBPromise * (^ZFQDBPromiseCatchBlk)(void (^blk)(NSError *error));

@interface ZFQDBPromise : NSObject

+ (instancetype )promiseWithAdapterBlock:(void (^)(ZFQDBPromiseAdapter *adapter))adapterBlk;

- (ZFQDBPromiseBlk)then;
- (ZFQDBPromiseCatchBlk)catch;

@end
