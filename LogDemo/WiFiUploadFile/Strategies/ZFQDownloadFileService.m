//
//  ZFQDownloadFileService.m
//  LogDemo
//
//  Created by _ on 17/4/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQDownloadFileService.h"
#import "CustomHTTPFileResponse.h"
#import "CustomHTTPAsynFileResponse.h"
#import <FMDB.h>
#import <ZFQLog.h>

@interface ZFQDownloadFileService()
{
    NSString *_method;
    NSString *_currFileId;
}
@end
@implementation ZFQDownloadFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    _method = method;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    NSDictionary *queryParam = [path queryParamsWithServicePath:@"file"];
    if (queryParam == nil || queryParam.count == 0) return NO;

    _currFileId = queryParam[@"fileId"];
    if (_currFileId != nil) {
        return YES;
    }
    return NO;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    if ([_method isEqualToString:@"GET"]) {
        //Checking to see if file exists.
        [self.fileManger searchFileWithFileId:_currFileId].then(^(FMResultSet *resultSet){
            if (resultSet) {
                NSString *path = [resultSet stringForColumn:@"path"];
                NSString *fileName = [resultSet stringForColumn:@"name"];
                
                NSMutableString *filePath = [[NSMutableString alloc] init];
                if (path.length > 0) {
                    [filePath appendFormat:@"/%@/%@",path,fileName];
                } else {
                    [filePath appendFormat:@"/%@",fileName];
                }

            }
        })
        .catch(^(NSError *error){
            ZFQLog(@"Download file error:%@",error);
        });
        
        
        if (true) {
            //get file path   virtual folder
            /*
             数据库表
             虚拟路径（不包括文件名） | 文件名
             */
            //        NSString *filePath = [];
//            CustomHTTPFileResponse *response = [[CustomHTTPFileResponse alloc] initWithFilePath:@"" forConnection:nil];
//            return response;
            CustomHTTPAsynFileResponse *response = [[CustomHTTPFileResponse alloc] initWithFilePath:@"" forConnection:nil];
            return response;
        } else {
            return nil;
        }
    }
    
    if ([_method isEqualToString:@"DELETE"]) {
        //delete file
//        return nil;
    }
    return nil;
}

@end
