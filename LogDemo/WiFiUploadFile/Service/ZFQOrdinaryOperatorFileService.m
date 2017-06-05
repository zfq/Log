//
//  ZFQOrdinaryDownloadFileService.m
//  LogDemo
//
//  Created by _ on 05/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQOrdinaryOperatorFileService.h"
#import "CustomHTTPFileResponse.h"
#import "CustomHTTPDataResponse.h"
#import "CustomHTTPFileResponse.h"
#import "ZFQLog.h"
#import "ServerResponseItem.h"

@interface ZFQOrdinaryOperatorFileService()
{
    NSString *_method;
    NSString *_currPath;
}
@property (nonatomic, strong) CustomHTTPAsynFileResponse *response;
@property (nonatomic, strong) CustomHTTPAsynDataResponse *dataResponse;
@end

@implementation ZFQOrdinaryOperatorFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    _method = method;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    NSString *beginRoot = @"/disk";
    if ([path rangeOfString:beginRoot].location != 0) {
        return NO;
    } else {
        path = [path substringFromIndex:beginRoot.length];
    }
    
    BOOL isDir = NO;
    _currPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_currPath isDirectory:&isDir] && isDir == NO) {
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
        
        self.response.myFilePath = _currPath;
        [self.response processResponseComplete];
        
        return self.response;
    } else if ([_method isEqualToString:@"DELETE"]) {
        self.dataResponse = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
        [[NSFileManager defaultManager] removeItemAtPath:_currPath error:nil];
        ServerResponseItem *item = [ServerResponseItem responseItem];
        item.errorMsg = @"删除成功";
        item.errorCode = 0;
        self.dataResponse.customData = [item jsonData];
        [self.dataResponse processResponseComplete];
        return self.dataResponse;
    }
        
    return nil;
}

@end
