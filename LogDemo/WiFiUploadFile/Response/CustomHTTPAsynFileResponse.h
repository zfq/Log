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

@interface CustomHTTPAsynFileResponse : NSObject<HTTPResponse>

@property (nonatomic, copy) NSString *myFilePath;

- (instancetype)initWithConnection:(HTTPConnection *)connection;


/**
 处理完成时手动调用
 */
- (void)processResponseComplete;

@end
