//
//  CallBaseViewController.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallBaseViewController.h"

@interface XLCallBaseViewController ()
@property(nonatomic, strong) NSTimer *activeTimer;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, assign) BOOL needPlayingAlertAfterForeground;
@property(nonatomic, assign) BOOL needPlayingRingAfterForeground;
@property(nonatomic, strong) CTCallCenter *callCenter;
@end

@implementation XLCallBaseViewController

-(instancetype)initWithOutgoingCallTargetId:(NSString *)targetId mediaType:(XLCallMediaType)mediaType userIdList:(NSArray *)userIdList{
    self = [super init];
    if (self) {
        
        [self registerForegroundNotification];
    }
    return self;
}


/**
 * 视图消失
 
 @param animated animated description
 */
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}
/**
 * 视图加载
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = UIColorFromRGB(0x262e42);
    [self.view addSubview:self.backgroundView];
    self.backgroundView.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onOrientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [self registerTelephonyEvent];
    [self addProximityMonitoringObserver];
    UIVisualEffect *blurEffect = [UIBlurEffect
                                  effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.view addSubview:self.blurView];
    self.blurView.hidden = NO;
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.callSession.callStatus == XLCallActive) {
        [self updateActiveTimer];
        [self startActiveTimer];
    } else if (self.callSession.callStatus == XLCallDialing) {
        self.tipsLabel.text = @"谁正在呼叫谁";
    } else if (self.callSession.callStatus == XLCallIncoming || self.callSession.callStatus == XLCallRinging) {
        if (self.needPlayingRingAfterForeground) {
            [self shouldRingForIncomingCall];
        }
        if (self.callSession.mediaType == XLCallMediaAudio) {
            self.tipsLabel.text = @"语音呼入";
        } else {
            self.tipsLabel.text =@"视频呼入";
        }
    } else if (self.callSession.callStatus == XLCallHangup) {
        //结束电话
        [self callDidDisconnect];
    }
    [self resetLayoutWithMediaType:self.callSession.mediaType
                        callStatus:self.callSession.callStatus];
    
}

- (void)onOrientationChanged:(NSNotification *)notification {
    [self resetLayoutWithMediaType:self.callSession.mediaType
                        callStatus:self.callSession.callStatus];
}


/**
 * 获取会话对象，类型
 
 @return return value description
 */
- (NSString *)targetId {
    return self.callSession.targetId;
}

- (XLCallMediaType)mediaType {
    return self.callSession.mediaType;
}

#pragma mark PublicFunciton
/*!
 通话即将接通
 */
- (void)callWillConnect{
    
}
/*!
 通话即将挂断
 */
- (void)callWillDisconnect{
    
}


/**
 * UI布局
 
 @param mediaType mediaType description
 @param callStatus callStatus description
 */
-(void)resetLayoutWithMediaType:(XLCallMediaType)mediaType callStatus:(XLCallStatus)callStatus{
    if (mediaType == XLCallMediaAudio) {
        self.backgroundView.backgroundColor = UIColorFromRGB(0x262e42);
        self.backgroundView.hidden = NO;
        self.blurView.hidden = NO;
        
        if (callStatus == XLCallActive) {
            [self.minimizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.minimizeButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.minimizeButton.hidden = YES;
        }
        if (callStatus == XLCallActive) {
            [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.bottom.mas_equalTo(self.hangupButton.mas_top).offset(-XLCallInsideMargin);
            }];
            self.timeLabel.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.timeLabel.hidden = YES;
        }
        
        if (callStatus == XLCallHangup) {
            [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
            }];
            self.timeLabel.hidden = NO;
        } else if (callStatus == XLCallActive) {
            [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
            }];
            self.timeLabel.hidden = NO;
        } else {
            [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
            }];
            self.timeLabel.hidden = NO;
        }
        self.tipsLabel.hidden = NO;
        
        if (callStatus == XLCallActive) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.hangupButton.selected  =YES;
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.hangupButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.hangupButton.mas_bottom);
                make.right.mas_equalTo(-XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.speakerButton];
            self.speakerButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.speakerButton.hidden = YES;
        }
        
        if (callStatus == XLCallDialing) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.hangupButton.selected  =YES;
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.hangupButton.selected  =YES;
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.hangupButton.mas_bottom);
                make.right.mas_equalTo(-XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.acceptButton];
            self.acceptButton.hidden = NO;
        } else if (callStatus == XLCallActive) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        }
        
        self.cameraCloseButton.hidden = YES;
        self.cameraSwitchButton.hidden = YES;
        
    } else if (mediaType == XLCallMediaVideo) {
        
        self.backgroundView.backgroundColor = UIColorFromRGB(0x262e42);
        self.backgroundView.hidden = NO;
        self.blurView.hidden = NO;
        
        if (callStatus == XLCallActive) {
            [self.minimizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.minimizeButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.minimizeButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.bottom.mas_equalTo(self.hangupButton.mas_top).offset(-XLCallInsideMargin);
            }];
            self.timeLabel.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.timeLabel.hidden = YES;
        }
        
        if (callStatus == XLCallHangup) {
            [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
            }];
            self.timeLabel.hidden = NO;
        } else if (callStatus == XLCallActive) {
            [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
            }];
            self.timeLabel.hidden = NO;
        } else {
            [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(XLCallLabelHeight);
                make.right.and.left.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
            }];
            self.timeLabel.hidden = NO;
        }
        self.tipsLabel.hidden = NO;
        
        if (callStatus == XLCallActive) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.hangupButton.selected  =YES;
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.hangupButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.hangupButton.mas_bottom);
                make.right.mas_equalTo(-XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.speakerButton];
            self.speakerButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.speakerButton.hidden = YES;
        }
        
        if (callStatus == XLCallDialing) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.hangupButton.selected  =YES;
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            self.hangupButton.selected  =YES;
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.hangupButton.mas_bottom);
                make.right.mas_equalTo(-XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.acceptButton];
            self.acceptButton.hidden = NO;
        } else if (callStatus == XLCallActive) {
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-XLCallVerticalMargin);
                make.left.mas_equalTo(XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            [self.cameraCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.hangupButton.mas_bottom);
                make.right.mas_equalTo(-XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.cameraSwitchButton];
            self.cameraSwitchButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.cameraSwitchButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            [self.cameraCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.hangupButton.mas_bottom);
                make.right.mas_equalTo(-XLCallHorizontalMargin);
                make.size.mas_equalTo(CGSizeMake(XLCallButtonLength, XLCallButtonLength));
            }];
            [self layoutTextUnderImageButton:self.cameraCloseButton];
            self.cameraCloseButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.cameraCloseButton.hidden = YES;
        }
    }
    
}

