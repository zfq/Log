//
//  ZFQConnectionProtocol.h
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZFQConnectionProtocol <NSObject>

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path;

@end
