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
#import "CustomHTTPFileResponse.h"
#import "NSString+FileHelp.h"
#import "ZFQAllResponseService.h"

@interface WiFiUploadHTTPConnection()
{
    MultipartFormDataParser *_parser;
    NSMutableString *_filePath;
}
@property (nonatomic, strong) ZFQServiceContext *serviceContext;
@end
@implementation WiFiUploadHTTPConnection 

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    NSLog(@"%@ %@",method,path);
    //We only focus on requests that we're interested in
    if ([self.serviceContext supportMethod:method path:path]) {
        return YES;
    }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    NSLog(@"body:%@ %@",method,path);
    
    BOOL expects = [self.serviceContext expectsRequestBodyFromMethod:method atPath:path];
    if (expects) {
        return YES;
    } else {
        return [super expectsRequestBodyFromMethod:method atPath:path];
    }
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    //handler our service
    NSObject<HTTPResponse> *responseObj = [self.serviceContext responseForMethod:method path:path request:request];
    if (responseObj) {
        return responseObj;
    }
    
    //Add additional Content-Type value for Specific file such as css and js etc.
    NSString *contentType = [self.serviceContext contentTypeForPath:path];
    if (contentType) {
        NSString *filePath = [self filePathForURI:path allowDirectory:NO];
        BOOL isDir = NO;
        if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && !isDir)
        {
            CustomHTTPFileResponse *customResponse = [[CustomHTTPFileResponse alloc] initWithFilePath:filePath forConnection:self];
            customResponse.customHttpHeader = @{@"Content-Type":contentType};
            return customResponse;
        }
    }
    
    return [super httpResponseForMethod:method URI:path];
}

- (NSData *)preprocessResponse:(HTTPMessage *)response
{
    //为特定类型的文件设置必要的Content-Type
    /*
    NSString *path = [response url].absoluteString;
    if (path) {
        NSLog(@"成功了:%@",path);
        NSString *contentType = [self.serviceContext contentTypeForPath:path];
        if (contentType) {
            [response setHeaderField:@"Content-Type" value:contentType];
        }
    }*/
    
    return [super preprocessResponse:response];
}

//以下两个方法默认是空方法,
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

- (ZFQServiceContext *)serviceContext
{
    if (!_serviceContext) {
        _serviceContext = [[ZFQServiceContext alloc] init];
        _serviceContext.request = request;
        [self addServiceForServiceContext:_serviceContext];
    }
    return _serviceContext;
}


/**
 Add your custom service for server,you should always add service in this function.

 @param serviceContext serviceContext
 */
- (void)addServiceForServiceContext:(ZFQServiceContext *)serviceContext
{
    [serviceContext addService:[[ZFQFileListService alloc] init]];
    [serviceContext addService:[[ZFQUploadFileService alloc] init]];
    
    ZFQDownloadFileService *downloadService = [[ZFQDownloadFileService alloc] init];
    downloadService.currConnection = self;
    [serviceContext addService:downloadService];
}

#pragma mark - Multipart form data parser delegate 以下的方法在while循环里，可能被调用多次

//如果上传的文件比较大，这个方法可能会被调用多次
- (void)processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    //存数据
    [self.serviceContext.fileHandle writeData:data];
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    //关闭文件
    [self.serviceContext.fileHandle closeFile];
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
    
//    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
//    NSString *fileName = [[disposition.params objectForKey:@"filename"] lastPathComponent];
//    if (!disposition || !fileName) {
//        return;
//    }
//    
//    //create file at directory
//    NSString *wifiFileDirPath = [NSString createDirInDocumentPathWithName:@"wifiFile"];
//    NSString *filePath = [NSString createFile:fileName atDirPath:wifiFileDirPath];
//    
//    //获取fileHandle
//    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [self.serviceContext processStartOfPartWithHeader:header];
}

@end
