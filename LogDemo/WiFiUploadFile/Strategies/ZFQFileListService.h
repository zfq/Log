//
//  ZFQFileListService.h
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"

@interface ZFQFileListService : NSObject<ZFQConnectionProtocol>

@property (nonatomic, strong) HTTPMessage *request;

@end
