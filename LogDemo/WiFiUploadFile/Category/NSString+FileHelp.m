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

+ (NSString *)createDirInDocumentPathWithName:(NSString *)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断wifiFile文件夹是否存在，如果不存在就创建
    NSString *wifiFileDirPath = [[NSString documentPath] stringByAppendingPathComponent:dirName];
    BOOL isDir = NO;
    if ( ![fileManager fileExistsAtPath:wifiFileDirPath isDirectory:&isDir] || !isDir) {
        //创建文件夹
        NSError *error;
        [fileManager createDirectoryAtPath:wifiFileDirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建文件夹失败:%@",error);
            wifiFileDirPath = nil;
        }
    }
    return wifiFileDirPath;
}

+ (NSString *)createFile:(NSString *)fileName atDirPath:(NSString *)dirPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *wifiFileDirPath = dirPath;
    //判断wifiFile文件夹里面的文件是否已经存在,如果不存在就创建文件
    NSString *filePath = [wifiFileDirPath stringByAppendingPathComponent:fileName];
    BOOL isDir = NO;
    BOOL fileExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (fileExist == NO || (fileExist && isDir == YES)) {
        //文件不存在，则先创建文件，再获取fileHandle
        BOOL result = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if (!result) filePath = nil;
    }
    return filePath;
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

- (NSDictionary *)queryParams
{
    if (self.length == 0) return nil;
    
    NSArray *paramPairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *mutiDict = [[NSMutableDictionary alloc] init];
    for (NSString *str in paramPairs) {
        NSArray *keyValuePair = [str componentsSeparatedByString:@"="];
        NSString *key = keyValuePair[0];
        NSString *value = keyValuePair[1];
        if (key.length > 0) {
            value = value ? value : @"";
            [mutiDict setObject:value forKey:key];
        }
    }
    return [mutiDict copy];
}

- (NSDictionary *)queryParamsWithServicePath:(NSString *)servicePath
{
    NSString *pattern = [NSString stringWithFormat:@"^/+%@\?",servicePath];
    NSRegularExpression *regularExp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSRange pathRange = [regularExp rangeOfFirstMatchInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    if (pathRange.length != 0) {
        NSURL *url = [NSURL URLWithString:self];
        return [url.query queryParams];
    }
    return nil;
}

+ (NSString *)contentTypeForPath:(NSString *)path
{
    NSString *fileType = [path pathExtension];
    return [self contentTypeForFileType:fileType];
}

+ (NSString *)contentTypeForFileType:(NSString *)fileType
{
    if (fileType.length == 0) return nil;
    
    if ([fileType isEqualToString:@"css"]) {
        return @"text/css; charset=utf-8";
    } else if ([fileType isEqualToString:@"js"]) {
        return @"application/javascript";
    } else if ([fileType isEqualToString:@"jpg"]) {
        return @"image/jpeg";
    } else if ([fileType isEqualToString:@"png"]) {
        return @"image/png";
    }
    return nil;
}

@end
