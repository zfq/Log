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

/**
 Insert a piece of data into the table "wifi_file".

 @param fileName File name that is not contain dir path.
 @param path The path where the file is located, this path not contain file name.
 @return An ZFQDBPromise object.
 */
- (ZFQDBPromise *)addFileWithName:(NSString *)fileName path:(NSString *)path;

- (ZFQDBPromise *)executeUpdate:(NSString *)sql;

- (ZFQDBPromise *)executeQuery:(NSString *)sql values:(NSArray *)values;

@end
