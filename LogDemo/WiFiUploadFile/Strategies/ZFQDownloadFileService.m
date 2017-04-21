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
@property (nonatomic, strong) CustomHTTPAsynFileResponse *response;
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
    //下载文件
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
            }
        })
        .catch(^(NSError *error){
            ZFQLog(@"Download file error:%@",error);
            
            [self.response processResponseComplete];
        });
        
        return self.response;
    }
    
    //删除文件
    if ([_method isEqualToString:@"DELETE"]) {
        //delete file
//        return nil;
    }
    return nil;
}

@end
