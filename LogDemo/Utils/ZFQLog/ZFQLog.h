//
//  ZFQLog.h
//  LogDemo
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ZFQLog(fmt,...) [ZFQLog log:__LINE__ format:fmt,##__VA_ARGS__]

@interface ZFQLog : NSObject

+ (void)log:(NSInteger)line msg:(NSString *)msg;

+ (void)log:(NSInteger)line format:(NSString *)format, ...;

@end
