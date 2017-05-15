//
//  ZFQUploadFile.m
//  LogDemo
//
//  Created by zhaofuqiang on 2017/4/10.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ZFQUploadFileService.h"
#import "NSString+FileHelp.h"
#import <CocoaHTTPServer/MultipartMessageHeaderField.h>
#import "ZFQFileManager.h"
#import "ServerResponseItem.h"
#import <ZFQLog.h>

@interface ZFQUploadFileService()
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
    self.response = [[CustomHTTPAsynDataResponse alloc] initWithConnection:self.currConnection];
    
    return self.response;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    return [self supportMethod:method path:path];
}

- (void)processStartOfPartWithHeader:(MultipartMessageHeader *)header
{
    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *fileName = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    if (!disposition || !fileName) {
        return;
    }
    
    //create file at directory
    NSString *fileRelativePath = @"wifiFile";
    NSString *wifiFileDirPath = [NSString createDirInDocumentPathWithName:fileRelativePath];
    NSString *fileAbsolutePath = [NSString createFile:fileName atDirPath:wifiFileDirPath];
    
    //get fileHandle
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileAbsolutePath];
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *fileName = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    if (!disposition || !fileName) {
        return;
    }
    
    //create file at directory
    NSString *fileRelativePath = @"wifiFile";
    NSString *wifiFileDirPath = [NSString createDirInDocumentPathWithName:fileRelativePath];
    NSString *fileAbsolutePath = [NSString createFile:fileName atDirPath:wifiFileDirPath];
    
    if (fileAbsolutePath) {
        [self.fileManger addFileWithName:fileName path:fileRelativePath].then(^(id value){
            ServerResponseItem *item = [ServerResponseItem responseItem];
            item.errorMsg = @"success";
            self.response.customData = [item jsonData];
            [self.response processResponseComplete];
        }).catch(^(NSError *error){
            ServerResponseItem *item = [ServerResponseItem responseItem];
            item.errorMsg = [error localizedDescription];
            item.errorCode = 500;
            self.response.customData = [item jsonData];
            [self.response processResponseComplete];
            ZFQLog(@"%@",error);
        });
    }

}
@end
