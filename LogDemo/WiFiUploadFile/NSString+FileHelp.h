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


/**
 Create a directory in document path, if directory already exist in document path or created failed, it will return nil.

 @param dirName new directory name
 @return new directory path
 */
+ (NSString *)createDirInDocumentPathWithName:(NSString *)dirName;

/**
 Create file in dirPath, if a file already exists at path, this method not overwrites and just return file path.
 
 @param fileName file name.
 @param dirPath directory path.
 @return The path for the new file.
 */
+ (NSString *)createFile:(NSString *)fileName atDirPath:(NSString *)dirPath;

/**
 Separate query string into dictionary, if query is empty ,it's return nil.

 @return dictionay,
 */
- (NSDictionary *)queryParams;

/**
 Parse key-value pairs from URI string, this method may be return nil if a string doesn't contain any valid key-value pairs.

 @param servicePath path string which is between character '/' and first character '?'.
 @return dictionary that contained all valid key-value pairs.
 */
- (NSDictionary *)queryParamsWithServicePath:(NSString *)servicePath;

@end
