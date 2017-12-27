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
        _remotePortraitView.layer.cornerRadius = 4;
        _remotePortraitView.layer.masksToBounds = YES;
        _remotePortraitView.backgroundColor = [UIColor yellowColor];
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

-(void)subVideoViewClicked{
    
}


- (void)resetLayoutWithMediaType:(XLCallMediaType )mediaType callStatus:(XLCallStatus )callStatus{
    [super resetLayoutWithMediaType:mediaType callStatus:callStatus];
    
        UIImage *remoteHeaderImage = self.remotePortraitView.image;
    if (mediaType == XLCallMediaAudio) {
          self.remotePortraitView.image = remoteHeaderImage;
          self.remotePortraitView.hidden = NO;
        if (callStatus == XLCallRinging||callStatus == XLCallDialing||callStatus == XLCallIncoming) {
            self.remotePortraitView.alpha = 0.5;
            self.statusView.hidden = NO;
        }else{
            self.statusView.hidden = YES;
            self.remotePortraitView.alpha = 1.0;
        }
        self.mainVideoView.hidden = YES;
        self.subVideoView.hidden = YES;
    }else{
        if (callStatus == XLCallActive) {
            self.remotePortraitView.hidden = YES;
            [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
            }];
            self.remoteNameLabel.hidden = NO;
            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        }else if (callStatus == XLCallDialing){
            [self.remotePortraitView mas_makeConstraints:^(MASConstraintMaker *make) {
                
            }];
            self.remotePortraitView.image = remoteHeaderImage;
            self.remotePortraitView.hidden = NO;
            
            
            [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
            }];
            self.remoteNameLabel.hidden = NO;
            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        }else if (callStatus == XLCallIncoming||callStatus== XLCallRinging){
            [self.remotePortraitView mas_makeConstraints:^(MASConstraintMaker *make) {
                
            }];
            self.remotePortraitView.image = remoteHeaderImage;
            self.remotePortraitView.hidden = NO;
            
            [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
            }];
            self.remoteNameLabel.hidden = NO;
            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        
        if (callStatus == XLCallActive) {
            if ([self isSupportOrientation:(UIInterfaceOrientation)[UIDevice currentDevice].orientation]) {
                [self.subVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                }];
            }else{
                [self.subVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                }];
            }
            
        }else{
            self.subVideoView.hidden = YES;
        }
        self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        }];
        
        if (callStatus == XLCallRinging||callStatus == XLCallDialing||callStatus == XLCallIncoming) {
            self.remotePortraitView.alpha = 0.5;
            self.statusView.hidden = NO;
        }else{
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


@end

