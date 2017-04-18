//
//  ZFQBaseService.m
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseService.h"

@implementation ZFQBaseService
/*
- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    self.method = method;
    self.path = path;
    self.request = request;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    NSAssert(0, @"You must implement this method in subclass");
    return NO;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    return nil;
}*/

- (ZFQFileManager *)fileManger
{
    if (!_fileManger) {
        _fileManger = [[ZFQFileManager alloc] init];
    }
    return _fileManger;
}

@end
