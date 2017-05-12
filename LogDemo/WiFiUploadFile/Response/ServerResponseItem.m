//
//  ServerResponseItem.m
//  LogDemo
//
//  Created by _ on 17/5/9.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ServerResponseItem.h"

#define kSRIErrorCode @"errorCode"
#define kSRIErrorMsg @"msg"

@interface ServerResponseItem()
@property (nonatomic, strong) NSMutableDictionary *responseDict;
@end

@implementation ServerResponseItem

+ (instancetype)defaultResponseItem
{
    ServerResponseItem *item = [[ServerResponseItem alloc] init];
    item.errorCode = 0;
    item.errorMsg = @"";
    
    item.responseDict[kSRIErrorCode] = @(item.errorCode);
    item.responseDict[kSRIErrorMsg] = item.errorMsg;
    
    return item;
}

- (void)setErrorMsg:(NSString *)errorMsg
{
    NSString *msg = @"";
    if ([errorMsg isKindOfClass:[NSString class]])
        msg = [errorMsg copy];
        
    _errorMsg = msg;
    self.responseDict[kSRIErrorMsg] = _errorMsg;
}

- (void)setErrorCode:(NSInteger)errorCode
{
    _errorCode = errorCode;
    self.responseDict[kSRIErrorCode] = @(_errorCode);
}

- (NSMutableDictionary *)responseDict
{
    if (!_responseDict) {
        _responseDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _responseDict;
}

- (void)setObj:(id)obj
{
    _obj = obj;
    if (_obj != nil) {
        self.responseDict[@"obj"] = _obj;
    }
}

- (NSData *)jsonData
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.responseDict options:0 error:nil];
    return data;
}

@end
