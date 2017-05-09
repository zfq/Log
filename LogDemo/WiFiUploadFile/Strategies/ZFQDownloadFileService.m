//
//  ZFQDownloadFileService.m
//  LogDemo
//
//  Created by _ on 17/4/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQDownloadFileService.h"
#import "CustomHTTPFileResponse.h"
#import "CustomHTTPDataResponse.h"
#import "CustomHTTPAsynFileResponse.h"
#import <FMDB.h>
#import <ZFQLog.h>

@interface ZFQDownloadFileService()
{
    NSString *_method;
    NSString *_currFileId;
}
@property (nonatomic, strong) CustomHTTPAsynFileResponse *response;
@property (nonatomic, strong) CustomHTTPAsynDataResponse *dataResponse;
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
            }
        })
        .catch(^(NSError *error){
            ZFQLog(@"Download file error:%@",error);
            
            [self.response processResponseComplete];
        });
        
        return self.response;
    }
    
    //Delete file
    if ([_method isEqualToString:@"DELETE"]) {

        self.dataResponse = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
        [self.fileManger removeFileWithFileId:_currFileId].then(^(id value){
            NSLog(@"删除成功");
            NSDictionary *jsonOBj = @{
                                      @"errorCode":@0,
                                      @"msg":@"删除成功"
                                      };
            NSData *data = [NSJSONSerialization dataWithJSONObject:jsonOBj options:0 error:nil];
            self.dataResponse.customData = data;
            [self.dataResponse processResponseComplete];
        });
        return self.dataResponse;
    }
    return nil;
}

@end
