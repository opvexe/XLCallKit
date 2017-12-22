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
}

@end
