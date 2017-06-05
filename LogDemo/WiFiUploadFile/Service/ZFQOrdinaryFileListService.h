//
//  ZFQOrdinaryFileListService.h
//  LogDemo
//
//  Created by _ on 05/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseService.h"

@interface ZFQOrdinaryFileListService : ZFQBaseService<ZFQConnectionProtocol>

@property (nonatomic, strong) HTTPMessage *request;

@end
