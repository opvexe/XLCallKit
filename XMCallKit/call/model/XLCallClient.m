//
//  XLCallClient.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallClient.h"
#import "XLCertificateToken.h"

@interface XLCallClient()<AgoraRtcEngineDelegate,AgoraRtcEngineDelegate>
@property(nonatomic,strong)AgoraAPI *callAgoraApi;
@property(nonatomic, strong)XLCallSession *currentCallSession;
@property (nonatomic,weak)id<XLCallReceiveDelegate>delegate;
@property(nonatomic,copy)NSString *userID;
@property(nonatomic,copy)NSString *callId;
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCallAgoraApi];
    }
    return self;
}

///初始化信令
-(void)initCallAgoraApi{
    self.callAgoraApi = [AgoraAPI getInstanceWithoutMedia:AgoraAppID];
    [self callAgoraApiCallBlock];
}

/*!
 * 设置信令状态回调
 
 */
-(void)callAgoraApiCallBlock{
    
    WS(weakSelf)
    self.callAgoraApi.onLoginSuccess = ^(uint32_t uid, int fd) {        ///登录成功回调
        NSLog(@"login successfully");
    };
    
    self.callAgoraApi.onLog = ^(NSString *txt) {      ///信令日志
        NSLog(@"__信令日志LOG__: %@", txt);
    };
    
    self.callAgoraApi.onLoginFailed = ^(AgoraEcode ecode) { ///登录失败回调
        NSLog(@"login faild");
    };
    
    self.callAgoraApi.onReconnecting = ^(uint32_t nretry) { ///连接丢失回调
        NSLog(@"lost connection :%d",nretry);
    };
    
    self.callAgoraApi.onError = ^(NSString *name, AgoraEcode ecode, NSString *desc) {   ///出错回调
        NSLog(@"error :%@",desc);
    };
    
    self.callAgoraApi.onChannelJoined = ^(NSString *channelID) {        ///加入频道回调
        NSLog(@"Join channel%@",channelID);
    };
    
    self.callAgoraApi.onChannelLeaved = ^(NSString *channelID, AgoraEcode ecode) {  ///离开频道回调
        NSLog(@"leave channel :%@",channelID);
    };
    
    self.callAgoraApi.onChannelUserList = ^(NSMutableArray *accounts, NSMutableArray *uids) {   ///频道用户列表
        NSLog(@"channel user list:%@=%@",accounts,uids);
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCallRemoteNotification:inviterUserId:mediaType:userIdList:userDict:)]) {
            [weakSelf.delegate didReceiveCallRemoteNotification:weakSelf.callId inviterUserId:weakSelf.userID mediaType:XLCallMediaVideo userIdList:accounts userDict:nil];
        }
    };
    
    self.callAgoraApi.onInviteReceivedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid) {
        NSLog(@"/本地回调 %@", account);
    };
    
    self.callAgoraApi.onInviteReceived = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {////收到呼叫邀请回调   // extra JSON 数据  定义呼叫类型  语音 或者视频
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCall:)]) {
            XLCallSession *session = [[XLCallSession alloc]init];
            NSDictionary *extraDic  =  [NSString dictionaryWithJsonString:extra];
            if (!is_null(extraDic)) {
                session.callId = convertToString([extraDic valueForKey:@"callid"]);
                session.startTime = convertToString([extraDic valueForKey:@"start_time"]).longLongValue;
            }
            session.callStatus  = XLCallIncoming;
            session.caller = account;
            session.mediaType  = XLCallMediaVideo;
            [weakSelf.delegate didReceiveCall:session];
        }
    };
    
    [self.callAgoraApi setOnInviteFailed:^(NSString *channelID, NSString *account, uint32_t uid, AgoraEcode ecode, NSString *extra) { ///呼叫失败回调
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCall:)]) {
            XLCallSession *session = [[XLCallSession alloc]init];
            NSDictionary *extraDic  =  [NSString dictionaryWithJsonString:extra];
            if (!is_null(extraDic)) {
                session.callId = convertToString([extraDic valueForKey:@"callid"]);
                session.startTime = convertToString([extraDic valueForKey:@"start_time"]).longLongValue;
            }
            switch (ecode) {
                    //网络问题
                case AgoraEcode_LOGOUT_E_NET:
                    session.disconnectReason = XLCallDisconnectReasonRemoteEngineUnsupported;
                    break;
                    //该账户已在别处登录
                case AgoraEcode_LOGOUT_E_KICKED:
                    session.disconnectReason = XLCallDisconnectReasonRemoteEngineUnsupported;
                    break;
                    //call 网络问题
                case AgoraEcode_INVITE_E_NET:
                    session.disconnectReason = XLCallDisconnectReasonRemoteEngineUnsupported;
                    break;
                default:
                    break;
            }
            
            session.caller = account;
            session.mediaType  = XLCallMediaVideo;
            [weakSelf.delegate didReceiveCall:session];
        }
    }];
    
    
    self.callAgoraApi.onInviteAcceptedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) { ////远端已接受呼叫回调(onInviteAcceptedByPeer)
        NSLog(@"/对方接收呼叫回调 %@", account);
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCall:)]) {
            XLCallSession *session = [[XLCallSession alloc]init];
            NSDictionary *extraDic  =  [NSString dictionaryWithJsonString:extra];
            if (!is_null(extraDic)) {
                session.callId = convertToString([extraDic valueForKey:@"callid"]);
                session.startTime = convertToString([extraDic valueForKey:@"start_time"]).longLongValue;
            }
            session.callStatus  = XLCallActive; ///接通
            session.caller = account;
            session.mediaType  = XLCallMediaVideo;
            [weakSelf.delegate didReceiveCall:session];
        }
    };
    
    self.callAgoraApi.onInviteRefusedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) { ////对方已拒绝呼叫回调(onInviteRefusedByPeer)
        NSLog(@"/对方已拒绝呼叫回调 %@", account);
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCall:)])  {
            XLCallSession *model = [[XLCallSession alloc] init];
            NSDictionary *extraDic = [NSString dictionaryWithJsonString:extra];
            if (!is_null(extraDic)) {
                model.callId = convertToString([extraDic valueForKey:@"callid"]);
                model.startTime = convertToString([extraDic valueForKey:@"start_time"]).longLongValue;
            }
            model.disconnectReason = XLCallDisconnectReasonRemoteReject;
            model.caller = account;
            model.mediaType  =XLCallMediaVideo;
            [weakSelf.delegate didReceiveCall:model];
        }
    };
    
    
    self.callAgoraApi.onInviteEndByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) { ////对方endCall回调(onInviteEndByPeer)
        NSLog(@"对方挂掉通话回调 %@", account);
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCall:)])  {
            XLCallSession *model = [[XLCallSession alloc] init];
            NSDictionary *extraDic = [NSString dictionaryWithJsonString:extra];
            if (!is_null(extraDic)) {
                model.callId = convertToString([extraDic valueForKey:@"callid"]);
                model.startTime = convertToString([extraDic valueForKey:@"start_time"]).longLongValue;
            }
            model.disconnectReason = XLCallDisconnectReasonRemoteHangup;
            model.caller = account;
            model.mediaType  =XLCallMediaVideo;
            [weakSelf.delegate didReceiveCall:model];
        }
    };
    
    self.callAgoraApi.onInviteEndByMyself = ^(NSString *channelID, NSString *account, uint32_t uid) {    ///本地已结束呼叫回调(onInviteEndByMyself)
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didReceiveCall:)])  {
            XLCallSession *model = [[XLCallSession alloc] init];
            model.disconnectReason = XLCallDisconnectReasonHangup;
            model.caller = account;
            model.mediaType  = XLCallMediaVideo;
            [weakSelf.delegate didReceiveCall:model];
        }
    };
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
                 sessionDelegate:(id<XLCallSessionDelegate>)delegate{
    XLCallSession *model = [[XLCallSession alloc] init];
    model.targetId = targetId;
    model.userProfileList = userIdList;
    model.mediaType = type;
    [model setDelegate:delegate];
    return model;
}

/*!
 设置全局通话呼入的监听器
 
 @param delegate CallLib全局通话呼入的监听器
 */
- (void)setDelegate:(id<XLCallReceiveDelegate>)delegate{
    self.delegate  = delegate;
}

/*!
 设置信令登录
 */
-(void)login{
    NSString *account   = @"" ;   ///客户端定义的用户账号
    unsigned expiredTime = (unsigned) [[NSDate date] timeIntervalSince1970] + 3600;
    NSString *token = [XLCertificateToken SignalingKeyByAppId:AgoraAppID
                                                  Certificate:AgoraAppCertificate
                                                      Account:account
                                                  ExpiredTime:expiredTime];
    [self.callAgoraApi login2:AgoraAppID account:account token:token uid:0 deviceID:@"" retry_time_in_s:60 retry_count:5];
}

/*!
 信令退出登录
 */
-(void)logout{
    [self.callAgoraApi logout];
}

@end

