//
//  CustomHTTPFileResponse.m
//  LogDemo
//
//  Created by _ on 17/4/12.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "CustomHTTPFileResponse.h"

@implementation CustomHTTPFileResponse

- (NSDictionary *)httpHeaders
{
    return self.customHttpHeader;
}

@end
