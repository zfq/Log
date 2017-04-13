//
//  CustomHTTPDataResponse.h
//  LogDemo
//
//  Created by _ on 17/2/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <CocoaHTTPServer/HTTPDataResponse.h>

@interface CustomHTTPDataResponse : HTTPDataResponse

@property (nonatomic, strong) NSMutableDictionary *customHttpHeader;

@end
