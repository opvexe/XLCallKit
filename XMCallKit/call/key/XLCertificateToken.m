//
//  XLCertificateToken.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCertificateToken.h"
#import <CommonCrypto/CommonDigest.h>

@implementation XLCertificateToken

+ (NSString *)SignalingKeyByAppId: (NSString *) appId Certificate:(NSString *)certificate Account:(NSString*)account ExpiredTime:(unsigned)expiredTime{
    NSString * sign = [self MD5:[NSString stringWithFormat:@"%@%@%@%d", account, appId, certificate, expiredTime]];
    return [NSString stringWithFormat:@"1:%@:%d:%@", appId, expiredTime, sign];
}

+ (NSString*)MD5:(NSString*)md5{
    // Create pointer to the string as UTF8
    const char *ptr = [md5 UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (uint32_t)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+(NSString *)CreateMediaKeyByChannelName:(NSString *)channelName Uid:(uint32_t)uid{
    unsigned expiredTime = (unsigned) [[NSDate date] timeIntervalSince1970] + 3600;
    __block NSString *key;
    if (AgoraEnableMediaCertificate) {
        key = [CallVideoKey createMediaKeyByAppID:AgoraAppID
                                   appCertificate:AgoraAppCertificate
                                      channelName:channelName
                                           unixTs:time(NULL)
                                        randomInt:(rand()%256 << 24) + (rand()%256 << 16) + (rand()%256 << 8) + (rand()%256)
                                              uid:uid
                                        expiredTs:expiredTime];
    }
    return key;
}
@end

