//
//  ZFQFileListService.m
//  LogDemo
//
//  Created by _ on 17/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQFileListService.h"
#import "CustomHTTPDataResponse.h"
#import "NSString+FileHelp.h"
#import "ServerResponseItem.h"

@implementation ZFQFileListService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    self.request = request;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    return [method isEqualToString:@"GET"] && [path isEqualToString:@"/files"];
}

- (NSObject<HTTPResponse> *)httpResponse
{    
    CustomHTTPAsynDataResponse *response = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
    
    //查询
    NSString *currPath = @"wifiFile";
    
    [self.fileManger fileListWithPath:currPath].then(^(NSArray *info){
        
        NSMutableArray *infoArray = [[NSMutableArray alloc] initWithCapacity:info.count];
        for (NSDictionary *dict in info) {
            NSString *fileName = dict[@"name"];
            NSString *tmpFilePath = [NSString stringWithFormat:@"%@/%@/%@",[NSString documentPath],currPath,fileName];
            NSDictionary *itemAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpFilePath error:nil];
            BOOL isDir = [itemAttr[NSFileType] isEqualToString:NSFileTypeDirectory];
            if (itemAttr != nil) {
                NSDictionary *info = @{
                                       @"name":fileName,
                                       @"fileId":dict[@"file_id"],
                                       @"size":itemAttr[NSFileSize],
                                       @"isDir":[NSString stringWithFormat:@"%i",isDir],
                                       @"type":[fileName pathExtension]
                                       };
                [infoArray addObject:info];
            }
        }

        ServerResponseItem *item = [ServerResponseItem responseItem];
        item.errorCode = 200;
        item.obj = infoArray;
        response.customData = [item jsonData];
        
        response.customHttpHeader[@"Content-Type"] = @"application/json; charset=utf-8";
        
        //mark as complete
        [response processResponseComplete];
    }).catch(^(NSError *error){

        ServerResponseItem *item = [ServerResponseItem responseItem];
        item.errorCode = 500;
        item.errorMsg = [error localizedDescription];
        item.obj = [NSArray array];
        response.customData = [item jsonData];
        response.customHttpHeader[@"Content-Type"] = @"application/json; charset=utf-8";
        
        //mark as complete
        [response processResponseComplete];
    });
    
    return response;
}

@end
