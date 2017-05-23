//
//  ZFQLog.m
//  LogDemo
//
//  Created by _ on 17/2/4.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQLog.h"
#import <stdio.h>
#import <time.h>

@implementation ZFQLog

void zfqPrintDate()
{
    time_t timep;
    time(&timep);
    struct tm *p = localtime(&timep);
    printf("%d/%d/%d %d:%d:%d ",(1900+p->tm_year),(1+p->tm_mon),p->tm_mday,p->tm_hour,p->tm_min,p->tm_sec);
}

+ (void)log:(NSInteger)line msg:(NSString *)msg
{
    if (!msg || ![msg isKindOfClass:[NSString class]]) {
        return;
    }
                
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logPath = [documentPath stringByAppendingPathComponent:@"log.txt"];
#ifdef DEBUG
    static BOOL logged = NO;
    if (!logged) {
        NSLog(@"log文件路径为\n%@",logPath);
        logged = YES;
    }
#endif
    msg = [NSString stringWithFormat:@"%@\r\n",msg];
    
    if (freopen([logPath UTF8String], "a+", stdout)) {
        
        //get current date
        zfqPrintDate();
        printf("%ld,%s", (long)line, [msg UTF8String]);
#ifdef DEBUG
        NSLog(@"%ld,%s", (long)line, [msg UTF8String]);
#endif
    }
    fclose(stdout);
}

+ (void)log:(NSInteger)line format:(NSString *)format, ...
{
    if (!format) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self log:line msg:msg];
}

@end
