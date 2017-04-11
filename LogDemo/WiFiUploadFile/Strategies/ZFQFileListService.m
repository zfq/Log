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

@implementation ZFQFileListService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{    
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    return [method isEqualToString:@"GET"] && [path isEqualToString:@"/files"];
}

- (NSObject<HTTPResponse> *)httpResponse
{
    NSArray *filesInfo = [NSString filesInfoInDocPath];
    if (filesInfo == nil) {
        filesInfo = [NSArray array];
    }
    NSDictionary *jsonObj = @{
                              @"errorCode":@0,
                              @"msg":@"nil",
                              @"obj":filesInfo
                              };
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil];
    CustomHTTPDataResponse *response = [[CustomHTTPDataResponse alloc] initWithData:data];
    response.customHttpHeader = @{
                                  @"Content-Type":@"text/plain; charset=utf-8"
                                  };
    
    return response;
}

@end
