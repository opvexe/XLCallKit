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


- (instancetype)initWithIncomingCall:(XLCallSession *)callSession {
    self = [super init];
    if (self) {
        _callSession = callSession;
        [self registerForegroundNotification];
        [_callSession setDelegate:self];
    }
    return self;
}

-(instancetype)initWithOutgoingCallTargetId:(NSString *)targetId mediaType:(XLCallMediaType)mediaType userIdList:(NSArray *)userIdList{
    self = [super init];
    if (self) {
        _callSession = [[XLCallClient sharedXLCallClient]startTargetId:targetId to:userIdList mediaType:mediaType sessionDelegate:self];
        [self registerForegroundNotification];
    }
    return self;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
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
    
    [self resetLayout:self.callSession.isMultiCall mediaType:self.callSession.mediaType callStatus:4];
}

- (void)onOrientationChanged:(NSNotification *)notification {
    [self resetLayout:self.callSession.isMultiCall mediaType:self.callSession.mediaType callStatus:self.callSession.callStatus];
}

#pragma mark ===========================================    <PrivateFunciton>  ===========================================
- (void)layoutTextUnderImageButton:(UIButton *)button {
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.frame.size.width,
                                              -button.imageView.frame.size.height - LSWMCallInsideMargin, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-button.titleLabel.intrinsicContentSize.height - LSWMCallInsideMargin, 0, 0,
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


- (void)stopPlayRing {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}


/*!
 重新Layout布局
 
 @param isMultiCall      是否多方通话
 @param mediaType        通话媒体类型
 @param callStatus       通话状态
 
 @discussion 如果您需要重写并调整UI的布局，应该先调用super。
 */
- (void)resetLayout:(BOOL)isMultiCall mediaType:(XLCallMediaType)mediaType callStatus:(XLCallStatus)callStatus{
    if (mediaType == XLCallMediaAudio && !isMultiCall) {
        self.backgroundView.backgroundColor = UIColorFromRGB(0x262e42);
        self.backgroundView.hidden = NO;
        
        self.blurView.hidden = NO;
        
        if (callStatus == XLCallActive) {
            self.minimizeButton.frame = CGRectMake(LSWMCallHorizontalMargin / 2, LSWMCallVerticalMargin,
                                                   LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.minimizeButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.minimizeButton.hidden = YES;
        }
        
        self.inviteUserButton.hidden = YES;
        
        if (callStatus == XLCallActive) {
            self.timeLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin * 2 + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.timeLabel.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.timeLabel.hidden = YES;
        }
        
        if (callStatus == XLCallHangup) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength -
                       LSWMCallInsideMargin * 3 - LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else if (callStatus == XLCallActive) {
            self.tipsLabel.frame = CGRectMake(
                                              LSWMCallHorizontalMargin,
                                              MAX((self.view.frame.size.height - LSWMCallLabelHeight) / 2,
                                                  LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin * 3 + LSWMCallLabelHeight * 2),
                                              self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin * 2 + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        }
        self.tipsLabel.hidden = NO;
        
        if (callStatus == XLCallActive) {
            self.muteButton.frame = CGRectMake(LSWMCallHorizontalMargin,
                                               self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                               LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.muteButton];
            self.muteButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.muteButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.speakerButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.speakerButton];
            self.speakerButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.speakerButton.hidden = YES;
        }
        
        if (callStatus == XLCallDialing) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.hangupButton.frame = CGRectMake(
                                                 LSWMCallHorizontalMargin, self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                                 LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.acceptButton];
            self.acceptButton.hidden = NO;
        } else if (callStatus == XLCallActive) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        }
        
        self.cameraCloseButton.hidden = YES;
        self.cameraSwitchButton.hidden = YES;
        
    } else if (mediaType == XLCallMediaVideo && !isMultiCall) {
        self.backgroundView.hidden = NO;
        
        self.blurView.hidden = YES;
        
        if (callStatus == XLCallActive) {
            self.minimizeButton.frame = CGRectMake(LSWMCallHorizontalMargin / 2, LSWMCallVerticalMargin,
                                                   LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.minimizeButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.minimizeButton.hidden = YES;
        }
        
        self.inviteUserButton.hidden = YES;
        
        if (callStatus == XLCallActive) {
            self.timeLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin + LSWMCallInsideMargin + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.timeLabel.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.timeLabel.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       MAX((self.view.frame.size.height - LSWMCallLabelHeight) / 2,
                           LSWMCallVerticalMargin + LSWMCallHeaderLength * 1.5 + LSWMCallInsideMargin * 3),
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else if (callStatus == XLCallDialing) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin * 2 + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       LSWMCallVerticalMargin * 3 + LSWMCallHeaderLength + LSWMCallInsideMargin * 2 + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else if (callStatus == XLCallHangup) {
            self.tipsLabel.frame = CGRectMake(
                                              LSWMCallHorizontalMargin,
                                              self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength * 2 - LSWMCallInsideMargin * 8,
                                              self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        }
        self.tipsLabel.hidden = NO;
        
        if (callStatus == XLCallActive) {
            self.muteButton.frame = CGRectMake(LSWMCallHorizontalMargin,
                                               self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                               LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.muteButton];
            self.muteButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.muteButton.hidden = YES;
        }
        
        self.speakerButton.hidden = YES;
        
        if (callStatus == XLCallDialing) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.hangupButton.frame = CGRectMake(
                                                 LSWMCallHorizontalMargin, self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                                 LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.acceptButton];
            self.acceptButton.hidden = NO;
        } else if (callStatus == XLCallActive) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.cameraSwitchButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.cameraSwitchButton];
            self.cameraSwitchButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.cameraSwitchButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.cameraCloseButton.frame = CGRectMake(
                                                      self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                                                      self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength * 2 - LSWMCallInsideMargin * 5,
                                                      LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.cameraCloseButton];
            self.cameraCloseButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.cameraCloseButton.hidden = YES;
        }
        
    } else if (mediaType == XLCallMediaAudio && isMultiCall) {
        self.backgroundView.backgroundColor = UIColorFromRGB(0x262e42);
        self.backgroundView.hidden = NO;
        
        self.blurView.hidden = NO;
        
        if (callStatus == XLCallActive) {
            self.minimizeButton.frame = CGRectMake(LSWMCallHorizontalMargin / 2, LSWMCallVerticalMargin,
                                                   LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.minimizeButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.minimizeButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.inviteUserButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin / 2 - LSWMCallButtonLength / 2,
                       LSWMCallVerticalMargin, LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.inviteUserButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.inviteUserButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.timeLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.timeLabel.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.timeLabel.hidden = YES;
        }
        
        // header orgin y = LSWMCallVerticalMargin * 2
        if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       LSWMCallVerticalMargin * 2 + LSWMCallHeaderLength + LSWMCallInsideMargin * 2 + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else if (callStatus == XLCallDialing) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength -
                       LSWMCallInsideMargin * 3 - LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        }
        self.tipsLabel.hidden = NO;
        
        if (callStatus == XLCallActive) {
            self.muteButton.frame = CGRectMake(LSWMCallHorizontalMargin,
                                               self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                               LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.muteButton];
            self.muteButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.muteButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.speakerButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.speakerButton];
            self.speakerButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.speakerButton.hidden = YES;
        }
        
        if (callStatus == XLCallDialing) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.hangupButton.frame = CGRectMake(
                                                 LSWMCallHorizontalMargin, self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                                 LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.acceptButton];
            self.acceptButton.hidden = NO;
        } else if (callStatus == XLCallActive) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        }
        
        self.cameraCloseButton.hidden = YES;
        self.cameraSwitchButton.hidden = YES;
        
    } else if (mediaType == XLCallMediaVideo && isMultiCall) {
        self.backgroundView.hidden = NO;
        
        self.blurView.hidden = YES;
        
        if (callStatus == XLCallActive) {
            self.minimizeButton.frame = CGRectMake(LSWMCallHorizontalMargin / 2, LSWMCallVerticalMargin,
                                                   LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.minimizeButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.minimizeButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.cameraSwitchButton.frame = CGRectMake(
                                                       self.view.frame.size.width - LSWMCallHorizontalMargin / 2 - LSWMCallButtonLength - LSWMCallInsideMargin,
                                                       LSWMCallVerticalMargin, LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.cameraSwitchButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.cameraSwitchButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.inviteUserButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin / 2 - LSWMCallButtonLength / 2,
                       LSWMCallVerticalMargin, LSWMCallButtonLength / 2, LSWMCallButtonLength / 2);
            self.inviteUserButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.inviteUserButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.timeLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin + LSWMCallInsideMargin + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
            self.timeLabel.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.timeLabel.hidden = YES;
        }
        
        if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       LSWMCallVerticalMargin * 2 + LSWMCallHeaderLength + LSWMCallInsideMargin * 2 + LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else if (callStatus == XLCallDialing) {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin, LSWMCallVerticalMargin,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        } else {
            self.tipsLabel.frame =
            CGRectMake(LSWMCallHorizontalMargin,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength * 3.5 -
                       LSWMCallInsideMargin * 5 - LSWMCallLabelHeight,
                       self.view.frame.size.width - LSWMCallHorizontalMargin * 2, LSWMCallLabelHeight);
        }
        self.tipsLabel.hidden = NO;
        
        if (callStatus == XLCallActive) {
            self.muteButton.frame = CGRectMake(LSWMCallHorizontalMargin,
                                               self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                               LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.muteButton];
            self.muteButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.muteButton.hidden = YES;
        }
        
        self.speakerButton.hidden = YES;
        
        if (callStatus == XLCallDialing) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        } else if (callStatus == XLCallIncoming || callStatus == XLCallRinging) {
            self.hangupButton.frame = CGRectMake(
                                                 LSWMCallHorizontalMargin, self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength,
                                                 LSWMCallButtonLength, LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.acceptButton];
            self.acceptButton.hidden = NO;
        } else if (callStatus == XLCallActive) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - LSWMCallButtonLength) / 2,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton];
            self.hangupButton.hidden = NO;
            
            self.acceptButton.hidden = YES;
        }
        
        if (callStatus == XLCallActive) {
            self.cameraCloseButton.frame =
            CGRectMake(self.view.frame.size.width - LSWMCallHorizontalMargin - LSWMCallButtonLength,
                       self.view.frame.size.height - LSWMCallVerticalMargin - LSWMCallButtonLength, LSWMCallButtonLength,
                       LSWMCallButtonLength);
            [self layoutTextUnderImageButton:self.cameraCloseButton];
            self.cameraCloseButton.hidden = NO;
        } else if (callStatus != XLCallHangup) {
            self.cameraCloseButton.hidden = YES;
        }
    }
}

