//
//  ZFQServiceContext.h
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"
#import <CocoaHTTPServer/MultipartMessageHeader.h>

@interface ZFQServiceContext : NSObject

@property (nonatomic, strong) HTTPMessage *request;
@property (nonatomic, strong) NSFileHandle *fileHandle;

- (NSObject<HTTPResponse> *)responseForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request;
- (BOOL)supportMethod:(NSString *)method path:(NSString *)path;
- (void)addService:(id<ZFQConnectionProtocol>)service;
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path;
/**
  Content-Type value corresponding to the request path. You can config custom Content-Type value for path which you're interested in.

 @param path request path of client.
 @return the appropriate Content-Type value for this path，if server can't handle this path,it will return nil.
 */
- (NSString *)contentTypeForPath:(NSString *)path;

- (void)processStartOfPartWithHeader:(MultipartMessageHeader*) header;

@end
