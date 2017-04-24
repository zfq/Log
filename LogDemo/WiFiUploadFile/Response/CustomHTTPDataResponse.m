//
//  CustomHTTPDataResponse.m
//  LogDemo
//
//  Created by _ on 17/2/13.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "CustomHTTPDataResponse.h"
#import "NSString+FileHelp.h"

@implementation CustomHTTPDataResponse

- (NSDictionary *)httpHeaders
{
    return self.customHttpHeader;
}

- (NSMutableDictionary *)customHttpHeader
{
    if (!_customHttpHeader) {
        _customHttpHeader = [[NSMutableDictionary alloc] init];
    }
    return _customHttpHeader;
}

@end

@interface CustomHTTPAsynDataResponse ()
{
    __weak HTTPConnection *_myConnection;
    UInt64 _currOffset;
}
/**
 响应是否已经处理完成，响应处理完成后数据开始发送
 */
@property (nonatomic) BOOL responseIsReady;

@end
@implementation CustomHTTPAsynDataResponse

- (instancetype)initWithConnection:(HTTPConnection *)connection
{
    self = [super init];
    if (self) {
        _myConnection = connection;
        _responseIsReady = NO;
    }
    return self;
}

- (UInt64)contentLength
{
    return self.customData.length;
}

- (UInt64)offset
{
    return _currOffset;
}

- (void)setOffset:(UInt64)offset
{
    _currOffset = offset;
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    if (_customData.length == 0) return nil;
    
    UInt64 byteLeftSize = _customData.length - _currOffset;
    UInt64 actualSize = MIN(length, byteLeftSize);
    
    void *bytes = (void *)([_customData bytes] + _currOffset);
    _currOffset += length;
    return [NSData dataWithBytesNoCopy:bytes length:actualSize freeWhenDone:NO];
}

- (BOOL)isDone
{
    return _currOffset == _customData.length;
}

- (BOOL)delayResponseHeaders
{
    return !self.responseIsReady;
}

- (NSDictionary *)httpHeaders
{
    return self.customHttpHeader;
}

#pragma mark - Public
- (void)processResponseComplete
{
    //Setting Content-Type and Content-Disposition
    
    self.responseIsReady = YES;
    [_myConnection responseHasAvailableData:self];
}

#pragma mark - Getter
- (NSMutableDictionary *)customHttpHeader
{
    if (!_customHttpHeader) {
        _customHttpHeader = [[NSMutableDictionary alloc] init];
    }
    return _customHttpHeader;
}

@end
