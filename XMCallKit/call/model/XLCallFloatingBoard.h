//
//  XLCallFloatingBoard.h
//  XMCallKit
//
//  Created by Facebook on 2018/1/4.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 最小化显示的悬浮窗
 */
@interface XLCallFloatingBoard : NSObject

/*!
 悬浮窗的Window
 */
@property(nonatomic, strong) UIWindow *window;

/*!
 音频通话最小化时的Button
 */
@property(nonatomic, strong) UIButton *floatingButton;

/*!
 视频通话最小化时的视频View
 */
@property(nonatomic, strong) UIView *videoView;

/*!
 当前的通话实体
 */
@property(nonatomic, strong) XLCallSession *callSession;


/*!
 开启悬浮窗
 
 @param callSession  通话实体
 @param touchedBlock 悬浮窗点击的Block
 */
+ (void)startCallFloatingBoard:(XLCallSession *)callSession
              withTouchedBlock:(void (^)(XLCallSession *callSession))touchedBlock;

/*!
 关闭当前悬浮窗
 */
+ (void)stopCallFloatingBoard;

@end
