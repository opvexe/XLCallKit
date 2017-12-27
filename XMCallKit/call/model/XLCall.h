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

#pragma mark < 弹出或关闭视图 >

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

#pragma mark  < 发起会话 >

/*!
 发起单人通话(视频或语音)
 
 @param targetId  对方的用户ID
 @param mediaType 使用的媒体类型
 */
- (void)startSingleCall:(NSString *)targetId mediaType:(XLCallMediaType)mediaType;


/*!
 直接发起多人通话
 
 @param targetId         会话目标ID
 @param mediaType        使用的媒体类型
 @param userIdList       邀请的用户ID列表
 
 @discussion 此方法会直接发起通话。目前支持的会话类型有讨论组和群组。
 
 @warning 您需要设置并实现groupMemberDataSource才能加人。
 */
- (void)startMultiCallViewController:(NSString *)targetId
                           mediaType:(XLCallMediaType)mediaType
                          userIdList:(NSArray *)userIdList;

@end

