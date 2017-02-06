//
//  ZFQLog.m
//  LogDemo
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQLog.h"
#import <stdio.h>

@implementation ZFQLog

+ (void)logMsg:(NSString *)msg
{
    if (!msg || ![msg isKindOfClass:[NSString class]]) {
        return;
    }
                
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logPath = [documentPath stringByAppendingPathComponent:@"log.txt"];
#ifdef DEBUG
    NSLog(@"log文件路径为%@",logPath);
#endif
    msg = [NSString stringWithFormat:@"%@\r\n",msg];
    
    if (freopen([logPath UTF8String], "a+", stdout)) {
        printf("%s", [msg UTF8String]);
    }
    fclose(stdout);
}

+ (void)logFormat:(NSString *)format, ...
{
    if (!format) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
        
    [self logMsg:msg];
}

@end
