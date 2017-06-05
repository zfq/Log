//
//  ZFQOrdinaryDownloadFileService.m
//  LogDemo
//
//  Created by _ on 05/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQOrdinaryDownloadFileService.h"
#import "CustomHTTPFileResponse.h"
#import "CustomHTTPDataResponse.h"
#import "CustomHTTPFileResponse.h"
#import "ZFQLog.h"
#import "ServerResponseItem.h"

@interface ZFQOrdinaryDownloadFileService()
{
    NSString *_method;
    NSString *_currPath;
}
@property (nonatomic, strong) CustomHTTPAsynFileResponse *response;
@property (nonatomic, strong) CustomHTTPAsynDataResponse *dataResponse;
@end

@implementation ZFQOrdinaryDownloadFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    _method = method;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    BOOL isDir = NO;
    _currPath = [NSHomeDirectory() stringByAppendingString:path];
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
    }
        
    return nil;
}

@end
