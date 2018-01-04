//
//  XLCallSession.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//


#import "XLCallSession.h"
#import "XLEncryptionType.h"
@interface XLCallSession ()<AgoraRtcEngineDelegate>
@property(nonatomic,strong)AgoraRtcEngineKit *agoraKit;
@property (nonatomic,weak)id<XLCallSessionDelegate>delegate;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,strong)UIView *videoView;
@end
@implementation XLCallSession

static NSInteger streamID = 0;

-(void)initWithRoomID:(NSString  *)roomID{          ///音频
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AgoraAppID delegate:self];
    [self.agoraKit joinChannelByKey:nil channelName:roomID info:nil uid:0 joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"进入音视频道成功");
    }];
}

-(void)initWithAgoraMediaSDK:(NSString *)roomID{      //视频
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AgoraAppID delegate:self];
    [self.agoraKit setChannelProfile:AgoraRtc_ChannelProfile_Communication];
    [self.agoraKit enableVideo];
    [self.agoraKit setEncryptionMode:[XLEncryptionType modeStringWithEncrypType:[[XLEncryptionType encrypTypeArray][0] intValue]]];
    [self.agoraKit setEncryptionSecret:AgoraEncrypSecret];
    [self.agoraKit createDataStream:&streamID reliable:YES ordered:YES];
    [self.agoraKit startPreview];
    [self.agoraKit joinChannelByKey:nil channelName:roomID info:nil uid:0 joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"进入视频道成功");
    }];
}

#pragma mark --- < 视频通话设置 >
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

/**
 设置用户所在的视频View
 
 @param view userId 用户ID（自己或他人)
 @param userId 视频的View
 @param renderMode 视频显示模式 (默认为RCCallRenderModelHidden)
 */
- (void)setVideoView:(UIView *)view userId:(NSString *)userId renderMode:(AgoraRtcRenderMode)renderMode{
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = userId.intValue;
    videoCanvas.view = view;
    videoCanvas.renderMode = renderMode;
    [self.agoraKit setupLocalVideo:videoCanvas];
}

#pragma mark < AgoraRtcEngineDelegate 视频>
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"视频解码回调");
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed{
    NSLog(@"获取本地视频第一帧,视频直播封面");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    NSLog(@"用户加入");
}

-(void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoFrameOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed{
    NSLog(@"获取远端视频第一帧");
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    NSLog(@"挂断成功 == 获取离开用户uid");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didApiCallExecute:(NSString*)api error:(NSInteger)error{
    NSLog(@"录制回调:%@",api) ;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    NSLog(@"video muted");
}
-(void)rtcEngine:(AgoraRtcEngineKit *)engine receiveStreamMessageFromUid:(NSUInteger)uid streamId:(NSInteger)streamId data:(NSData *)data {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到消息%@",message);
}
#pragma mark < AgoraRtcEngineDelegate 音频>
- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine{
    NSLog(@"音频连接打断");
}
- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine{
    NSLog(@"Connection Lost");
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraRtcErrorCode)errorCode{
    NSLog(@"Occur error:%ld",(long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    NSLog(@"Did joined channel");
}
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine audioQualityOfUid:(NSUInteger)uid quality:(AgoraRtcQuality)quality delay:(NSUInteger)delay lost:(NSUInteger)lost{
    NSLog(@"Audio Quality of uid");
}

/**
 * 视频录制状态
 @param type XLRecordingMediaStart(开始录制),XLRecordingMediaStop(结束录制)
 */
-(void)rtcRecordingStatus:(XLRecordingMediaType)type{
    if (type == XLRecordingMediaStart) {
        [self.agoraKit startRecordingService:AgoraRecordSever];
    }else{
        [self.agoraKit stopRecordingService:AgoraRecordSever];
    }
}

/*!
 设置通话状态变化的监听器
 
 @param delegate 通话状态变化的监听器
 */
- (void)setDelegate:(id<XLCallSessionDelegate>)delegate{
    _delegate = delegate;
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
}


/*!
 邀请用户加入通话
 
 @param userIdList 用户ID列表
 @param type       建议被邀请者使用的媒体类型
 */
- (void)inviteRemoteUsers:(NSArray *)userIdList mediaType:(XLCallMediaType)type{
    
}


/*!
 更换自己使用的媒体类型
 
 @param type 媒体类型
 */
- (BOOL)changeMediaType:(XLCallMediaType)type{
    
    return YES;
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

/**
 * 设置本地视频属性，可用此接口设置本地视频分辨率。
 
 **/
- (void)setVideoProfile:(AgoraRtcVideoProfile)profile{
    [self.agoraKit setVideoProfile:profile swapWidthAndHeight:NO];
}

#pragma mark < 音频设置 >
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

@end

