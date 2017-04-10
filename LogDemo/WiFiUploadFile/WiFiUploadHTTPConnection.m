//
//  WiFiUploadHTTPConnection.m
//  LogDemo
//
//  Created by _ on 17/2/9.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "WiFiUploadHTTPConnection.h"
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaHTTPServer/MultipartMessageHeaderField.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import "CustomHTTPDataResponse.h"
#import "NSString+FileHelp.h"
#import "ZFQAllResponseService.h"

@interface WiFiUploadHTTPConnection()
{
    MultipartFormDataParser *_parser;
    NSFileHandle *_fileHandle;
    NSMutableString *_filePath;
}
@end
@implementation WiFiUploadHTTPConnection 

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    NSLog(@"%@ %@",method,path);
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    
    if ([path isEqualToString:@"/files"] && [method isEqualToString:@"GET"]) {
        
        return YES;
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    NSLog(@"body:%@ %@",method,path);
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"]) {
        //获取boundary
        NSString *contentType = [request headerField:@"Content-Type"];
        NSString *pattern = @"boundary=-+[a-zA-Z0-9]+";
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [reg matchesInString:contentType options:NSMatchingReportCompletion range:NSMakeRange(0, contentType.length)];
        if (result.count > 0) {
            NSTextCheckingResult *checkResult = result.firstObject;
            NSRange range = [checkResult range];
            NSString *subStr = [contentType substringWithRange:range];
            NSString *boundary = [subStr substringFromIndex:9];
            [request setHeaderField:@"boundary" value:boundary];
        }
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    /*
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"]) {
        NSDictionary *jsonOBj = @{
                                  @"errorCode":@0,
                                  @"msg":@"success"
                                  };
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonOBj options:0 error:nil];
        CustomHTTPDataResponse *response = [[CustomHTTPDataResponse alloc] initWithData:data];
        
        //处理可能的Ajax跨域问题
        if ([request.allHeaderFields objectForKey:@"Origin"]) {
            response.customHttpHeader = @{@"Access-Control-Allow-Origin":@"*"};
        }

        return response;
    }
    
    if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/files"]) {
        
        NSArray *filesInfo = [NSString filesInfoInDocPath];
        if (filesInfo == nil) {
            filesInfo = [NSArray array];
        }
        NSDictionary *jsonOBj = @{
                                  @"errorCode":@0,
                                  @"msg":@"nil",
                                  @"obj":filesInfo
                                  };
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonOBj options:0 error:nil];
        CustomHTTPDataResponse *response = [[CustomHTTPDataResponse alloc] initWithData:data];
        response.customHttpHeader = @{
                                      @"Content-Type":@"text/plain; charset=utf-8"
                                      };
        
        return response;
    }
    */
    
    ZFQServiceContext *context = [[ZFQServiceContext alloc] init];
    [context addService:[[ZFQFileListService alloc] init]];
    [context addService:[[ZFQUploadFileService alloc] init]];
    
    NSObject<HTTPResponse> *responseObj = [context responseForMethod:method path:path request:request];
    if (responseObj) {
        return responseObj;
    }
    
    return [super httpResponseForMethod:method URI:path];
}

//以下两个方法默认是空方法, 类似servlet里面的两个代理方法
- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    //得先获取到boundary
    NSString *boundary = [request headerField:@"boundary"];
    _parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    _parser.delegate = self;
    
    _filePath = [[NSMutableString alloc] init];
}

//如果上传的文件比较大，则这个方法可能会被调用多次
- (void)processBodyData:(NSData *)postDataChunk
{
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [_parser appendData:postDataChunk];
}

#pragma mark - Multipart form data parser delegate 以下的方法在while循环里，可能被调用多次

//如果上传的文件比较大，这个方法可能会被调用多次
- (void)processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    //存数据
    [_fileHandle writeData:data];
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    //关闭文件
    [_fileHandle closeFile];
}

- (void)processPreambleData:(NSData*) data
{
    
}

- (void)processEpilogueData:(NSData*) data
{
    
}

- (void)processStartOfPartWithHeader:(MultipartMessageHeader*) header
{
/* 从post请求体中获取文件名 即从下面的filename中获取
     
    POST /files HTTP/1.1
    Host: 172.16.15.152:8090
    Content-Length: 192
    Origin: http://172.16.15.152:8090
    User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36
    Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryA9YRhDWvIJYzWVXW
    Accept:星/星
    Referer: http://172.16.15.152:8090/
    Accept-Encoding: gzip, deflate
    Accept-Language: zh-CN,zh;q=0.8,en;q=0.6,ko;q=0.4,zh-TW;q=0.2

    ------WebKitFormBoundaryA9YRhDWvIJYzWVXW
    Content-Disposition: form-data; name="file"; filename="f1.txt"
    Content-Type: text/plain

    hello wold!

    ------WebKitFormBoundaryA9YRhDWvIJYzWVXW--
    
*/
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *fileName = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if (!disposition || !fileName) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断wifiFile文件夹是否存在，如果不存在就创建
    NSString *wifiFileDirPath = [[NSString documentPath] stringByAppendingPathComponent:@"wifiFile"];
    BOOL isDir = NO;
    if ( ![fileManager fileExistsAtPath:wifiFileDirPath isDirectory:&isDir] || !isDir) {
        //创建文件夹
        NSError *error;
        [fileManager createDirectoryAtPath:wifiFileDirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建文件夹失败:%@",error);
        }
    }
    
    //判断wifiFile文件夹里面的文件是否已经存在,如果不存在就创建文件
    NSString *filePath = [wifiFileDirPath stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir == NO)
    {
        //文件已经存在，则获取fileHandle
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } else {
        //文件不存在，则先创建文件，再获取fileHandle
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
}

@end