#pragma mark  =========================================         <定时器开始计时>              =========================================================
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

#pragma mark  ===========================================              <懒加载控件>              ========================================================
- (UIButton *)minimizeButton {
    if (!_minimizeButton) {
        _minimizeButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _minimizeButton.frame =CGRectMake(LSWMCallHorizontalMargin / 2, LSWMCallVerticalMargin / 2,
                                          LSWMCallButtonLength, LSWMCallButtonLength);
        [_minimizeButton setImage:[UIImage imageNamed:@"minimize.png"]
                         forState:UIControlStateNormal];
        [_minimizeButton setImage:[UIImage imageNamed:@"minimize.png"]
                         forState:UIControlStateHighlighted];
        
        [_minimizeButton addTarget:self action:@selector(minimizeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_minimizeButton];
        _minimizeButton.hidden = YES;
    }
    return _minimizeButton;
}

- (UIButton *)inviteUserButton {
    if (!_inviteUserButton) {
        _inviteUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _inviteUserButton.frame =CGRectMake(LSWMCallHorizontalMargin / 2, LSWMCallVerticalMargin / 2,
                                            LSWMCallButtonLength, LSWMCallButtonLength);
        [_inviteUserButton setImage:[UIImage imageNamed:@"add"]
                           forState:UIControlStateNormal];
        [_inviteUserButton setImage:[UIImage imageNamed:@"add"]
                           forState:UIControlStateHighlighted];
        
        [_inviteUserButton addTarget:self
                              action:@selector(inviteUserButtonClicked)
                    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_inviteUserButton];
        _inviteUserButton.hidden = YES;
    }
    return _inviteUserButton;
}

- (void)inviteUserButtonClicked {
    [self didTapInviteUserButton];
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:18];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"1000秒";
        [self.view addSubview:_timeLabel];
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.font = [UIFont systemFontOfSize:18];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.text = @"网络异常";
        [self.view addSubview:_tipsLabel];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (UIButton *)muteButton {
    if (!_muteButton) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"mute_hover"]
                     forState:UIControlStateHighlighted];
        [_muteButton setImage:[UIImage imageNamed:@"mute_hover"]
                     forState:UIControlStateSelected];
        [_muteButton setTitle:@"静音"
                     forState:UIControlStateNormal];
        [_muteButton setSelected:self.callSession.isMuted];
        [_muteButton addTarget:self action:@selector(muteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_muteButton];
        _muteButton.hidden = YES;
    }
    return _muteButton;
}
- (UIButton *)speakerButton {
    if (!_speakerButton) {
        _speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speakerButton setImage:[UIImage imageNamed:@"handfree.png"]
                        forState:UIControlStateNormal];
        [_speakerButton setImage:[UIImage imageNamed:@"handfree_hover.png"]
                        forState:UIControlStateHighlighted];
        [_speakerButton setImage:[UIImage imageNamed:@"handfree_hover.png"]
                        forState:UIControlStateSelected];
        [_speakerButton setTitle:@"免提"
                        forState:UIControlStateNormal];
        [_speakerButton setSelected:self.callSession.speakerEnabled];
        
        [_speakerButton addTarget:self
                           action:@selector(speakerButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_speakerButton];
        _speakerButton.hidden = YES;
    }
    return _speakerButton;
}

