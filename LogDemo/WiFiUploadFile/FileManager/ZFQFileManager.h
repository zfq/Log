//
//  ZFQFileManager.h
//  LogDemo
//
//  Created by _ on 17/4/17.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQDBPromise.h"

@interface ZFQFileManager : NSObject

- (ZFQDBPromise *)executeUpdate:(NSString *)sql;

@end
