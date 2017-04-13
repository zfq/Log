//
//  ZFQDownloadFileService.m
//  LogDemo
//
//  Created by _ on 17/4/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQDownloadFileService.h"
#import "CustomHTTPFileResponse.h"

@interface ZFQDownloadFileService()
{
    NSString *_currFileName;
}
@end
@implementation ZFQDownloadFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    NSDictionary *queryParam = [path queryParamsWithServicePath:@"file"];
    if (queryParam == nil || queryParam.count == 0) return NO;
    
//    NSRegularExpression *regularExp = [NSRegularExpression regularExpressionWithPattern:@"^/+file\?" options:0 error:nil];
//    NSRange pathRange = [regularExp rangeOfFirstMatchInString:path options:NSMatchingReportCompletion range:NSMakeRange(0, path.length)];
//    if (pathRange.length != 0) {
//        NSURL *url = [NSURL URLWithString:path];
//        NSString *queryStr = url.query;
//        NSArray *paramPairs = [queryStr componentsSeparatedByString:@"&"];
//    }
//    
//    NSString *tmpPath = url.path;
    if (queryParam[@"name"] != nil) {
        return YES;
    }
    return NO;
//    return [method isEqualToString:@"GET"] && [path isEqualToString:@"/upload"];
}

- (NSObject<HTTPResponse> *)httpResponse
{
    //Checking to see if file exists.
    
    if (true) {
        CustomHTTPFileResponse *response = [[CustomHTTPFileResponse alloc] initWithFilePath:@"" forConnection:nil];
        return response;
    } else {
        return nil;
    }
}

@end
