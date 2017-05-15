//
//  CustomHTTPDataResponse.h
//  LogDemo
//
//  Created by _ on 17/2/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <CocoaHTTPServer/HTTPConnection.h>

//Synchronize data response
@interface CustomSyncDataResponse : HTTPDataResponse
@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;
@end

//Asynchronize data response
@interface CustomHTTPAsynDataResponse : NSObject <HTTPResponse>

@property (nonatomic, copy) NSData *customData;
@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;

- (instancetype)initWithConnection:(HTTPConnection *)connection;

/**
 This method must be called after you ready response data.
 */
- (void)processResponseComplete;

@end
