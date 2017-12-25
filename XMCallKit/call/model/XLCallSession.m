//
//  XLCallSession.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallSession.h"

@interface XLCallSession ()<AgoraRtcEngineDelegate>
@property(nonatomic,strong)AgoraRtcEngineKit *agoraKit;
@property(nonatomic,weak)id <XLCallSessionDelegate>delegate;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,strong)UIView *videoView;
@property(nonatomic,assign)XLCallStatus callStatus;
@end
@implementation XLCallSession

-(void)initWithAppId:(NSString  *)appId{
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:self];
    int code = [self.agoraKit joinChannelByKey:nil channelName:AgoraChannelName info:nil uid:0 joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
    }];
    
    if (code !=0) {
        NSLog(@"Join channel failed");
    }
}

#pragma mark < AgoraRtcEngineDelegate >

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    
    
}

/*!
 设置通话状态变化的监听器
 
 @param delegate 通话状态变化的监听器
 */
- (void)setDelegate:(id<XLCallSessionDelegate>)delegate{
    self.delegate = delegate;
}


/*!
 接听来电
 
 @param type 接听使用的媒体类型
 */
- (void)accept:(XLCallMediaType)type{
    switch (type) {
        case XLCallMediaVideo:{
            [self.agoraKit enableVideo];
        }
            break;
        default:
            [self.agoraKit enableAudio];
            [self.agoraKit disableVideo];
            break;
    }
}
/*!
 挂断通话
 */
- (void)hangup{
    [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        self.agoraKit = nil;
    }];
//    [self.agoraApi channelInviteEnd:nil account:self.userId uid:0];
}
/*!
 设置用户所在的视频View
 
 @param userId 用户ID（自己或他人）
 @param view   视频的View
 */
- (void)setVideoView:(UIView *)view userId:(NSString *)userId{
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = userId.intValue;
    videoCanvas.view = view;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupLocalVideo:videoCanvas];
}

/*!
 邀请用户加入通话
 
 @param userIdList 用户ID列表
 @param type       建议被邀请者使用的媒体类型
 */
- (void)inviteRemoteUsers:(NSArray *)userIdList mediaType:(XLCallMediaType)type{
    
}

/**
 设置用户所在的视频View
 
 @param view userId 用户ID（自己或他人)
 @param userId 视频的View
 */
- (void)setVideoView:(UIView *)view userId:(NSString *)userId renderMode:(AgoraRtcRenderMode)renderMode{
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = userId.intValue;
    videoCanvas.view = view;
    videoCanvas.renderMode = renderMode;
    [self.agoraKit setupLocalVideo:videoCanvas];
}
/*!
 更换自己使用的媒体类型
 
 @param type 媒体类型
 */
- (BOOL)changeMediaType:(XLCallMediaType)type{
    
    return YES;
}

/*!
 设置静音状态
 
 @param muted 是否静音
 
 @return 是否设置成功
 
 @discussion 默认值为NO。
 */
- (BOOL)setMuted:(BOOL)muted{
    if ([self.agoraKit muteLocalAudioStream:muted]==0) {
        return YES;
    }else{
        return NO;
    }
}

/*!
 设置扬声器状态
 
 @param speakerEnabled  是否开启扬声器
 @return                是否设置成功
 */
- (BOOL)setSpeakerEnabled:(BOOL)speakerEnabled{
    if ( [self.agoraKit setEnableSpeakerphone:speakerEnabled]==0) {
        return YES;
    }else{
        return NO;
    }
}
/*!
 设置摄像头状态
 @param cameraEnabled  是否开启摄像头
 @return               是否设置成功
 
 @discussion 音频通话的默认值为NO，视频通话的默认值为YES。
 */
- (BOOL)setCameraEnabled:(BOOL)cameraEnabled{
    if ( [self.agoraKit muteLocalVideoStream:cameraEnabled]==0) {
        return YES;
    }else{
        return NO;
    }
}

/*!
 切换前后摄像头
 */
- (BOOL)switchCameraMode{
    if ([self.agoraKit switchCamera]==0) {
        return YES;
    }else{
        return NO;
    }
}


@end

