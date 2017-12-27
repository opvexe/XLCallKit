//
//  XLCall.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCall.h"

@interface XLCall()
@property(nonatomic,strong)AgoraAPI *callAgoraApi;
@property(nonatomic, strong) NSMutableArray *callWindows;
@end

@implementation XLCall

+ (instancetype)sharedXLCall {
    static dispatch_once_t onceToken;
    static XLCall *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XLCall alloc] init];
        instance.maxMultiAudioCallUserNumber = 20;
        instance.maxMultiVideoCallUserNumber = 9;
        instance.callWindows = [[NSMutableArray alloc] init];
    });
    return instance;
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

