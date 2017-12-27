//
//  CallBaseViewController.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 通话的基类
 */
@interface XLCallBaseViewController : UIViewController<XLCallSessionDelegate>

#pragma mark  <  会话类型  >
/*!
 会话目标ID
 */
@property(nonatomic, strong, readonly) NSString *targetId;

/*!
 媒体类型
 */
@property(nonatomic, assign, readonly) XLCallMediaType mediaType;

/*!
 通话实体
 */
@property(nonatomic, strong) XLCallSession *callSession;

#pragma mark   <  UI控件  >
/*!
 背景View
 */
@property(nonatomic, strong) UIView *backgroundView;

/*!
 蒙层View
 */
@property(nonatomic, strong) UIVisualEffectView *blurView;

/*!
 最小化Button
 */
@property(nonatomic, strong) UIButton *minimizeButton;

/*!
 加人Button
 */
@property(nonatomic, strong) UIButton *inviteUserButton;

/*!
 通话时长Label
 */
@property(nonatomic, strong) UILabel *timeLabel;

/*!
 提示Label
 */
@property(nonatomic, strong) UILabel *tipsLabel;

/*!
 静音Button
 */
@property(nonatomic, strong) UIButton *muteButton;

/*!
 扬声器Button
 */
@property(nonatomic, strong) UIButton *speakerButton;

/*!
 接听Button
 */
@property(nonatomic, strong) UIButton *acceptButton;

/*!
 挂断Button
 */
@property(nonatomic, strong) UIButton *hangupButton;

/*!
 关闭摄像头的Button
 */
@property(nonatomic, strong) UIButton *cameraCloseButton;

/*!
 切换前后摄像头的Button
 */
@property(nonatomic, strong) UIButton *cameraSwitchButton;

#pragma mark  < 布局 >

/*!
 重新Layout布局
 @param mediaType        通话媒体类型
 @param callStatus       通话状态
 
 @discussion 如果您需要重写并调整UI的布局，应该先调用super。
 */
- (void)resetLayoutWithMediaType:(XLCallMediaType )mediaType callStatus:(XLCallStatus )callStatus;


#pragma mark  < 发起通话 >
/*!
 初始化ViewController并发起通话
 @param targetId         会话目标ID
 @param mediaType        通话媒体类型
 @param userIdList       邀请的用户ID列表
 
 @return ViewController
 */
- (instancetype)initWithOutgoingCallTargetId:(NSString *)targetId
                                   mediaType:(XLCallMediaType)mediaType
                                  userIdList:(NSArray *)userIdList;

/*!
 初始化呼入的ViewController
 
 @param callSession 呼入的通话实体
 
 @return ViewController
 */
- (instancetype)initWithIncomingCall:(XLCallSession *)callSession;

#pragma mark  < 回调 >
/*!
 通话即将接通
 */
- (void)callWillConnect;
/*!
 通话即将挂断
 */
- (void)callWillDisconnect;
/*!
 点击最小化Button的回调
 */
- (void)didTapMinimizeButton;
/*!
 点击加人Button的回调
 */
- (void)didTapInviteUserButton;

/*!
 点击接听Button的回调
 */
- (void)didTapAcceptButton;

/*!
 点击挂断Button的回调
 */
- (void)didTapHangupButton;

/*!
 点击扬声器Button的回调
 */
- (void)didTapSpeakerButton;
/*!
 点击静音Button的回调
 */
- (void)didTapMuteButton;

/*!
 点击开启、关闭摄像头Button的回调
 */
- (void)didTapCameraCloseButton;

/*!
 点击切换前后摄像头Button的回调
 */
- (void)didTapCameraSwitchButton;

@end

