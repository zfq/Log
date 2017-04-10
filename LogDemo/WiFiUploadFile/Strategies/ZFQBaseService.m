//
//  ZFQBaseService.m
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseService.h"

@implementation ZFQBaseService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    self.method = method;
    self.path = path;
    self.request = request;
    return NO;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    return nil;
}

@end