-(void)callDidDisconnect{
    
    
}
/*!
 点击最小化Button的回调
 */
- (void)didTapMinimizeButton{
    
}
/*!
 点击加人Button的回调
 */
- (void)didTapInviteUserButton{
    
}
/*!
 点击接听Button的回调
 */
- (void)didTapAcceptButton{
    
}

/*!
 点击挂断Button的回调
 */
- (void)didTapHangupButton{
    
}

/*!
 点击扬声器Button的回调
 */
- (void)didTapSpeakerButton{
    
}
/*!
 点击静音Button的回调
 */
- (void)didTapMuteButton{
    
}

/*!
 点击开启、关闭摄像头Button的回调
 */
- (void)didTapCameraCloseButton{
    
}

/*!
 点击切换前后摄像头Button的回调
 */
- (void)didTapCameraSwitchButton{
    
}
#pragma mark PrivateFunciton
- (void)layoutTextUnderImageButton:(UIButton *)button {
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.frame.size.width,
                                              -button.imageView.frame.size.height - XLCallInsideMargin, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-button.titleLabel.intrinsicContentSize.height - XLCallInsideMargin, 0, 0,
                                              -button.titleLabel.intrinsicContentSize.width);
}
- (void)registerTelephonyEvent {
    self.callCenter = [[CTCallCenter alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.callCenter.callEventHandler = ^(CTCall *call) {
        if ([call.callState isEqualToString:CTCallStateConnected]) {
            [weakSelf.callSession hangup];
        }
    };
}

- (void)addProximityMonitoringObserver {
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(proximityStatueChanged:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
}
- (void)removeProximityMonitoringObserver {
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
}
- (void)proximityStatueChanged:(NSNotificationCenter *)notification {
    if ([UIDevice currentDevice].proximityState) {
        [[AVAudioSession sharedInstance]
         setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [[AVAudioSession sharedInstance]
         setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)registerForegroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appDidBecomeActive {
    if (self.needPlayingAlertAfterForeground) {
        [self shouldAlertForWaitingRemoteResponse];
    } else if (self.needPlayingRingAfterForeground) {
        [self shouldRingForIncomingCall];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)shouldAlertForWaitingRemoteResponse {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"voip_calling_ring" ofType:@"mp3"];
        [self startPlayRing:ringPath];
        self.needPlayingAlertAfterForeground = NO;
    } else {
        self.needPlayingAlertAfterForeground = YES;
    }
}
/*!
 收到电话，可以播放铃声
 */
- (void)shouldRingForIncomingCall {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"voip_call.mp3" ofType:@"mp3"];
        [self startPlayRing:ringPath];
        self.needPlayingRingAfterForeground = NO;
    } else {
        self.needPlayingRingAfterForeground = YES;
    }
}
- (void)startPlayRing:(NSString *)ringPath {
    if (ringPath) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        if (self.audioPlayer) {
            [self stopPlayRing];
        }
        
        NSURL *url = [NSURL URLWithString:ringPath];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
}
/*!
 停止播放铃声(通话接通或挂断)
 */
- (void)shouldStopAlertAndRing {
    self.needPlayingRingAfterForeground = NO;
    self.needPlayingAlertAfterForeground = NO;
    [self stopPlayRing];
}

- (void)stopPlayRing {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}


- (void)startActiveTimer {
    self.activeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateActiveTimer)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.activeTimer fire];
}
- (void)stopActiveTimer {
    if (self.activeTimer) {
        [self.activeTimer invalidate];
        self.activeTimer = nil;
    }
}
- (void)updateActiveTimer {
    self.timeLabel.text = [XLCallVideoUtility getTalkTimeStringForTime:100000];
}
#pragma TargetAction
-(void)cameraCloseButtonClicked{
    
    
}
- (void)hangupButtonClicked {
    
}

- (void)acceptButtonClicked {
    
}
// 扬声器
- (void)speakerButtonClicked {
    
}
//静音
- (void)muteButtonClicked {
    
}
//最小
-(void)minimizeButtonClicked{
    
    
}

- (UIButton *)minimizeButton {
    if (!_minimizeButton) {
        _minimizeButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _minimizeButton.backgroundColor = [UIColor redColor];
        [_minimizeButton setImage:[UIImage imageWithColor:[UIColor redColor]]
                         forState:UIControlStateNormal];
        [_minimizeButton setImage:[UIImage imageWithColor:[UIColor redColor]]
                         forState:UIControlStateHighlighted];
        [_minimizeButton addTarget:self
                            action:@selector(minimizeButtonClicked)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_minimizeButton];
        _minimizeButton.hidden = YES;
    }
    return _minimizeButton;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor redColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:18];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_timeLabel];
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.backgroundColor = [UIColor redColor];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.font = [UIFont systemFontOfSize:18];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:_tipsLabel];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (UIButton *)muteButton {
    if (!_muteButton) {
        _muteButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setImage:[UIImage imageWithColor:[UIColor yellowColor]] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                     forState:UIControlStateHighlighted];
        [_muteButton setImage:[UIImage imageWithColor:[UIColor redColor]]
                     forState:UIControlStateSelected];
        [_muteButton setTitle:@"静音"
                     forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(muteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_muteButton];
        _muteButton.backgroundColor = [UIColor redColor];
        _muteButton.hidden = YES;
    }
    return _muteButton;
}

