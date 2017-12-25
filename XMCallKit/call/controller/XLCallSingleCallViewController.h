//
//  XLCallSingleCallViewController.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>


/*!
 单人音视频ViewController
 */

@interface XLCallSingleCallViewController : XLCallBaseViewController

/*!
 对端的头像View
 */
@property(nonatomic, strong) UIImageView *remotePortraitView;

/*!
 对端的名字Label
 */
@property(nonatomic, strong) UILabel *remoteNameLabel;

/*!
 用户状态的view
 */
@property(nonatomic, strong) UIImageView *statusView;

/*!
 全屏的视频View
 */
@property(nonatomic, strong) UIView *mainVideoView;

/*!
 通话接通后，界面右上角的视频View
 */
@property(nonatomic, strong) UIView *subVideoView;


#pragma mark - 初始化

/*!
 初始化单人音视频ViewController并发起通话
 
 @param targetId         会话ID
 @param mediaType        通话媒体类型
 
 @return 单人音视频ViewController
 */
- (instancetype)initWithOutgoingCall:(NSString *)targetId mediaType:(XLCallMediaType)mediaType;


@end
