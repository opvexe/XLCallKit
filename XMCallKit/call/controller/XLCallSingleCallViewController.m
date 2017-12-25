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


@end