- (UIButton *)acceptButton {
    if (!_acceptButton) {
        _acceptButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_acceptButton setImage:[UIImage imageNamed:@"answer.png"]
                       forState:UIControlStateNormal];
        [_acceptButton setImage:[UIImage imageNamed:@"answer_hover.png"]
                       forState:UIControlStateHighlighted];
        [_acceptButton setTitle:@"接听"
                       forState:UIControlStateNormal];
        
        [_acceptButton addTarget:self
                          action:@selector(acceptButtonClicked)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_acceptButton];
        _acceptButton.hidden = YES;
    }
    return _acceptButton;
}

- (UIButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_hangupButton setImage:[UIImage imageNamed:@"hang_up.png"]
                       forState:UIControlStateNormal];
        [_hangupButton setImage:[UIImage imageNamed:@"hang_up_hover.png"]
                       forState:UIControlStateHighlighted];
        [_hangupButton setTitle:@"挂断"
                       forState:UIControlStateNormal];
        
        [_hangupButton addTarget:self
                          action:@selector(hangupButtonClicked)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_hangupButton];
        _hangupButton.hidden = YES;
    }
    return _hangupButton;
}

- (UIButton *)cameraCloseButton {
    if (!_cameraCloseButton) {
        _cameraCloseButton =[UIButton buttonWithType:UIButtonTypeCustom];
        
        if (!self.callSession.isMultiCall) {
            [_cameraCloseButton setImage:[UIImage imageNamed:@"audio.png"]
                                forState:UIControlStateNormal];
            [_cameraCloseButton setImage:[UIImage imageNamed:@"audio.png"]
                                forState:UIControlStateHighlighted];
            [_cameraCloseButton
             setTitle:@"语音聊天"
             forState:UIControlStateNormal];
        } else {
            [_cameraCloseButton setImage:[UIImage imageNamed:@"video.png"]
                                forState:UIControlStateNormal];
            [_cameraCloseButton setImage:[UIImage imageNamed:@"video.png"]
                                forState:UIControlStateHighlighted];
            [_cameraCloseButton setImage:[UIImage imageNamed:@"video_hover.png"]
                                forState:UIControlStateSelected];
            [_cameraCloseButton setTitle:@"关闭摄像头"
                                forState:UIControlStateNormal];
            [_cameraCloseButton setTitle:@"开启摄像头"
                                forState:UIControlStateSelected];
        }
        [_cameraCloseButton setSelected:!self.callSession.cameraEnabled];
        [_cameraCloseButton addTarget:self
                               action:@selector(cameraCloseButtonClicked)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_cameraCloseButton];
        _cameraCloseButton.hidden = YES;
    }
    return _cameraCloseButton;
}

