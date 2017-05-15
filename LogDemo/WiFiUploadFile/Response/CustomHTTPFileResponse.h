//
//  CustomHTTPAsynFileResponse.h
//  LogDemo
//
//  Created by _ on 17/4/18.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPAsyncFileResponse.h>
#import <CocoaHTTPServer/HTTPResponse.h>
#import <CocoaHTTPServer/HTTPFileResponse.h>

//Synchronize file response.
@interface CustomHTTPSyncFileResponse : HTTPFileResponse

@property (nonatomic, copy) NSDictionary *customHttpHeader;

@end

//Asynchronize file response.
@interface CustomHTTPAsynFileResponse : NSObject<HTTPResponse>

@property (nonatomic, copy) NSString *myFilePath;

/**
 Custom response data,  it's usually used as error response.
 */
@property (nonatomic, strong) NSData *customData;

- (instancetype)initWithConnection:(HTTPConnection *)connection;


/**
  This method must be called after you ready response data.
 */
- (void)processResponseComplete;

@end
