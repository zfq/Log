//
//  NSString+FileHelp.m
//  LogDemo
//
//  Created by _ on 17/4/7.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "NSString+FileHelp.h"

@implementation NSString (FileHelp)

+ (NSString *)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSArray<NSDictionary *> *)filesInfoInDocPath
{
    return [self filesInfoAtPath:[self documentPath]];
}

+ (NSArray<NSDictionary *> *)filesInfoAtPath:(NSString *)path
{
    if (!path) { return nil;}
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path] == NO) {return nil;}
    
    NSArray<NSString *> *paths = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *filesInfo = [[NSMutableArray alloc] initWithCapacity:paths.count];
    for (NSString *tmpPath in paths) {
        if ([tmpPath isEqualToString:@".DS_Store"]) {
            continue;
        }
        NSString *tmpFilePath = [path stringByAppendingPathComponent:tmpPath];
        NSDictionary *itemAttr = [fileManager attributesOfItemAtPath:tmpFilePath error:nil];
        BOOL isDir = [itemAttr[NSFileType] isEqualToString:NSFileTypeDirectory];
        [fileManager fileExistsAtPath:tmpFilePath isDirectory:&isDir];
        if (itemAttr != nil) {
            NSDictionary *info = @{
                                   @"path":tmpPath,
                                   @"size":itemAttr[NSFileSize],
                                   @"isDir":[NSString stringWithFormat:@"%i",isDir],
                                   @"type":[tmpPath pathExtension]
                                   };
            [filesInfo addObject:info];
        }
    }
    
    return filesInfo;
}

@end
