//
//  ZFQUploadFile.h
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"
#import <CocoaHTTPServer/MultipartMessageHeader.h>
#import "CustomHTTPDataResponse.h"
#import "ZFQBaseService.h"

@interface ZFQUploadFileService : ZFQBaseService<ZFQConnectionProtocol>

@property (nonatomic, strong) HTTPMessage *request;

@property (nonatomic, strong) NSFileHandle *fileHandle;

@property (nonatomic, strong) CustomHTTPAsynDataResponse *response;

@end
