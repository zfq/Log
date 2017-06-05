//
//  ZFQDeleteAllFileService.m
//  LogDemo
//
//  Created by _ on 12/05/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQDeleteAllFileService.h"
#import "CustomHTTPDataResponse.h"
#import "ServerResponseItem.h"

@interface ZFQDeleteAllFileService()
{
    NSString *_method;
    NSString *_currFileId;
}
@property (nonatomic, strong) CustomHTTPAsynDataResponse *dataResponse;
@end
@implementation ZFQDeleteAllFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    _method = method;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/clear"]) {
        return YES;
    }
    return NO;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    //Delete file
    self.dataResponse = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
    [self.fileManger removeAllFile].then(^(id value){
        ServerResponseItem *item = [ServerResponseItem responseItem];
        item.errorMsg = @"删除成功";
        item.errorCode = 0;
        self.dataResponse.customData = [item jsonData];
        [self.dataResponse processResponseComplete];
    });
    return self.dataResponse;
}

@end
