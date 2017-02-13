//
//  NSString+IPAddress.m
//  LogDemo
//
//  Created by _ on 17/2/8.
//  Copyright © 2017年 zhaofuqiang. All rights reserved.
//

#import "NSString+IPAddress.h"
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <ZFQLog.h>

@implementation NSString (IPAddress)

+ (NSString *)currentIpAddress
{
    char hostName[128];
    
    gethostname(hostName, sizeof(hostName));
    struct hostent *hent = gethostbyname(hostName);
    ZFQLog(@"hostname: %@\n",[NSString stringWithUTF8String:hent->h_name]);
    
    char *ipAddress = NULL;
    for (NSInteger i = 0; hent -> h_addr_list[i]; i++) {

        struct in_addr addr = *(struct in_addr *)(hent->h_addr_list[i]);
        ipAddress = inet_ntoa(addr);
        
        ZFQLog(@"%@\n", [NSString stringWithUTF8String:ipAddress]);
    }
    
    return [NSString stringWithUTF8String:ipAddress];
}


@end
