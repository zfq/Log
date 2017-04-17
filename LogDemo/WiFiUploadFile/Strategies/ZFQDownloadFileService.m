//
//  ZFQDownloadFileService.m
//  LogDemo
//
//  Created by _ on 17/4/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQDownloadFileService.h"
#import "CustomHTTPFileResponse.h"

@interface ZFQDownloadFileService()
{
    NSString *_currFileName;
}
@end
@implementation ZFQDownloadFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    NSDictionary *queryParam = [path queryParamsWithServicePath:@"file"];
    if (queryParam == nil || queryParam.count == 0) return NO;

    _currFileName = queryParam[@"name"];
    if (_currFileName != nil) {
        return YES;
    }
    return NO;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    //Checking to see if file exists.
    if (true) {
        //get file path   virtual folder
        /*
         数据库表
         虚拟路径（不包括文件名） | 文件名
         */
//        NSString *filePath = [];
        CustomHTTPFileResponse *response = [[CustomHTTPFileResponse alloc] initWithFilePath:@"" forConnection:nil];
        return response;
    } else {
        return nil;
    }
}

@end
