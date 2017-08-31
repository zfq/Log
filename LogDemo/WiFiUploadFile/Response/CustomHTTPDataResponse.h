//
//  CustomHTTPDataResponse.h
//  LogDemo
//
//  Created by _ on 17/2/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <CocoaHTTPServer/HTTPConnection.h>

//Asynchronize data response
@interface CustomAsyncDataResponse : HTTPDataResponse
@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;
@end

//Synchronize data response
@interface CustomHTTPAsyncDataResponse : NSObject <HTTPResponse>

@property (nonatomic, copy) NSData *customData;
@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;

- (instancetype)initWithConnection:(HTTPConnection *)connection;

/**
 This method must be called after you ready response data.
 */
- (void)processResponseComplete;

@end
