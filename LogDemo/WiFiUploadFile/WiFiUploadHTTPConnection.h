//
//  WiFiUploadHTTPConnection.h
//  LogDemo
//
//  Created by _ on 17/2/9.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <CocoaHTTPServer/HTTPConnection.h>
#import <CocoaHTTPServer/MultipartFormDataParser.h>

@interface WiFiUploadHTTPConnection : HTTPConnection <MultipartFormDataParserDelegate>

@end
