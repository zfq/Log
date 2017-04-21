//
//  CustomHTTPFileResponse.h
//  LogDemo
//
//  Created by _ on 17/4/12.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPFileResponse.h>
#import <CocoaHTTPServer/HTTPAsyncFileResponse.h>

@interface CustomHTTPFileResponse : HTTPFileResponse

@property (nonatomic, copy) NSDictionary *customHttpHeader;

@end
