//
//  ServerResponseItem.m
//  LogDemo
//
//  Created by _ on 17/5/9.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "ServerResponseItem.h"

@interface ServerResponseItem()
@property (nonatomic, strong) NSMutableDictionary *responseDict;
@end

@implementation ServerResponseItem

+ (instancetype)defaultResponseItem
{
    ServerResponseItem *item = [[ServerResponseItem alloc] init];
    item.errorCode = 0;
    item.errorMsg = @"";
    
    item.responseDict[@"errorCode"] = @(item.errorCode);
    item.responseDict[@"errorMsg"] = item.errorMsg;
    
    return item;
}

- (void)setErrorMsg:(NSString *)errorMsg
{
    NSString *msg = @"";
    if ([errorMsg isKindOfClass:[NSString class]])
        msg = [errorMsg copy];
        
    _errorMsg = msg;
    self.responseDict[@"errorCode"] = _errorMsg;
}

- (void)setErrorCode:(NSInteger)errorCode
{
    _errorCode = errorCode;
    self.responseDict[@"errorCode"] = @(_errorCode);
}

- (NSMutableDictionary *)responseDict
{
    if (!_responseDict) {
        _responseDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _responseDict;
}

- (NSData *)jsonData
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.responseDict options:0 error:nil];
    return data;
}

@end
