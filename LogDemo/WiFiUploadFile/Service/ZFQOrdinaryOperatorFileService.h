//
//  ZFQOrdinaryDownloadFileService.h
//  LogDemo
//
//	Access home path of the app.
//
//  Created by _ on 05/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseService.h"

/**
 操作App的home路径，功能包括获取文件列表、下载文件、删除文件
 */
@interface ZFQOrdinaryOperatorFileService : ZFQBaseService<ZFQConnectionProtocol>

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end
