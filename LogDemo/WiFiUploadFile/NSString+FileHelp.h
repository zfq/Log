//
//  NSString+FileHelp.h
//  LogDemo
//
//  Created by _ on 17/4/7.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileHelp)

+ (NSString *)documentPath;
+ (NSArray<NSDictionary *> *)filesInfoInDocPath;
+ (NSArray<NSDictionary *> *)filesInfoAtPath:(NSString *)path;

@end
