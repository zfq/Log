//
//  ZFQLog.h
//  LogDemo
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFQLog : NSObject

+ (void)logMsg:(NSString *)msg;

+ (void)logFormat:(NSString *)format, ...;

@end
