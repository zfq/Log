//
//  ZFQFileListService.m
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQFileListService.h"

@implementation ZFQFileListService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path
{
    return [method isEqualToString:@"GET"] && [path isEqualToString:@"/files"];
}

@end
