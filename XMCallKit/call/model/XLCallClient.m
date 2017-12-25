//
//  XLCallClient.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallClient.h"
@interface XLCallClient()<AgoraRtcEngineDelegate>
@property(nonatomic,weak)id<XLCallReceiveDelegate>delegate;
@property(nonatomic,weak)id<XLCallSessionDelegate>sessionDelegate;
@property (strong,nonatomic)AgoraRtcEngineKit *rtcEngine;
@end
@implementation XLCallClient

+ (instancetype)sharedXLCallClient{
    static dispatch_once_t onceToken;
    static XLCallClient *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XLCallClient alloc] init];
    });
    return instance;
}

/*!
 设置全局通话呼入的监听器
 
 @param delegate CallLib全局通话呼入的监听器
 */
- (void)setDelegate:(id<XLCallReceiveDelegate>)delegate{
    self.delegate  = delegate;
}

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
                 sessionDelegate:(id<XLCallReceiveDelegate>)delegate{
    XLCallSession *session = [[XLCallSession alloc]init];
  
    return session;
}


/**
 设置本地视频属性，可用此接口设置本地视频分辨率，设置宽和高替换
 
 @param profile profile
 @param swapWidthAndHeight 是否交换宽和高  (默认不交换)
 */
- (void)setVideoProfile:(AgoraRtcVideoProfile)profile swapWidthAndHeight:(BOOL)swapWidthAndHeight{
    
}



@end
