//
//  CustomHTTPAsynFileResponse.m
//  LogDemo
//
//  Created by _ on 17/4/18.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "CustomHTTPFileResponse.h"
#import <CocoaHTTPServer/HTTPConnection.h>
#import "NSString+FileHelp.h"
#import <unistd.h>
#import <fcntl.h>
#import "ZFQLog.h"

@implementation CustomHTTPSyncFileResponse

- (NSDictionary *)httpHeaders
{
    return self.customHttpHeader;
}

@end


@interface CustomHTTPAsynFileResponse()
{
    __weak HTTPConnection *_myConnection;
    UInt64 _fileSize;
    UInt64 _fileOffset;
    int _fileHandle;
    void * _buffer;
    UInt64 _currBufferSize;
}

@property (nonatomic) BOOL aborded;

/**
 响应是否已经处理完成，响应处理完成后数据开始发送
 */
@property (nonatomic) BOOL responseIsReady;

/**
 数据是否全部发送
 */
@property (nonatomic) BOOL sendComplete;

@end

@implementation CustomHTTPAsynFileResponse

- (instancetype)initWithConnection:(HTTPConnection *)connection
{
    self = [super init];
    if (self) {
        _myConnection = connection;
        _responseIsReady = NO;
        _aborded = NO;
        _fileHandle = -1;
    }
    return self;
}

#pragma mark - Protocol
- (UInt64)contentLength
{
    if (_customData.length > 0) {
        return _customData.length;
    } else {
        return _fileSize;
    }
}

- (UInt64)offset
{
    return _fileOffset;
}

- (void)setOffset:(UInt64)offset
{
    _fileOffset = offset;
    
    if (self.customData.length > 0) {
        return;
    }
    
    //打开文件
    if ([self openFileIfNeed] == NO) {
        return;
    };
    
    //将文件指针偏移到offset位置
    if (lseek(_fileHandle, offset, SEEK_SET) != offset) {
        ZFQLog(@"偏移文件失败:%d",errno);
        self.aborded = YES;
    }
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    if (self.customData.length > 0) {
        UInt64 byteLeftSize = _customData.length - _fileOffset;
        UInt64 actualSize = MIN(length, byteLeftSize);
        void *bytes = (void *)([_customData bytes] + _fileOffset);
        _fileOffset += length;
        return [NSData dataWithBytesNoCopy:bytes length:actualSize freeWhenDone:NO];
    }
    
    //打开文件
    if ([self openFileIfNeed] == NO) {
        return nil;
    };
    
    //剩余文件大小
    UInt64 bytesLeftSize = _fileSize - _fileOffset;
    //实际需要读取的数据大小
    UInt64 bytesToRead = MIN(length, bytesLeftSize);
    
    //创建buffer
    if (_buffer == NULL || _currBufferSize < bytesToRead) {
        _currBufferSize = bytesToRead;
        _buffer = reallocf(_buffer, bytesToRead);
    }
    
    //从_fileOffset位置读取length个长度
    ssize_t result = read(_fileHandle, _buffer, bytesToRead);
    if (result <= 0) {
        ZFQLog(@"读取文件出错了:result:%zd",result);
        self.aborded = YES;
        return nil;
    } else {
        _fileOffset += result;
        return [NSData dataWithBytes:_buffer length:result];
    }
}

- (BOOL)isDone
{
    if (_customData.length > 0) {
        return _fileOffset = _customData.length;
    } else {
        return _fileOffset == _fileSize;
    }
}

- (BOOL)delayResponseHeaders
{
    //异步响应过程中返回YES,响应完成后返回NO
    if (self.responseIsReady == NO) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)status
{
    return 200;
}

- (BOOL)isChunked
{
    return NO;
}

- (void)connectionDidClose
{
}

- (void)dealloc
{
    if (_fileHandle != -1) {
        close(_fileHandle);
    }
}

- (NSDictionary *)httpHeaders
{
    return self.customHttpHeader;
}

#pragma mark - Public
- (void)processResponseComplete
{
    //获取文件大小
    NSString *tmpFilePath = [self.myFilePath stringByResolvingSymlinksInPath];
    
    if (tmpFilePath) {
        NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpFilePath error:nil];
        if (attr) {
            _fileSize = [[attr objectForKey:NSFileSize] unsignedLongLongValue];
            
            if (!_customHttpHeader) {
                _customHttpHeader = [[NSMutableDictionary alloc] init];
            }
            
            //Setting Content-Type and Content-Disposition
            NSString *fileName = [tmpFilePath lastPathComponent];
            NSString *contentType =  [NSString contentTypeForPath:tmpFilePath];
            if (contentType) {
                _customHttpHeader[@"Content-Type"] = contentType;
            }
            if (fileName.length > 0) {
                _customHttpHeader[@"Content-Disposition"] = [NSString stringWithFormat:@"attachment; filename=%@",fileName];
            } else {
                _customHttpHeader[@"Content-Disposition"] = @"attachment";
            }
        }
    }
    
    self.responseIsReady = YES;
    [_myConnection responseHasAvailableData:self];
}

- (BOOL)openFileIfNeed
{
    //如果之前操作文件出过错，就不用打开文件了
    if (self.aborded) {
        return NO;
    }
    
    //如果文件已经成功打开过
    if (_fileHandle != -1) {
        //Notify the connection that we have new data avaliable for it.
        [_myConnection responseHasAvailableData:self];
        
        return YES;
    }
    _fileHandle = open(_myFilePath.UTF8String, O_RDONLY);
    if (_fileHandle == -1) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setAborded:(BOOL)aborded
{
    _aborded = aborded;
    if (_aborded == YES) {
        [_myConnection responseDidAbort:self];
    }
}

@end
