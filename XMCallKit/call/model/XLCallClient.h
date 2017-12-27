//
//  XLCallClient.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLCallReceiveDelegate.h"

/*!
 * 全局通话呼入的监听器
 */
@interface XLCallClient : NSObject

/*!
 * Call的核心类单例
 */

+ (instancetype)sharedXLCallClient;

/*!
 设置信令
 
 */
@property(nonatomic,readonly,strong)AgoraAPI *callAgoraApi;

/*!
 设置全局通话呼入的监听器
 
 @param delegate CallLib全局通话呼入的监听器
 */
- (void)setDelegate:(id<XLCallReceiveDelegate>)delegate;

/*!
 当前的通话会话实体
 */
@property(nonatomic, strong, readonly) XLCallSession *currentCallSession;

/*!
 信令登录
 */
-(void)login;

/*!
 信令退出登录
 */
-(void)logout;

/*!
 是否生成通话记录消息，默认为YES
 */
@property(nonatomic, assign) BOOL enableCallSummary;

@end

