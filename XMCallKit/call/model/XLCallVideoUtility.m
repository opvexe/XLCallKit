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

@end
