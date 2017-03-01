//
//  NSString+IPAddress.m
//  LogDemo
//
//  Created by _ on 17/2/8.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "NSString+IPAddress.h"
#include <netdb.h>
#import <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#import <ZFQLog.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation NSString (IPAddress)

+ (NSString *)currentIpAddress
{
    char hostName[128];
    
    gethostname(hostName, sizeof(hostName));
    struct hostent *hent = gethostbyname(hostName);
    if (hent == NULL) {
        //使用另一种获取ip地址的方法
        return [self getIpAddressMethod1];
    }
    ZFQLog(@"hostname: %@\n",[NSString stringWithUTF8String:hent->h_name]);
    
    char *ipAddress = NULL;
    for (NSInteger i = 0; hent -> h_addr_list[i]; i++) {

        struct in_addr addr = *(struct in_addr *)(hent->h_addr_list[i]);
        ipAddress = inet_ntoa(addr);
        
        ZFQLog(@"%@\n", [NSString stringWithUTF8String:ipAddress]);
    }
    
    return [NSString stringWithUTF8String:ipAddress];
}

//通过枚举网卡来获取IP地址
+ (NSString *)getIpAddressMethod1
{
    [self getWifiName:^(NSString *wifiName) {
        NSLog(@"wifi名称为:%@",wifiName);
    }];
    
    struct ifaddrs *ifAddrStruct = NULL;
    void * tmpAddrPtr = NULL;
    
    getifaddrs(&ifAddrStruct);
    
    while (ifAddrStruct != NULL) {
        if (ifAddrStruct->ifa_addr->sa_family == AF_INET) {
            tmpAddrPtr = &((struct sockaddr_in *)ifAddrStruct->ifa_addr)->sin_addr;
            char addressBuffer[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);
            
            printf("名称：%s,ip地址为:%s\n",ifAddrStruct->ifa_name,addressBuffer);
        } else if (ifAddrStruct->ifa_addr->sa_family == AF_INET6) {
            tmpAddrPtr = &((struct sockaddr_in *)ifAddrStruct->ifa_addr)->sin_addr;
            char addressBuffer[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, tmpAddrPtr, addressBuffer, INET6_ADDRSTRLEN);
            printf("名称：%s，ipv6地址为:%s\n",ifAddrStruct->ifa_name,addressBuffer);
        }
        
        ifAddrStruct = ifAddrStruct->ifa_next;
    }
    
    freeifaddrs(ifAddrStruct);
    return @"";
}

+ (void)getWifiName:(void (^)(NSString *wifiName))blk
{
    //异步获取wifi名称,注意模拟器无法获取wifi名称
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSArray *ifs = (__bridge_transfer NSArray *)(CNCopySupportedInterfaces());
        NSDictionary *info = nil;
        for (NSString *ifnam in ifs) {
            info = (__bridge_transfer NSDictionary *)(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
            if (info) {
                break;
            }
        }
        
        NSString *wifiName = info[(__bridge_transfer NSString *)(kCNNetworkInfoKeySSID)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (blk) {
                blk(wifiName);
            }
        });
    });
}

@end
