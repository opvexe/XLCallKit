//
//  XLCertificateToken.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  信令签名 Signaling Key
 */
@interface XLCertificateToken : NSObject

/**
 * 获取信令签名

 调用示例代码
 {
  unsigned expiredTime =  (unsigned)[[NSDate date] timeIntervalSince1970] + 3600;
  NSString * token =  [self calcToken:appID certificate:certificate1 account:name expiredTime:expiredTime];
 }
 
 @param appId 声网APPID
 @param certificate 声网Certificate
 @param account 客户端定义的用户账号
 @param expiredTime 过期时间
 @return Signaling Key
 */
+ (NSString *)SignalingKeyByAppId: (NSString *) appId Certificate:(NSString *)certificate Account:(NSString*)account ExpiredTime:(unsigned)expiredTime;

@end
