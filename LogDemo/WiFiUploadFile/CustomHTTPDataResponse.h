//
//  CustomHTTPDataResponse.h
//  LogDemo
//
//  Created by _ on 17/2/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <CocoaHTTPServer/HTTPConnection.h>

@interface CustomHTTPDataResponse : HTTPDataResponse

@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;

@end

@interface CustomHTTPAsynDataResponse : NSObject <HTTPResponse>

@property (nonatomic, copy) NSData *customData;
@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;

- (instancetype)initWithConnection:(HTTPConnection *)connection;

/**
 处理完成时手动调用
 */
- (void)processResponseComplete;

@end
