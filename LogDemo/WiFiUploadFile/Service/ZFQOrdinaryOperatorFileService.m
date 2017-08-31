//
//  ZFQOrdinaryDownloadFileService.m
//  LogDemo
//
//  Created by _ on 05/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQOrdinaryOperatorFileService.h"
#import <CocoaHTTPServer/MultipartMessageHeaderField.h>
#import "CustomHTTPFileResponse.h"
#import "CustomHTTPDataResponse.h"
#import "CustomHTTPFileResponse.h"
#import "ServerResponseItem.h"
#import "ZFQLog.h"

@interface ZFQOrdinaryOperatorFileService()
{
    NSString *_method;
    NSString *_currPath;
	NSString *_beginRoot;
}
@property (nonatomic, strong) CustomHTTPAsynFileResponse *response;
//@property (nonatomic, strong) CustomHTTPAsynDataResponse *dataResponse;
@end

@implementation ZFQOrdinaryOperatorFileService

- (instancetype)init
{
	self = [super init];
	if (self) {
		_beginRoot = @"/disk";
	}
	return self;
}

- (BOOL)matchMethod:(NSString *)method path:(NSString *)path request:(HTTPMessage *)request
{
    _method = method;
    return [self supportMethod:method path:path];
}

- (BOOL)supportMethod:(NSString *)method path:(NSString *)path
{
    NSString *beginRoot = _beginRoot;
    if ([path rangeOfString:beginRoot].location != 0) {
        return NO;
    } else {
        path = [path substringFromIndex:beginRoot.length];
    }
    
    _currPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
	return YES;
}

/**
 返回文件夹中的所有的文件信息，如果文件夹路径不存在，则返回空数组

 @param dirPath 文件夹路径
 @return 包含所有文件信息的数组
 */
- (NSArray *)fileInfosWithDirPath:(NSString *)dirPath
{
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *infoArray = [[NSMutableArray alloc] init];
	
	NSArray<NSString *> *fileNames = [fileManager contentsOfDirectoryAtPath:dirPath error:&error];
	for (NSString *tmpName in fileNames) {
		//忽略隐藏文件
		if ([[tmpName substringToIndex:1] isEqualToString:@"."]) {
			continue;
		}
		NSString *tmpPath = [dirPath stringByAppendingPathComponent:tmpName];
		error = nil;
		NSDictionary *itemAttr = [fileManager attributesOfItemAtPath:tmpPath error:&error];
		if (error) {
			NSLog(@"%@",error);
		} else {
			BOOL isDir = [itemAttr[NSFileType] isEqualToString:NSFileTypeDirectory];
			if (itemAttr != nil) {
				NSDictionary *info = @{
									   @"name":tmpName,
									   @"size":itemAttr[NSFileSize],
									   @"isDir":[NSString stringWithFormat:@"%i",isDir],
									   @"type":[tmpName pathExtension],
									   @"path":tmpPath
									   };
				[infoArray addObject:info];
			}
		}
	}
	
	return infoArray;
}

- (NSObject<HTTPResponse> *)httpResponse
{
    //Download file
    if ([_method isEqualToString:@"GET"]) {
        _response = [[CustomHTTPAsynFileResponse alloc] initWithConnection:self.currConnection];
		
		//Checking if the file exists.
		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL isDir = NO;
		BOOL exist = [fileManager fileExistsAtPath:_currPath isDirectory:&isDir];
		if (exist == NO) {
			ServerResponseItem *item = [ServerResponseItem responseItem];
			item.errorMsg = @"文件不存在";
			item.errorCode = 404;
			_response.customData = [item jsonData];
			[_response processResponseComplete];
			return _response;
		} else {
			if (isDir == NO) {
				//return file
				_response.myFilePath = _currPath;
				[_response processResponseComplete];
				return _response;
			} else {
				//return file list info
				CustomHTTPAsyncDataResponse *response = [[CustomHTTPAsyncDataResponse alloc] initWithConnection:self.currConnection];
    
				ServerResponseItem *item = [ServerResponseItem responseItem];
				item.errorCode = 200;
				item.obj = [self fileInfosWithDirPath:_currPath];
				response.customData = [item jsonData];
				response.customHttpHeader[@"Content-Type"] = @"application/json; charset=utf-8";
				
				//mark as complete
				[response processResponseComplete];
				return response;
			}
		}
    }
	
	if ([_method isEqualToString:@"DELETE"]) {
        CustomHTTPAsyncDataResponse *response = [[CustomHTTPAsyncDataResponse alloc] initWithConnection:self.currConnection];
        [[NSFileManager defaultManager] removeItemAtPath:_currPath error:nil];
        ServerResponseItem *item = [ServerResponseItem responseItem];
        item.errorMsg = @"删除成功";
        item.errorCode = 0;
        response.customData = [item jsonData];
        [response processResponseComplete];
        return response;
    }
	
	if ([_method isEqualToString:@"POST"]) {
		//将文件上传到当前路径下面
		
		
		CustomHTTPAsyncDataResponse *response = [[CustomHTTPAsyncDataResponse alloc] initWithConnection:self.currConnection];
		[[NSFileManager defaultManager] removeItemAtPath:_currPath error:nil];
		ServerResponseItem *item = [ServerResponseItem responseItem];
		item.errorMsg = @"删除成功";
		item.errorCode = 0;
		response.customData = [item jsonData];
		[response processResponseComplete];
		return response;
	}
	
    return nil;
}

#pragma mark - upload file
#warning 上传文件尚未实现！！！！
- (void)processStartOfPartWithHeader:(MultipartMessageHeader *)header
{
	if (![_method isEqualToString:@"POST"]) {
		return;
	}
	
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
	if (![_method isEqualToString:@"POST"]) {
		return;
	}
	
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