- (UIButton *)speakerButton {
    if (!_speakerButton) {
        _speakerButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_speakerButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                        forState:UIControlStateNormal];
        [_speakerButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                        forState:UIControlStateHighlighted];
        [_speakerButton setImage:[UIImage imageWithColor:[UIColor redColor]]
                        forState:UIControlStateSelected];
        [_speakerButton setTitle:@"扬声器"
                        forState:UIControlStateNormal];
        [_speakerButton addTarget:self
                           action:@selector(speakerButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
        _speakerButton.backgroundColor = [UIColor redColor];
        [self.view addSubview:_speakerButton];
        _speakerButton.hidden = YES;
    }
    return _speakerButton;
}
- (UIButton *)acceptButton {
    if (!_acceptButton) {
        _acceptButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_acceptButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                       forState:UIControlStateNormal];
        [_acceptButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                       forState:UIControlStateHighlighted];
        [_acceptButton setTitle:@"接受"
                       forState:UIControlStateNormal];
        
        [_acceptButton addTarget:self
                          action:@selector(acceptButtonClicked)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_acceptButton];
        
        _acceptButton.backgroundColor = [UIColor redColor];
        _acceptButton.hidden = YES;
    }
    return _acceptButton;
}

- (UIButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_hangupButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                       forState:UIControlStateNormal];
        [_hangupButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                       forState:UIControlStateHighlighted];
        [_hangupButton setTitle:@"拒绝"
                       forState:UIControlStateNormal];
        
        [_hangupButton addTarget:self
                          action:@selector(hangupButtonClicked)
                forControlEvents:UIControlEventTouchUpInside];
        _hangupButton.backgroundColor = [UIColor redColor];
        [self.view addSubview:_hangupButton];
        _hangupButton.hidden = YES;
    }
    return _hangupButton;
}

- (UIButton *)cameraCloseButton {
    if (!_cameraCloseButton) {
        
        _cameraCloseButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraCloseButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                            forState:UIControlStateNormal];
        [_cameraCloseButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                            forState:UIControlStateHighlighted];
        [_cameraCloseButton setImage:[UIImage imageWithColor:[UIColor yellowColor]]
                            forState:UIControlStateSelected];
        [_cameraCloseButton setTitle:@"关闭摄像头"
                            forState:UIControlStateNormal];
        [_cameraCloseButton setTitle:@"打开摄像头"
                            forState:UIControlStateSelected];
        [_cameraCloseButton addTarget:self
                               action:@selector(cameraCloseButtonClicked)
                     forControlEvents:UIControlEventTouchUpInside];
        _cameraCloseButton.backgroundColor = [UIColor redColor];
        [self.view addSubview:_cameraCloseButton];
        _cameraCloseButton.hidden = YES;
    }
    return _cameraCloseButton;
}

@end

