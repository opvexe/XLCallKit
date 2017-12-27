//
//  CallVideoKey.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "CallVideoKey.h"
#include "DynamicKey4.h"

@implementation CallVideoKey
+ (NSString *) createMediaKeyByAppID:(NSString*)appID
                      appCertificate:(NSString*)appCertificate
                         channelName:(NSString*)channelName
                              unixTs:(uint32_t)unixTs
                           randomInt:(uint32_t)randomInt
                                 uid:(uint32_t)uid
                           expiredTs:(uint32_t)expiredTs
{
    std::string x = agora::tools::DynamicKey4::generateMediaChannelKey(
                                                                       [appID UTF8String],
                                                                       [appCertificate UTF8String],
                                                                       [channelName UTF8String],
                                                                       unixTs,
                                                                       randomInt,
                                                                       uid,
                                                                       expiredTs).c_str();
    
    return [NSString stringWithCString:x.c_str()
                              encoding:NSUTF8StringEncoding] ;
}
@end
