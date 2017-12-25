//
//  XLCallClient.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLCallReceiveDelegate.h"

/*!
 CallLib核心类
 */
@interface XLCallClient : NSObject
/*!
 获取通话能力库CallLib的核心类单例
 @return 通话能力库CallLib的核心类单例
 @discussion 您可以通过此方法，获取CallLib的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedXLCallClient;

/*!
 设置全局通话呼入的监听器
 
 @param delegate CallLib全局通话呼入的监听器
 */
- (void)setDelegate:(id<XLCallReceiveDelegate>)delegate;

/*!
 发起一个通话
 
 @param targetId         目标会话ID
 @param userIdList       邀请的用户ID列表
 @param type             发起的通话媒体类型
 @param delegate         通话监听
 
 @return 呼出的通话实体
 */
- (XLCallSession *)startTargetId:(NSString *)targetId
                              to:(NSArray *)userIdList
                       mediaType:(XLCallMediaType)type
                 sessionDelegate:(id<XLCallSessionDelegate>)delegate;


/**
 设置本地视频属性，可用此接口设置本地视频分辨率，设置宽和高替换
 
 @param profile profile
 @param swapWidthAndHeight 是否交换宽和高  (默认不交换)
 */
- (void)setVideoProfile:(AgoraRtcVideoProfile)profile swapWidthAndHeight:(BOOL)swapWidthAndHeight;

/*!
 当前的通话会话实体
 */
@property(nonatomic, strong, readonly) XLCallSession *currentCallSession;

@end

