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
#include <net/if.h>
#import <ZFQLog.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation NSString (IPAddress)

/*
+ (NSString *)currentIpAddress
{
    char hostName[128];
    
    gethostname(hostName, sizeof(hostName));
    
    //getHostByName会阻塞，不要在主线程中调用，getHostByName是已经淘汰的方法，用getaddrinfo来代替
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
}*/

/*
//通过枚举网卡来获取IP地址
+ (NSString *)getIpAddressMethod1
{
//    [self getWifiName:^(NSString *wifiName) {
//        NSLog(@"wifi名称为:%@",wifiName);
//    }];
//    
//    NSString *cellularName = [self cellularProviderName];
//    NSLog(@"%@",cellularName);
    
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
*/

+ (NSString *)currentIpAddress
{
    return [self getIPAddress:YES];
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

/**
 异步获取wifi名称

 @param blk 回调
 */
+ (void)asynGetWifiName:(void (^)(NSString *wifiName))blk
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


/**
 获取运营商的名称

 @return 字符串
 */
+ (NSString *)cellularProviderName
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    return carrier == nil ? @"":[carrier carrierName];
}

@end
