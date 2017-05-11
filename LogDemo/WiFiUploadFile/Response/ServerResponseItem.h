//
//  ServerResponseItem.h
//  LogDemo
//
//  Created by _ on 17/5/9.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerResponseItem : NSObject

@property (nonatomic) NSInteger errorCode;
@property (nonatomic, copy) NSString *errorMsg;

+ (instancetype)defaultResponseItem;

- (NSData *)jsonData;

@end
