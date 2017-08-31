//
//  ZFQDownloadFileService.m
//  LogDemo
//
//  Created by _ on 17/4/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQOperatorFileService.h"
#import "CustomHTTPFileResponse.h"
#import "CustomHTTPDataResponse.h"
#import "CustomHTTPFileResponse.h"
#import <FMDB.h>
#import "ZFQLog.h"
#import "ServerResponseItem.h"

@interface ZFQOperatorFileService()
{
    NSString *_method;
    NSString *_currFileId;
}
@property (nonatomic, strong) CustomHTTPAsynFileResponse *response;
@property (nonatomic, strong) CustomHTTPAsyncDataResponse *dataResponse;
@end
@implementation ZFQOperatorFileService

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
    //Download file
    if ([_method isEqualToString:@"GET"]) {
        self.response = [[CustomHTTPAsynFileResponse alloc] initWithConnection:self.currConnection];
        //Checking to see if file exists.
        NSInteger tmpFileId = [_currFileId integerValue];
        [self.fileManger searchFileWithFileId:tmpFileId].then(^(NSArray *result){
            if (result.count > 0) {
                NSDictionary *dict = result[0];
                
                NSString *path = dict[@"path"];
                NSString *fileName = dict[@"name"];
                
                NSMutableString *filePath = [[NSMutableString alloc] init];
                if (path.length > 0) {
                    [filePath appendFormat:@"/%@/%@",path,fileName];
                } else {
                    [filePath appendFormat:@"/%@",fileName];
                }
                
                //
                self.response.myFilePath = [[NSString documentPath] stringByAppendingPathComponent:filePath];
                [self.response processResponseComplete];
            } else {
                ServerResponseItem *item = [ServerResponseItem responseItem];
                item.errorMsg = @"文件不存在";
                item.errorCode = 404;
                self.response.customData = [item jsonData];
                [self.response processResponseComplete];
            }
        })
        .catch(^(NSError *error){
            ZFQLog(@"Download file error:%@",error);
            ServerResponseItem *item = [ServerResponseItem responseItem];
            item.errorMsg = [error localizedDescription];
            self.response.customData = [item jsonData];
            [self.response processResponseComplete];
        });
        
        return self.response;
    }
    
    //Delete file
    if ([_method isEqualToString:@"DELETE"]) {
        self.dataResponse = [[CustomHTTPAsyncDataResponse alloc] initWithConnection:self.currConnection];
        [self.fileManger removeFileWithFileId:_currFileId].then(^(id value){
            ServerResponseItem *item = [ServerResponseItem responseItem];
            item.errorMsg = @"删除成功";
            item.errorCode = 0;
            self.dataResponse.customData = [item jsonData];
            [self.dataResponse processResponseComplete];
        });
        return self.dataResponse;
    }
    
    return nil;
}

@end
