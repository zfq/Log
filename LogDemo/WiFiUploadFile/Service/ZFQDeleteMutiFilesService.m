//
//  ZFQDeleteMutiFilesService.m
//  LogDemo
//
//  Created by _ on 15/05/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQDeleteMutiFilesService.h"
#import "CustomHTTPDataResponse.h"

@interface ZFQDeleteMutiFilesService()
{
    NSString *_method;
    HTTPMessage *_request;
    NSArray *_fileList;
}
@property (nonatomic, strong) CustomHTTPAsynDataResponse *dataResponse;
@end
@implementation ZFQDeleteMutiFilesService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    _method = method;
    _request = request;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/delete"]) {
        return YES;
    }
    return NO;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    //Delete file
    self.dataResponse = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
    
    [self.fileManger removeFileWithFileIds:_fileList successBlk:^{
        ServerResponseItem *item = [ServerResponseItem responseItem];
        item.errorMsg = @"删除成功";
        item.errorCode = 0;
        self.dataResponse.customData = [item jsonData];
        [self.dataResponse processResponseComplete];
    }];

    return self.dataResponse;
}

- (void)finishBody:(NSData *)bodyData
{
    if (bodyData != nil) {
        /* //form data
        NSString *queryStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        NSArray *keyValues = [queryStr componentsSeparatedByString:@"&"];
        NSMutableDictionary *formDatas = [NSMutableDictionary dictionaryWithCapacity:keyValues.count];
        for (NSString *str in keyValues) {
            NSArray *tmpArray = [str componentsSeparatedByString:@"="];
            if (tmpArray.count == 2) {
                [formDatas setObject:tmpArray[1] forKey:tmpArray[0]];
            }
        }
         */
        
        //json data
        _fileList = [NSJSONSerialization JSONObjectWithData:bodyData options:0 error:nil];
    }
}

@end
