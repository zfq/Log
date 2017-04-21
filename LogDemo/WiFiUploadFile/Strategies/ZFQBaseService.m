//
//  ZFQBaseService.m
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseService.h"

@implementation ZFQBaseService

- (ZFQFileManager *)fileManger
{
    if (!_fileManger) {
        _fileManger = [[ZFQFileManager alloc] init];
    }
    return _fileManger;
}

@end
