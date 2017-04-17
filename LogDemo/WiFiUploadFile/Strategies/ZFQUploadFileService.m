//
//  ZFQUploadFile.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQUploadFileService.h"
#import "CustomHTTPDataResponse.h"
#import "NSString+FileHelp.h"
#import <CocoaHTTPServer/MultipartMessageHeaderField.h>
#import "ZFQFileManager.h"

@interface ZFQUploadFileService()
@property (nonatomic, strong) ZFQFileManager *fileManager;
@end

@implementation ZFQUploadFileService

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    self.request = request;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
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
    
    return response;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    return [self supportMethod:method path:path];
}

- (void)createFileWithHeader:(MultipartMessageHeader*) header
{
    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *fileName = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    if (!disposition || !fileName) {
        return;
    }
    
    //create file at directory
    NSString *wifiFileDirPath = [NSString createDirInDocumentPathWithName:@"wifiFile"];
    NSString *filePath = [NSString createFile:fileName atDirPath:wifiFileDirPath];
    if (filePath) {
        __weak typeof(self) weakSelf = self;
        [self.fileManager addFileWithName:fileName path:wifiFileDirPath].then(^(id value){
            //get fileHandle 
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        });
    }
}

- (ZFQFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[ZFQFileManager alloc] init];
    }
    return _fileManager;
}

@end
