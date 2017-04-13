//
//  CustomHTTPDataResponse.m
//  LogDemo
//
//  Created by _ on 17/2/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "CustomHTTPDataResponse.h"

@implementation CustomHTTPDataResponse

- (NSDictionary *)httpHeaders
{
    return self.customHttpHeader;
}

- (NSMutableDictionary *)customHttpHeader
{
    if (!_customHttpHeader) {
        _customHttpHeader = [[NSMutableDictionary alloc] init];
    }
    return _customHttpHeader;
}

@end
