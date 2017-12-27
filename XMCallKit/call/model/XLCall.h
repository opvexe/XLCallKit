//
//  XLCall.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 CallKit核心类
 */
@interface XLCall : NSObject

/*!
 当前的通话会话实体
 */
@property(nonatomic, strong)XLCallSession *currentCallSession;
/*!
 音频通话支持的最大通话人数
 */
@property(nonatomic, assign) int maxMultiAudioCallUserNumber;

/*!
 视频通话支持的最大通话人数
 */
@property(nonatomic, assign) int maxMultiVideoCallUserNumber;



/*!
 Call的核心类
 */
+ (instancetype)sharedXLCall;

/*!
 弹出通话ViewController或选择成员ViewController
 
 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)presentCallViewController:(UIViewController *)viewController;

/*!
 取消通话ViewController或选择成员ViewController
 
 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)dismissCallViewController:(UIViewController *)viewController;

@end

