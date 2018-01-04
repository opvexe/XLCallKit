//
//  XLCallSingleCallViewController.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallSingleCallViewController.h"

@interface XLCallSingleCallViewController ()

@end

@implementation XLCallSingleCallViewController

- (instancetype)initWithOutgoingCall:(NSString *)targetId mediaType:(XLCallMediaType)mediaType{
    return [super initWithOutgoingCallTargetId:targetId mediaType:mediaType userIdList:@[targetId]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (UIImageView *)remotePortraitView {
    if (!_remotePortraitView) {
        _remotePortraitView = [[UIImageView alloc] init];
        _remotePortraitView.hidden = YES;
        _remotePortraitView.layer.cornerRadius = 5.0;
        _remotePortraitView.layer.masksToBounds = YES;
        _remotePortraitView.image = [UIImage imageNamed:@"portrait.jpg"];
        [self.view addSubview:_remotePortraitView];
    }
    return _remotePortraitView;
}

- (UILabel *)remoteNameLabel {
    if (!_remoteNameLabel) {
        _remoteNameLabel = [[UILabel alloc] init];
        _remoteNameLabel.backgroundColor = [UIColor clearColor];
        _remoteNameLabel.textColor = [UIColor whiteColor];
        _remoteNameLabel.font = [UIFont systemFontOfSize:18];
        _remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        _remoteNameLabel.text = @"shumin";
        [self.view addSubview:_remoteNameLabel];
        _remoteNameLabel.hidden = YES;
    }
    return _remoteNameLabel;
}


- (UIImageView *)statusView {
    if (!_statusView) {
        _statusView = [[UIImageView alloc] init];
        [self.view addSubview:_statusView];
        _statusView.hidden = YES;
        _statusView.image = [UIImage imageNamed:@"voip_connecting"];
    }
    return _statusView;
}

- (UIView *)mainVideoView {
    if (!_mainVideoView) {
        _mainVideoView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        _mainVideoView.backgroundColor = UIColorFromRGB(0x262e42);
        [self.backgroundView addSubview:_mainVideoView];
        _mainVideoView.hidden = YES;
    }
    return _mainVideoView;
}

- (UIView *)subVideoView {
    if (!_subVideoView) {
        _subVideoView = [[UIView alloc] init];
        _subVideoView.backgroundColor = [UIColor blackColor];
        _subVideoView.layer.borderWidth = 1;
        _subVideoView.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self.view addSubview:_subVideoView];
        _subVideoView.hidden = YES;
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subVideoViewClicked)];
        [_subVideoView addGestureRecognizer:tap];
    }
    return _subVideoView;
}


- (void)resetLayout:(BOOL)isMultiCall mediaType:(XLCallMediaType)mediaType callStatus:(XLCallStatus)callStatus{
    [super resetLayout:isMultiCall mediaType:mediaType callStatus:callStatus];
    UIImage *remoteHeaderImage = self.remotePortraitView.image;
    if (mediaType == XLCallMediaAudio) {
        self.remotePortraitView.frame = CGRectMake((self.view.frame.size.width - LSWMCallHeaderLength) / 2,
                                                   LSWMCallVerticalMargin * 3, LSWMCallHeaderLength, LSWMCallHeaderLength);
        self.remotePortraitView.image = remoteHeaderImage;
        self.remotePortraitView.hidden = NO;
        
        self.remoteNameLabel.frame =
        CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin,
                   self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        self.remoteNameLabel.hidden = NO;
        
        self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        
        self.statusView.frame = CGRectMake((self.view.frame.size.width - 17) / 2,
                                           LSWMCallVerticalMargin * 3 + (LSWMCallHeaderLength - 4) / 2, 17, 4);
        
        if (callStatus == XLCallRinging || callStatus == XLCallDialing || callStatus == XLCallIncoming) {
            self.remotePortraitView.alpha = 0.5;
            self.statusView.hidden = NO;
        } else {
            self.statusView.hidden = YES;
            self.remotePortraitView.alpha = 1.0;
        }
        self.mainVideoView.hidden = YES;
        self.subVideoView.hidden = YES;
        [self resetRemoteUserInfoIfNeed];
    } else {
        if (callStatus == XLCallDialing) {
            self.mainVideoView.hidden = NO;
            [self.callSession setVideoView:self.mainVideoView
                                    userId:[XLUserInfoCacheManager getUser].userId];
            self.blurView.hidden = YES;
        } else if (callStatus == XLCallActive) {
            self.mainVideoView.hidden = NO;
            [self.callSession setVideoView:self.mainVideoView userId:self.callSession.targetId];
            self.blurView.hidden = YES;
        } else {
            self.mainVideoView.hidden = YES;
        }
        if (callStatus == XLCallActive) {
            self.remotePortraitView.hidden = YES;
            
            self.remoteNameLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.remoteNameLabel.hidden = NO;
            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        } else if (callStatus == XLCallDialing) {
            self.remotePortraitView.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallHeaderLength) / 2, LSWMCallVerticalMargin * 3,
                       LSWMCallHeaderLength, LSWMCallHeaderLength);
            self.remotePortraitView.image = remoteHeaderImage;
            self.remotePortraitView.hidden = NO;
            
            self.remoteNameLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.remoteNameLabel.hidden = NO;
            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.remotePortraitView.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallHeaderLength) / 2, LSWMCallVerticalMargin * 3,
                       LSWMCallHeaderLength, LSWMCallHeaderLength);
            self.remotePortraitView.image = remoteHeaderImage;
            self.remotePortraitView.hidden = NO;
            
            self.remoteNameLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.remoteNameLabel.hidden = NO;
            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        if (callStatus == XLCallActive) {
            if ([XLCallVideoUtility isLandscape] && [self isSupportOrientation:(UIInterfaceOrientation)[UIDevice currentDevice].orientation]) {
                self.subVideoView.frame =
                CGRectMake(self.view.frame.size.width - LSWMCallHeaderLength - LSWMCallHorizontalMargin / 2,
                           LSWMCallVerticalMargin, LSWMCallHeaderLength * 1.5, LSWMCallHeaderLength);
            } else {
                self.subVideoView.frame =
                CGRectMake(self.view.frame.size.width - LSWMCallHeaderLength - LSWMCallHorizontalMargin / 2,
                           LSWMCallVerticalMargin, LSWMCallHeaderLength, LSWMCallHeaderLength * 1.5);
            }
            [self.callSession setVideoView:self.subVideoView
                                    userId:[XLUserInfoCacheManager getUser].userId];
            self.subVideoView.hidden = NO;
        } else {
            self.subVideoView.hidden = YES;
        }
        
        self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        self.statusView.frame = CGRectMake((self.view.frame.size.width - 17) / 2,
                                           LSWMCallVerticalMargin * 3 + (LSWMCallHeaderLength - 4) / 2, 17, 4);
        
        if (callStatus == XLCallRinging || callStatus == XLCallDialing || callStatus == XLCallIncoming) {
            self.remotePortraitView.alpha = 0.5;
            self.statusView.hidden = NO;
        } else {
            self.statusView.hidden = YES;
            self.remotePortraitView.alpha = 1.0;
        }
    }
}


- (BOOL)isSupportOrientation:(UIInterfaceOrientation)orientation {
    return [[UIApplication sharedApplication]
            supportedInterfaceOrientationsForWindow:[UIApplication sharedApplication].keyWindow] &
    (1 << orientation);
}

- (void)resetRemoteUserInfoIfNeed {
    
}



-(void)subVideoViewClicked{
    
}
@end

