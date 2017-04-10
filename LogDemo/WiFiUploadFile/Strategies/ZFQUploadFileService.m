//
//  ZFQUploadFile.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQUploadFileService.h"
#import <CocoaHTTPServer/HTTPResponse.h>
#import "NSString+FileHelp.h"

@implementation ZFQUploadFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    [super matchMethod:method path:path request:request];
    
    return [method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"];
}

- (NSObject<HTTPResponse> *)httpResponse
{
    NSDictionary *jsonOBj = @{
                              @"errorCode":@0,
                              @"msg":@"success"
                              };
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonOBj options:0 error:nil];
    CustomHTTPDataResponse *response = [[CustomHTTPDataResponse alloc] initWithData:data];
    
    //处理可能的Ajax跨域问题
    if ([self.request.allHeaderFields objectForKey:@"Origin"]) {
        response.customHttpHeader = @{@"Access-Control-Allow-Origin":@"*"};
    }
    
    return response;
}

@end
