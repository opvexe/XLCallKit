//
//  XLConst.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#ifndef XLConst_h
#define XLConst_h

#import <UIKit/UIKit.h>

/*!
 媒体类型
 */
typedef NS_ENUM(NSInteger, XLCallMediaType) {
    /*!
     音频
     */
    XLCallMediaAudio = 1,
    /*!
     视频
     */
    XLCallMediaVideo = 2,
};

/*!
 通话状态
 */
typedef NS_ENUM(NSInteger, XLCallStatus) {
    /*!
     初始状态
     */
    XLCallIdle   = 0,
    /*!
     正在呼出
     */
    XLCallDialing = 1,
    /*!
     正在呼入
     */
    XLCallIncoming = 2,
    /*!
     收到一个通话呼入后，正在振铃
     */
    XLCallRinging = 3,
    /*!
     正在通话
     */
    XLCallActive = 4,
    /*!
     已经挂断
     */
    XLCallHangup = 5,
};



/*!
 通话结束原因
 */
typedef NS_ENUM(NSInteger, XLCallDisconnectReason) {
    /*!
     己方取消已发出的通话请求
     */
    XLCallDisconnectReasonCancel = 1,
    /*!
     己方拒绝收到的通话请求
     */
    XLCallDisconnectReasonReject = 2,
    /*!
     己方挂断
     */
    XLCallDisconnectReasonHangup = 3,
    /*!
     己方忙碌
     */
    XLCallDisconnectReasonBusyLine = 4,
    /*!
     己方未接听
     */
    XLCallDisconnectReasonNoResponse = 5,
    /*!
     己方不支持当前引擎
     */
    XLCallDisconnectReasonEngineUnsupported = 6,
    /*!
     己方网络出错
     */
    XLCallDisconnectReasonNetworkError = 7,
    
    /*!
     对方取消已发出的通话请求
     */
    XLCallDisconnectReasonRemoteCancel = 11,
    /*!
     对方拒绝收到的通话请求
     */
    XLCallDisconnectReasonRemoteReject = 12,
    /*!
     通话过程对方挂断
     */
    XLCallDisconnectReasonRemoteHangup = 13,
    /*!
     对方忙碌
     */
    XLCallDisconnectReasonRemoteBusyLine = 14,
    /*!
     对方未接听
     */
    XLCallDisconnectReasonRemoteNoResponse = 15,
    /*!
     对方网络错误
     */
    XLCallDisconnectReasonRemoteEngineUnsupported = 16,
    /*!
     对方网络错误
     */
    XLCallDisconnectReasonRemoteNetworkError = 17,
    /*!
     己方其他端已接听
     */
    XLCallDisconnectReasonAcceptByOtherClient = 18,
    /*!
     己方被加入黑名单
     */
    XLCallDisconnectReasonAddToBlackList = 19,
};



/*!
 媒体录制状态
 */
typedef NS_ENUM(NSInteger, XLRecordingMediaType) {
    /*!
     开始录制
     */
    XLRecordingMediaStart = 1,
    /*!
     结束录制
     */
    XLRecordingMediaStop = 2,
};

#pragma mark    < 声望 key >

extern NSString * const AgoraCustomerID;                ///声望AppID
extern NSString * const AgoraCustomerCertificate;       ///声望Certificate
extern NSString * const AgoraChannelName;               ///声望ChannelName，房间号
extern NSString * const AgoraRecordSever;               ///录制视频的服务器地址

#endif /* XLConst_h */

