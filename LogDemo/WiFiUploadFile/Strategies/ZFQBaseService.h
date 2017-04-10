//
//  ZFQBaseService.h
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"
#import <CocoaHTTPServer/HTTPMessage.h>

@interface ZFQBaseService : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) HTTPMessage *request;

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request;
- (NSObject<HTTPResponse> *)httpResponse;

@end
