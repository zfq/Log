//
//  ZFQConnectionProtocol.h
//  LogDemo
//
//  Created by _ on 17/4/11.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaHTTPServer/HTTPResponse.h>
#import "NSString+FileHelp.h"

@protocol ZFQConnectionProtocol <NSObject>

@optional
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path;

@required
- (BOOL)supportMethod:(NSString *)method path:(NSString *)path;
- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request;
- (NSObject<HTTPResponse> *)httpResponse;

@end
