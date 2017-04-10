//
//  ZFQBaseService.h
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQConnectionProtocol.h"

@interface ZFQBaseService : NSObject <ZFQConnectionProtocol>

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *path;

@end
