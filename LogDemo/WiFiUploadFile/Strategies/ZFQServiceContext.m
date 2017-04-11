//
//  ZFQServiceContext.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQServiceContext.h"

@interface ZFQServiceContext()
@property (nonatomic, strong) NSMutableArray<id<ZFQConnectionProtocol> > *serviceList;
@end
@implementation ZFQServiceContext

- (NSObject<HTTPResponse> *)responseForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service matchMethod:method path:path request:request]) {
            return [service httpResponse];
        }
    }
    return nil;
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service supportMethod:method path:path]) {
            return YES;
        }
    }
    return NO;
}

- (void)addService:(id<ZFQConnectionProtocol>)service
{
    if (!_serviceList) {
        _serviceList = [[NSMutableArray alloc] init];
    }
    [_serviceList addObject:service];
}

@end
