//
//  NSObject+ZFQUnresolvedSelector.m
//  LogDemo
//
//  Created by _ on 12/06/2017.
//  Copyright © 2017 zhaofuqiang. All rights reserved.
//

#import "NSObject+ZFQUnresolvedSelector.h"
#import "ZFWCrashProtect.h"
#import <objc/runtime.h>

@implementation NSObject (ZFQUnresolvedSelector)

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *selStr = NSStringFromSelector(aSelector);
    NSString *clsName = NSStringFromClass([self class]);
    if ([clsName hasPrefix:@"_"]
        || [self isKindOfClass:NSClassFromString(@"UITextInputController")]
        || [clsName hasPrefix:@"UIKeyboard"]
        || [selStr isEqualToString:@"dealloc"]) {
        return nil;
    }
    
    ZFWCrashProtect *protect = [[ZFWCrashProtect alloc] init];
    NSString *crashMessage = [NSString stringWithFormat:@"[%@ %@]:unrecognized selector to instance",self,NSStringFromSelector(aSelector)];
    protect.crashMessage = crashMessage;
    IMP imp = [protect methodForSelector:@selector(collectionCrashMessage)];
    class_addMethod([ZFWCrashProtect class], aSelector, imp, "v@:");
    return protect;
}

@end