- (UIButton *)cameraSwitchButton {
    if (!_cameraSwitchButton) {
        _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (!self.callSession.isMultiCall) {
            [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera.png"]
                                 forState:UIControlStateNormal];
            [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera_hover.png"]
                                 forState:UIControlStateHighlighted];
            [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera_hover.png"]
                                 forState:UIControlStateSelected];
            [_cameraSwitchButton setTitle:@"摄像头"
                                 forState:UIControlStateNormal];
            [_cameraSwitchButton setTitle:@"摄像头"
                                 forState:UIControlStateSelected];
        } else {
            [_cameraSwitchButton setImage:[UIImage imageNamed:@"change.png"]
                                 forState:UIControlStateNormal];
            [_cameraSwitchButton setImage:[UIImage imageNamed:@"change.png"]
                                 forState:UIControlStateHighlighted];
            [_cameraSwitchButton setImage:[UIImage imageNamed:@"change.png"]
                                 forState:UIControlStateSelected];
        }
        
        [_cameraSwitchButton addTarget:self
                                action:@selector(cameraSwitchButtonClicked)
                      forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_cameraSwitchButton];
        _cameraSwitchButton.hidden = YES;
    }
    return _cameraSwitchButton;
}

#pragma mark  ================================================       <XLCallSessionDelegate>               ================================================

