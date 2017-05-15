//
//  ZFQServiceContext.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQServiceContext.h"
#import "CustomHTTPDataResponse.h"
#import "ZFQAllResponseService.h"

@interface ZFQServiceContext()
@property (nonatomic, strong) NSMutableArray<id<ZFQConnectionProtocol> > *serviceList;
@property (nonatomic, strong) NSMutableDictionary *serviceDict;
@end
@implementation ZFQServiceContext

#pragma mark - Public
- (NSObject<HTTPResponse> *)responseForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{    
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service matchMethod:method path:path request:request]) {
            NSObject<HTTPResponse> *response = [service httpResponse];
            
            //add filter
            NSObject<HTTPResponse> *finalResponse = [self doFilterForMethod:method path:path request:request originResponse:response];
            return finalResponse;
        }
    }
    return [self configResponseWithMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service supportMethod:method path:path]) {
            return YES;
        }
    }
    
    return [self configWithMethod:method path:path];
}

- (void)addService:(id<ZFQConnectionProtocol>)service
{
    if (!_serviceList) {
        _serviceList = [[NSMutableArray alloc] init];
    }
    if (!_serviceDict) {
        _serviceDict = [[NSMutableDictionary alloc] init];
    }
    [_serviceList addObject:service];
    [_serviceDict setObject:service forKey:NSStringFromClass(service.class)];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service respondsToSelector:@selector(expectsRequestBodyFromMethod:atPath:)]) {
            if ([service expectsRequestBodyFromMethod:method atPath:path]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)processStartOfPartWithHeader:(MultipartMessageHeader*)header
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service respondsToSelector:@selector(processStartOfPartWithHeader:)]) {
            [service processStartOfPartWithHeader:header];
            self.fileHandle = [(ZFQUploadFileService *)service fileHandle];
            break;
        }
    }
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service respondsToSelector:@selector(processEndOfPartWithHeader:)]) {
            [service processEndOfPartWithHeader:header];
            break;
        }
    }
}

- (void)finishBody:(NSData *)bodyData
{
    for (id<ZFQConnectionProtocol> service in self.serviceList) {
        if ([service respondsToSelector:@selector(finishBody:)]) {
            [service finishBody:bodyData];
            break;
        }
    }
}

#pragma mark - Private
- (NSObject<HTTPResponse> *)doFilterForMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request originResponse:(NSObject<HTTPResponse> *)originResponse
{
    if ([originResponse isKindOfClass:[CustomHTTPAsynDataResponse class]]) {
        CustomHTTPAsynDataResponse *customResponse = (CustomHTTPAsynDataResponse *)originResponse;

        //Handle possible Ajax cross-domain issues
        if ([request.allHeaderFields objectForKey:@"Origin"]) {
            customResponse.customHttpHeader[@"Access-Control-Allow-Origin"] = @"*";
        }
        
        //Add the necessary setting blew
        return customResponse;
    }
    return originResponse;
}

- (NSString *)boundaryForRequest:(HTTPMessage *)request
{
    //find out boundary string
    NSString *contentType = [request headerField:@"Content-Type"];
    if (contentType == nil) return nil;
    
    NSString *pattern = @"boundary=-+[a-zA-Z0-9]+";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *result = [reg matchesInString:contentType options:NSMatchingReportCompletion range:NSMakeRange(0, contentType.length)];
    if (result.count > 0) {
        NSTextCheckingResult *checkResult = result.firstObject;
        NSRange range = [checkResult range];
        NSString *subStr = [contentType substringWithRange:range];
        NSString *boundary = [subStr substringFromIndex:9];
        return boundary;
    }
    return nil;
}

- (BOOL)configWithMethod:(NSString *)method path:(NSString *)path
{
    if ([method isEqualToString:@"OPTIONS"]) {
        return YES;
    }
    return NO;
}

- (NSObject<HTTPResponse> *)configResponseWithMethod:(NSString *)method path:(NSString *)path
{
    if ([method isEqualToString:@"OPTIONS"]) {
        CustomSyncDataResponse *response = [[CustomSyncDataResponse alloc] initWithData:nil];
        response.customHttpHeader[@"Access-Control-Allow-Origin"] = @"*";
        response.customHttpHeader[@"Access-Control-Allow-Methods"] = @"POST, GET, OPTIONS";
        response.customHttpHeader[@"Access-Control-Max-Age"] = @"86400";
        return response;
    }
    return nil;
}

@end
