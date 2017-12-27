//
//  XLCallSession.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLCallSessionDelegate.h"

/*!
 当前的通话会话实体
 */

@interface XLCallSession : NSObject
/*!
 通话ID
 */
@property(nonatomic, strong) NSString *callId;

/*!
 通话的目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 是否是多方通话
 */
@property(nonatomic, assign, readonly, getter=isMultiCall) BOOL multiCall;

/*!
 通话的扩展信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 通话的当前状态
 */
@property(nonatomic, assign) XLCallStatus callStatus;

/*!
 通话的最初发起人
 */
@property(nonatomic, strong) NSString *caller;

/*!
 邀请当前用户加入通话的邀请者
 */
@property(nonatomic, strong, readonly) NSString *inviter;

/*!
 当前的用户列表
 */
@property(nonatomic, strong) NSArray *userProfileList;

/*!
 自己的状态
 */
//@property(nonatomic, strong, readonly) RCCallUserProfile *myProfile;

/*!
 当前用户使用的媒体类型
 */
@property(nonatomic, assign) XLCallMediaType mediaType;

/*!
 通话开始的时间
 
 @discussion
 如果是用户呼出的通话，则startTime为通话呼出时间；如果是呼入的通话，则startTime为通话呼入时间。
 */
@property(nonatomic, assign) long long startTime;

/*!
 通话接通时间
 */
@property(nonatomic, assign) long long connectedTime;

/*!
 通话挂断原因
 */
@property(nonatomic, assign) XLCallDisconnectReason disconnectReason;

/*!
 设置通话状态变化的监听器
 
 @param delegate 通话状态变化的监听器
 */
- (void)setDelegate:(id<XLCallSessionDelegate>)delegate;

/*!
 接听来电
 
 @param type 接听使用的媒体类型
 */
- (void)accept:(XLCallMediaType)type;

/*!
 挂断通话
 */
- (void)hangup;

/*!
 邀请用户加入通话
 
 @param userIdList 用户ID列表
 @param type       建议被邀请者使用的媒体类型
 */
- (void)inviteRemoteUsers:(NSArray *)userIdList mediaType:(XLCallMediaType)type;

/*!
 设置用户所在的视频View
 
 @param userId 用户ID（自己或他人）
 @param view   视频的View
 */
- (void)setVideoView:(UIView *)view userId:(NSString *)userId;

/**
 设置用户所在的视频View
 
 @param view userId 用户ID（自己或他人)
 @param userId 视频的View
 @param renderMode 视频显示模式 (默认为RCCallRenderModelHidden)
 */
- (void)setVideoView:(UIView *)view userId:(NSString *)userId renderMode:(AgoraRtcRenderMode)renderMode;

/*!
 更换自己使用的媒体类型
 
 @param type 媒体类型
 */
- (BOOL)changeMediaType:(XLCallMediaType)type;

/*!
 静音状态
 */
@property(nonatomic, readonly) BOOL isMuted;

/*!
 设置静音状态
 
 @param muted 是否静音
 
 @return 是否设置成功
 
 @discussion 默认值为NO。
 */
- (BOOL)setMuted:(BOOL)muted;

/*!
 扬声器状态，是否开启扬声器
 
 @discussion 音频通话的默认值为NO，视频通话的默认值为YES。
 */
@property(nonatomic, readonly) BOOL speakerEnabled;

/*!
 设置扬声器状态
 
 @param speakerEnabled  是否开启扬声器
 @return                是否设置成功
 */
- (BOOL)setSpeakerEnabled:(BOOL)speakerEnabled;

/*!
 摄像头状态，是否开启摄像头
 */
@property(nonatomic, readonly) BOOL cameraEnabled;

/*!
 设置摄像头状态
 
 @param cameraEnabled  是否开启摄像头
 @return               是否设置成功
 
 @discussion 音频通话的默认值为NO，视频通话的默认值为YES。
 */
- (BOOL)setCameraEnabled:(BOOL)cameraEnabled;

/*!
 切换前后摄像头
 
 @return 是否切换成功
 */
- (BOOL)switchCameraMode;

/**
 * 设置本地视频属性，可用此接口设置本地视频分辨率。  ///默认 AgoraRtc_VideoProfile_360P
 *
 { @(AgoraRtc_VideoProfile_120P),
 @(AgoraRtc_VideoProfile_180P),
 @(AgoraRtc_VideoProfile_240P),
 @(AgoraRtc_VideoProfile_360P),
 @(AgoraRtc_VideoProfile_480P),
 @(AgoraRtc_VideoProfile_720P)]; }
 * @param profile profile
 */
- (void)setVideoProfile:(AgoraRtcVideoProfile)profile;

@end