/*!
 通话已接通
 */
- (void)callDidConnect{
    [self callWillConnect];
    self.tipsLabel.text = @"";
    [self startActiveTimer];
    [self resetLayout:self.callSession.isMultiCall
            mediaType:self.callSession.mediaType
           callStatus:self.callSession.callStatus];
}

/*!
 结束通话
 */
-(void)callDidDisconnect{
    [self callWillDisconnect];
    [XLCallVideoUtility clearCallIdleTimerDisableds];
    if (self.callSession.connectedTime > 0) {
        self.tipsLabel.text =@"通话结束";
    } else {
        self.tipsLabel.text =
        [XLCallVideoUtility getReadableStringForCallViewController:self.callSession.disconnectReason];
    }
    self.tipsLabel.textColor = [UIColor whiteColor];
    
    [self stopActiveTimer];
    [self resetLayout:self.callSession.isMultiCall mediaType:self.callSession.mediaType callStatus:self.callSession.callStatus];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[XLCall sharedXLCall]dismissCallViewController:self];
    });
    
    [self removeProximityMonitoringObserver];
}

/*!
 对端正在振铃
 
 @param userId 对端的用户ID
 */
- (void)remoteUserDidRing:(NSString *)userId {
    [self resetLayout:self.callSession.isMultiCall
            mediaType:self.callSession.mediaType
           callStatus:self.callSession.callStatus];
}

/*!
 有用户被邀请加入通话
 
 @param userId    被邀请的用户ID
 @param mediaType 希望被邀请者选择的媒体类型
 */
- (void)remoteUserDidInvite:(NSString *)userId mediaType:(XLCallMediaType)mediaType {
    [self resetLayout:self.callSession.isMultiCall
            mediaType:self.callSession.mediaType
           callStatus:self.callSession.callStatus];
}


/*!
 有用户加入了通话
 
 @param userId    用户ID
 @param mediaType 用户的媒体类型
 */
- (void)remoteUserDidJoin:(NSString *)userId mediaType:(XLCallMediaType)mediaType {
    [self resetLayout:self.callSession.isMultiCall
            mediaType:self.callSession.mediaType
           callStatus:self.callSession.callStatus];
}

/*!
 有用户切换了媒体类型
 
 @param userId    用户ID
 @param mediaType 切换至的媒体类型
 */
