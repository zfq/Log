//
//  ZFWCrashProtect.h
//  LogDemo
//
//  Created by _ on 12/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFWCrashProtect : NSObject

@property (nonatomic, strong) NSString *crashMessage;

- (void)collectionCrashMessage;

@end
