//
//  XLCallVideoUtility.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLCallVideoUtility : NSObject
/**
 通话时间
 */
+ (NSString *)getTalkTimeStringForTime:(long)time;
/**
 设置锁屏
 */
+ (void)setCallIdleTimerDisabled;
/**
 清空锁屏
 */
+ (void)clearCallIdleTimerDisableds;


/**
 * 挂断原因回调

 @param hangupReason hangupReason description
 @return return value description
 */
+ (NSString *)getReadableStringForCallViewController:(XLCallDisconnectReason)hangupReason;

+ (BOOL)isLandscape;
@end
