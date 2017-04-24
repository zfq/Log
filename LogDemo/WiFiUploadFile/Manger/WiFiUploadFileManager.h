//
//  WiFiUploadFileManager.h
//  LogDemo
//
//  Created by _ on 17/2/8.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiUploadFileManager : NSObject

/**
 获取ip地址成功后的回调
 */
@property (nonatomic, copy) void (^ipAddressBlk)(NSString *ipAddress);

- (void)startHttpServer;
- (void)stopHttpServer;

@end
