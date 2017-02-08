//
//  WiFiUploadFileManager.m
//  LogDemo
//
//  Created by _ on 17/2/8.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "WiFiUploadFileManager.h"
#import <HTTPServer.h>
#import "ZFQLog.h"
#import "NSString+IPAddress.h"

@interface WiFiUploadFileManager ()
{
    HTTPServer *_httpServer;
}
@end
@implementation WiFiUploadFileManager

- (void)startHttpServer
{
    _httpServer = [[HTTPServer alloc] init];
    
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    [_httpServer setDocumentRoot:webPath];
    
    NSError *error;
    if ([_httpServer start:&error]) {
        UInt16 port = [_httpServer listeningPort];
        ZFQLog(@"启动成功,端口号为:%@:%hu",[NSString currentIpAddress],port);
    } else {
        ZFQLog(@"启动失败:%@",error);
    }
}

- (void)stopHttpServer
{
    [_httpServer stop];
}

@end
