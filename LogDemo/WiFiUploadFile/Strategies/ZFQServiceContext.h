//
//  ZFQServiceContext.h
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"

@interface ZFQServiceContext : NSObject

- (NSObject<HTTPResponse> *)responseForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request;
- (BOOL)supportMethod:(NSString *)method path:(NSString *)path;
- (void)addService:(id<ZFQConnectionProtocol>)service;

@end
