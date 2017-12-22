//
//  XLCallCommonDefine.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#ifndef XLCallCommonDefine_h
#define XLCallCommonDefine_h

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
typedef NS_ENUM(NSInteger, RCCallDisconnectReason) {
    /*!
     己方取消已发出的通话请求
     */
    RCCallDisconnectReasonCancel = 1,
    /*!
     己方拒绝收到的通话请求
     */
    RCCallDisconnectReasonReject = 2,
    /*!
     己方挂断
     */
    RCCallDisconnectReasonHangup = 3,
    /*!
     己方忙碌
     */
    RCCallDisconnectReasonBusyLine = 4,
    /*!
     己方未接听
     */
    RCCallDisconnectReasonNoResponse = 5,
    /*!
     己方不支持当前引擎
     */
    RCCallDisconnectReasonEngineUnsupported = 6,
    /*!
     己方网络出错
     */
    RCCallDisconnectReasonNetworkError = 7,
    
    /*!
     对方取消已发出的通话请求
     */
    RCCallDisconnectReasonRemoteCancel = 11,
    /*!
     对方拒绝收到的通话请求
     */
    RCCallDisconnectReasonRemoteReject = 12,
    /*!
     通话过程对方挂断
     */
    RCCallDisconnectReasonRemoteHangup = 13,
    /*!
     对方忙碌
     */
    RCCallDisconnectReasonRemoteBusyLine = 14,
    /*!
     对方未接听
     */
    RCCallDisconnectReasonRemoteNoResponse = 15,
    /*!
     对方网络错误
     */
    RCCallDisconnectReasonRemoteEngineUnsupported = 16,
    /*!
     对方网络错误
     */
    RCCallDisconnectReasonRemoteNetworkError = 17,
    /*!
     己方其他端已接听
     */
    RCCallDisconnectReasonAcceptByOtherClient = 18,
    /*!
     己方被加入黑名单
     */
    RCCallDisconnectReasonAddToBlackList = 19,
};

/**
 视频显示模式
 */
typedef NS_ENUM(NSInteger, RCCallRenderModel) {
    
    /*!
     默认: 如果视频尺寸与显示视窗尺寸不一致，则视频流会按照显示视窗的比例进行周边裁剪或图像拉伸后填满视窗。
     */
    RCCallRenderModelHidden = 1,
    
    /*!
     RenderFit: 如果视频尺寸与显示视窗尺寸不一致，在保持长宽比的前提下，将视频进行缩放后填满视窗。
     */
    RCCallRenderModelFit = 2,
    
    /*!
     RenderAdaptive: 如果自己和对方都是竖屏，或者如果自己和对方都是横屏，使用
     RCCallRenderModelHidden；如果对方和自己一个竖屏一个横屏，则使用RCCallRenderModelFit。
     */
    RCCallRenderModelAdaptive = 3,
};
#endif /* XLCallCommonDefine_h */

