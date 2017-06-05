//
//  ZFQOrdinaryFileListService.m
//  LogDemo
//
//  不用数据库 只读取文件夹
//
//  Created by _ on 05/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQOrdinaryFileListService.h"
#import "CustomHTTPDataResponse.h"
#import "NSString+FileHelp.h"
#import "ServerResponseItem.h"

@interface ZFQOrdinaryFileListService()
{
    NSArray *_infoArray;
}
@end
@implementation ZFQOrdinaryFileListService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    self.request = request;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    if ([method isEqualToString:@"GET"]) {
        _infoArray = [self fileInfosInPath:path];
        if (!_infoArray) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)fileInfosInPath:(NSString *)path
{
    NSString *beginRoot = @"/disk";
    if ([path rangeOfString:beginRoot].location != 0) {
        return nil;
    } else {
        path = [path substringFromIndex:beginRoot.length];
    }

    NSString *currPath = [NSHomeDirectory() stringByAppendingString:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //如果是个文件 就不处理它
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:currPath isDirectory:&isDir] && isDir == NO) {
        return nil;
    }
    
    NSError *error = nil;
    
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    NSArray<NSString *> *fileNames = [fileManager contentsOfDirectoryAtPath:currPath error:&error];
    for (NSString *tmpName in fileNames) {
        if ([[tmpName substringToIndex:1] isEqualToString:@"."]) {
            continue;
        }
        NSString *tmpPath = [currPath stringByAppendingPathComponent:tmpName];
        error = nil;
        NSDictionary *itemAttr = [fileManager attributesOfItemAtPath:tmpPath error:&error];
        if (error) {
            NSLog(@"%@",error);
        } else {
            BOOL isDir = [itemAttr[NSFileType] isEqualToString:NSFileTypeDirectory];
            if (itemAttr != nil) {
                NSDictionary *info = @{
                                       @"name":[path lastPathComponent],
                                       @"fileId":@"-1",
                                       @"size":itemAttr[NSFileSize],
                                       @"isDir":[NSString stringWithFormat:@"%i",isDir],
                                       @"type":[path pathExtension],
                                       @"path":tmpPath
                                       };
                [infoArray addObject:info];
            }
        }
    }
    
    return infoArray;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    CustomHTTPAsynDataResponse *response = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
    
    ServerResponseItem *item = [ServerResponseItem responseItem];
    item.errorCode = 200;
    item.obj = _infoArray;
    response.customData = [item jsonData];
    
    response.customHttpHeader[@"Content-Type"] = @"application/json; charset=utf-8";
    
    //mark as complete
    [response processResponseComplete];
    
    return response;
}

@end
