//
//  XLCallVideoUtility.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallVideoUtility.h"

@implementation XLCallVideoUtility

+ (NSString *)getTalkTimeStringForTime:(long)time {
    if (time < 60 * 60) {
        return [NSString stringWithFormat:@"%02ld:%02ld", time / 60, time % 60];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", time / 60 / 60, (time / 60) % 60, time % 60];
    }
}

+ (void)setCallIdleTimerDisabled {
    [[NSUserDefaults standardUserDefaults] setBool:[UIApplication sharedApplication].idleTimerDisabled
                                            forKey:@"XLCallIdleTimerDisabled"];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

+ (void)clearCallIdleTimerDisableds {
    BOOL oldStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"XLCallIdleTimerDisabled"];
    [UIApplication sharedApplication].idleTimerDisabled = oldStatus;
}

+ (NSString *)getReadableStringForCallViewController:(XLCallDisconnectReason)hangupReason{
    NSString *hangupReasonString = nil;
    switch (hangupReason) {
        case XLCallDisconnectReasonCancel:
            hangupReasonString = @"己方取消已发出的通话请求";
            break;
        case XLCallDisconnectReasonReject:
            hangupReasonString = @"己方拒绝收到的通话请求";
            break;
        case XLCallDisconnectReasonHangup:
            hangupReasonString = @"己方挂断";
            break;
        case XLCallDisconnectReasonRemoteCancel:
            hangupReasonString = @"己方忙碌";
            break;
        case XLCallDisconnectReasonRemoteReject:
            hangupReasonString = @"对方拒绝收到的通话请求";
            break;
        case XLCallDisconnectReasonRemoteHangup:
            hangupReasonString = @"通话过程对方挂断";
            break;
        case XLCallDisconnectReasonRemoteBusyLine:
            hangupReasonString = @"对方忙碌";
            break;
        case XLCallDisconnectReasonRemoteNoResponse:
            hangupReasonString = @"对方未接听";
            break;
        case XLCallDisconnectReasonAcceptByOtherClient:
            hangupReasonString = @"己方其他端已接听";
            break;
        default:
            break;
    }
    return hangupReasonString;
}

+ (BOOL)isLandscape {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    return screenBounds.size.width > screenBounds.size.height;
}

+ (void)setScreenForceOn {
    [[NSUserDefaults standardUserDefaults] setBool:[UIApplication sharedApplication].idleTimerDisabled
                                            forKey:@"RCCallIdleTimerDisabled"];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

+ (void)clearScreenForceOnStatus {
    BOOL oldStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"RCCallIdleTimerDisabled"];
    [UIApplication sharedApplication].idleTimerDisabled = oldStatus;
}
@end