- (void)remoteUserDidChangeMediaType:(NSString *)userId mediaType:(XLCallMediaType)mediaType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.callSession.isMultiCall) {
            if (mediaType == XLCallMediaAudio && self.callSession.mediaType != XLCallMediaAudio) {
                if ([self.callSession changeMediaType:XLCallMediaAudio]) {
                    [self.callSession setVideoView:nil userId:[[XLUserInfoCacheManager getUser]userId]];
                    [self.callSession setVideoView:nil userId:self.callSession.targetId];
                    [self resetLayout:self.callSession.isMultiCall
                            mediaType:XLCallMediaAudio
                           callStatus:self.callSession.callStatus];
                }
            }
        } else if (self.callSession.mediaType == mediaType && mediaType == XLCallMediaVideo) {
            [self remoteUserDidDisableCamera:NO byUser:userId];
        }
    });
}

/*!
 对端用户关闭/打开了摄像头
 
 @param userId    用户ID
 @param muted     是否关闭camera
 */
- (void)remoteUserDidDisableCamera:(BOOL)muted byUser:(NSString *)userId {
    [self resetLayout:self.callSession.isMultiCall
            mediaType:self.callSession.mediaType
           callStatus:self.callSession.callStatus];
}

/*!
 有用户挂断
 
 @param userId 用户ID
 @param reason 挂断的原因
 */
- (void)remoteUserDidLeft:(NSString *)userId reason:(XLCallDisconnectReason)reason {
    [self resetLayout:self.callSession.isMultiCall
            mediaType:self.callSession.mediaType
           callStatus:self.callSession.callStatus];
}

/*!
 对方正在振铃，可以播放对应的彩铃
 */
- (void)shouldAlertForWaitingRemoteResponse {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"voip_calling_ring.mp3" ofType:@"mp3"];
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

/*!
 停止播放铃声(通话接通或挂断)
 */
- (void)shouldStopAlertAndRing {
    self.needPlayingRingAfterForeground = NO;
    self.needPlayingAlertAfterForeground = NO;
    [self stopPlayRing];
}

/*!
 通话过程中的错误回调
 
 @param error 错误码
 
 @warning 如果是不可恢复的错误，SDK会挂断电话并回调callDidDisconnect。
 */
- (void)errorDidOccur:(XLCallErrorCode)error {
    if ([self respondsToSelector:@selector(tipsWillShow:)]) {
        if (![self tipsWillShow:error]) {
            return;
        }
    }
    self.tipsLabel.text = [NSString stringWithFormat:@"错误码：%ld",(long)error];
}


/*!
 当前通话网络状态的回调，该回调方法每两秒触发一次
 
 @param txQuality   上行网络质量
 @param rxQuality   下行网络质量
 */
- (void)networkTxQuality:(AgoraRtcQuality)txQuality rxQuality:(AgoraRtcQuality)rxQuality{
    NSLog(@"networkTxQuality, %lu, %lu", (unsigned long)txQuality, (unsigned long)rxQuality);
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

#pragma mark  ======================================   <Button点击事件>       ================================
/*!
 摄像头前置后置
 */
-(void)cameraSwitchButtonClicked{
}

/*!
 开启关闭摄像头
 */
-(void)cameraCloseButtonClicked{
}

/*!
 挂断
 */
- (void)hangupButtonClicked {
}

/*!
 接听
 */
- (void)acceptButtonClicked {
}

/*!
 扬声器
 */
- (void)speakerButtonClicked {
    
}

/*!
 静音
 */
- (void)muteButtonClicked {
    
}

/*!
 最小化
 */
-(void)minimizeButtonClicked{
    
}

/*
 错误回调
 */
- (BOOL)tipsWillShow:(XLCallErrorCode)warning {
    return YES;
}
/*
 点击最小化Button的回调
 */
- (void)didTapMinimizeButton{
    
}
/*
 点击加人Button的回调
 */
- (void)didTapInviteUserButton{
    
}
/*
 点击接听Button的回调
 */
- (void)didTapAcceptButton{
    
}

/*
 点击挂断Button的回调
 */
- (void)didTapHangupButton{
    
}

/*
 点击扬声器Button的回调
 */
- (void)didTapSpeakerButton{
    
}
/*
 点击静音Button的回调
 */
- (void)didTapMuteButton{
    
}

/*
 点击开启、关闭摄像头Button的回调
 */
- (void)didTapCameraCloseButton{
    
}

/*
 点击切换前后摄像头Button的回调
 */
- (void)didTapCameraSwitchButton{
    
}
@end

