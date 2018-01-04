//
//  XLCall.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCall.h"
#import "XLCallSingleCallViewController.h"
#import "XLCallAudioMultiCallViewController.h"
#import "XLCallVideoMultiCallViewController.h"

@interface XLCall()<XLCallReceiveDelegate>
@property(nonatomic,strong)AgoraAPI *callAgoraApi;
@property(nonatomic, strong) NSMutableArray *callWindows;
@property(nonatomic, strong) NSMutableArray *locationNotificationList;
@end

@implementation XLCall

+ (instancetype)sharedXLCall {
    static dispatch_once_t onceToken;
    static XLCall *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XLCall alloc] init];
        [[XLCallClient sharedXLCallClient] setDelegate:instance];
        instance.maxMultiAudioCallUserNumber = 20;
        instance.maxMultiVideoCallUserNumber = 9;
        instance.callWindows = [[NSMutableArray alloc] init];
        instance.locationNotificationList = [[NSMutableArray alloc] init];
        [instance registerNotification];
    });
    return instance;
}

/*!
 当前的通话会话实体
 */
- (XLCallSession *)currentCallSession {
    return [XLCallClient sharedXLCallClient].currentCallSession;
}

/*!
 发起单人通话(视频或语音)
 
 @param targetId  对方的用户ID
 @param mediaType 使用的媒体类型
 */
- (void)startSingleCall:(NSString *)targetId mediaType:(XLCallMediaType)mediaType{
    XLCallSingleCallViewController *singleCallViewController = [[XLCallSingleCallViewController alloc]initWithOutgoingCall:targetId mediaType:mediaType];
    [self presentCallViewController:singleCallViewController];
}

/*!
 直接发起多人通话
 
 @param targetId         会话目标ID
 @param mediaType        使用的媒体类型
 @param userIdList       邀请的用户ID列表
 
 @discussion 此方法会直接发起通话。目前支持的会话类型有讨论组和群组。
 
 @warning 您需要设置并实现groupMemberDataSource才能加人。
 */

-(void)startMultiCallViewController:(NSString *)targetId mediaType:(XLCallMediaType)mediaType userIdList:(NSArray *)userIdList{
    if (mediaType == XLCallMediaAudio) {
        XLCallAudioMultiCallViewController *audioCallViewController = [[XLCallAudioMultiCallViewController alloc]initWithOutgoingCallTargetId:targetId mediaType:mediaType userIdList:userIdList];
        [self presentCallViewController:audioCallViewController];
    }else{
        XLCallVideoMultiCallViewController *videoCallViewController = [[XLCallVideoMultiCallViewController alloc]initWithOutgoingCallTargetId:targetId mediaType:mediaType userIdList:userIdList];
        [self presentCallViewController:videoCallViewController];
    }
}

#pragma mark < XLCallReceiveDelegate >
- (void)didReceiveCall:(XLCallSession *)callSession {
    if (!callSession.isMultiCall) {
        XLCallSingleCallViewController *singleCallViewController = [[XLCallSingleCallViewController alloc]initWithIncomingCall:callSession];
        [self presentCallViewController:singleCallViewController];
    }else{
        if (callSession.mediaType == XLCallMediaAudio) {
            XLCallAudioMultiCallViewController *multiCallViewController = [[XLCallAudioMultiCallViewController alloc]initWithIncomingCall:callSession];
            [self presentCallViewController:multiCallViewController];
        }else{
            XLCallVideoMultiCallViewController *multiCallViewController = [[XLCallVideoMultiCallViewController alloc]initWithIncomingCall:callSession];
            [self presentCallViewController:multiCallViewController];
        }
    }
}

-(void)didReceiveCallRemoteNotification:(NSString *)callId inviterUserId:(NSString *)inviterUserId mediaType:(XLCallMediaType)mediaType userIdList:(NSArray *)userIdList userDict:(NSDictionary *)userDict{
    
}




#pragma mark < NotificationCenter >
-(void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

-(void)appDidBecomeActive{
    for (UILocalNotification *notification in self.locationNotificationList) {
        if ([notification.userInfo[@"appData"][@"callId"] isEqualToString:self.currentCallSession.callId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            [self.locationNotificationList removeObject:notification];
            break;
        }
    }
}

- (void)presentCallViewController:(UIViewController *)viewController {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIWindow *activityWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    activityWindow.windowLevel = UIWindowLevelAlert;
    activityWindow.rootViewController = viewController;
    [activityWindow makeKeyAndVisible];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    animation.type = kCATransitionMoveIn;     //可更改为其他方式
    animation.subtype = kCATransitionFromTop; //可更改为其他方式
    [[activityWindow layer] addAnimation:animation forKey:nil];
    [self.callWindows addObject:activityWindow];
}

- (void)dismissCallViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[XLCallBaseViewController class]]) {
        UIViewController *rootVC = viewController;
        while (rootVC.parentViewController) {
            rootVC = rootVC.parentViewController;
        }
        viewController = rootVC;
    }
    
    for (UIWindow *window in self.callWindows) {
        if (window.rootViewController == viewController) {
            [window resignKeyWindow];
            window.hidden = YES;
            [[UIApplication sharedApplication].delegate.window makeKeyWindow];
            [self.callWindows removeObject:window];
            break;
        }
    }
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


@end

