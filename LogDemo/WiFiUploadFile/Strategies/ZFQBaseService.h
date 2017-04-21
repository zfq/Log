//
//  ZFQBaseService.h
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQFileManager.h"
#import <CocoaHTTPServer/HTTPConnection.h>

@interface ZFQBaseService : NSObject

@property (nonatomic, strong) ZFQFileManager *fileManger;
@property (nonatomic, weak) HTTPConnection *currConnection;

@end
