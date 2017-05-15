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
#import "WiFiUploadHTTPConnection.h"

@interface WiFiUploadFileManager ()
{
    HTTPServer *_httpServer;
}
@end
@implementation WiFiUploadFileManager

- (void)startHttpServer
{
    _httpServer = [[HTTPServer alloc] init];
//    [_httpServer setType:@"_http._tcp."];
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    [_httpServer setDocumentRoot:webPath];
    [_httpServer setConnectionClass:[WiFiUploadHTTPConnection class]];
    [_httpServer setPort:8091];
    NSError *error;
    if ([_httpServer start:&error]) {
        UInt16 port = [_httpServer listeningPort];
        NSString *ipAddress = [NSString currentIpAddress];
        ZFQLog(@"启动成功,端口号为:%@:%hu",ipAddress,port);
        ipAddress = [NSString stringWithFormat:@"%@:%i",ipAddress,port];
        if (self.ipAddressBlk) {
            self.ipAddressBlk(ipAddress);
        }
    } else {
        ZFQLog(@"启动失败:%@",error);
        if (self.ipAddressBlk) {
            self.ipAddressBlk(@"失败");
        }
    }
}

- (void)stopHttpServer
{
    [_httpServer stop];
}

@end
