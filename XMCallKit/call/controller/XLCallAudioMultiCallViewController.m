//
//  XLCallAudioMultiCallViewController.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLCallAudioMultiCallViewController.h"

@interface XLCallAudioMultiCallViewController ()
@property(nonatomic, strong) NSMutableArray *subUserModelList;
@end

@implementation XLCallAudioMultiCallViewController

- (instancetype)initWithOutgoingCallTargetId:(NSString *)targetId
                                  userIdList:(NSArray *)userIdList{
    return [super initWithOutgoingCallTargetId:targetId mediaType:XLCallMediaAudio userIdList:userIdList];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
