//
//  ZFQServiceContext.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQServiceContext.h"
#import "CustomHTTPDataResponse.h"

@interface ZFQServiceContext()
@property (nonatomic, strong) NSMutableArray<id<ZFQConnectionProtocol> > *serviceList;
@end
@implementation ZFQServiceContext

#pragma mark - Public
- (NSObject<HTTPResponse> *)responseForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{    
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service matchMethod:method path:path request:request]) {
            NSObject<HTTPResponse> *response = [service httpResponse];
            
            //添加过滤器
//            NSObject<HTTPResponse> *finalResponse = [self doFilterForMethod:method path:path originResponse:response];
//            return finalResponse;
            return response;
        }
    }
    return nil;
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service supportMethod:method path:path]) {
            return YES;
        }
    }
    return NO;
}

- (void)addService:(id<ZFQConnectionProtocol>)service
{
    if (!_serviceList) {
        _serviceList = [[NSMutableArray alloc] init];
    }
    [_serviceList addObject:service];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service respondsToSelector:@selector(expectsRequestBodyFromMethod:atPath:)]) {
            if ([service expectsRequestBodyFromMethod:method atPath:path]) {
                [self setBoundaryHeaderFieldForRequest];
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)contentTypeForPath:(NSString *)path
{
    NSString *fileType = [path pathExtension];
    return [self contentTypeForFileType:fileType];
}

#pragma mark - Private
- (NSObject<HTTPResponse> *)doFilterForMethod:(NSString *)method path:(NSString *)path originResponse:(NSObject<HTTPResponse> *)originResponse
{
    if ([originResponse isKindOfClass:[CustomHTTPDataResponse class]]) {
        CustomHTTPDataResponse *customResponse = (CustomHTTPDataResponse *)originResponse;
        NSMutableDictionary *mutiDict = nil;
        if (customResponse.customHttpHeader == nil) {
            mutiDict = [[NSMutableDictionary alloc] init];
        } else {
            mutiDict = [[NSMutableDictionary alloc] initWithDictionary:customResponse.customHttpHeader];
        }
        
        //设置Content-Type
        NSString *contentType = [self contentTypeForPath:path];
        if (contentType) {
            mutiDict[@"Content-Type"] = contentType;
        }
        customResponse.customHttpHeader = mutiDict;
        
        return customResponse;
    }
    return originResponse;
}

- (NSString *)contentTypeForFileType:(NSString *)fileType
{
    if (fileType.length == 0) return nil;
    
    if ([fileType isEqualToString:@"css"]) {
        return @"text/css; charset=utf-8";
    } else if ([fileType isEqualToString:@"js"]) {
        return @"application/javascript";
    }
    return nil;
}

- (void)setBoundaryHeaderFieldForRequest
{
    //获取boundary
    NSString *contentType = [self.request headerField:@"Content-Type"];
    NSString *pattern = @"boundary=-+[a-zA-Z0-9]+";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *result = [reg matchesInString:contentType options:NSMatchingReportCompletion range:NSMakeRange(0, contentType.length)];
    if (result.count > 0) {
        NSTextCheckingResult *checkResult = result.firstObject;
        NSRange range = [checkResult range];
        NSString *subStr = [contentType substringWithRange:range];
        NSString *boundary = [subStr substringFromIndex:9];
        [self.request setHeaderField:@"boundary" value:boundary];
    }
}

@end
