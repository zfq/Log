//
//  ZFQUploadFile.h
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"

@interface ZFQUploadFileService : NSObject<ZFQConnectionProtocol>

@property (nonatomic, strong) HTTPMessage *request;

@end
