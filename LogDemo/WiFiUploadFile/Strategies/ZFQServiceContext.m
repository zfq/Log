//
//  ZFQServiceContext.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQServiceContext.h"

@interface ZFQServiceContext()
@property (nonatomic, strong) ZFQBaseService *service;
@property (nonatomic, strong) NSMutableArray<ZFQBaseService *> *serviceList;
@end
@implementation ZFQServiceContext

- (NSObject<HTTPResponse> *)responseForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    for (ZFQBaseService *service in self.serviceList) {
        if ([service matchMethod:method path:path request:request]) {
            return [service httpResponse];
        }
    }
    return nil;
}

- (void)addService:(ZFQBaseService *)service
{
    if (!_serviceList) {
        _serviceList = [[NSMutableArray alloc] init];
    }
    [_serviceList addObject:service];
}

@end
