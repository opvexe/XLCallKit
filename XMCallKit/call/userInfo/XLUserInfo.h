//
//  XLUserInfo.h
//  XMCallKit
//
//  Created by Facebook on 2018/1/3.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLUserInfo : NSObject<NSCoding>
/*!
 用户ID
 */
@property(nonatomic, strong) NSString *userId;

/*!
 用户名称
 */
@property(nonatomic, strong) NSString *name;

/*!
 用户头像的URL
 */
@property(nonatomic, strong) NSString *portraitUri;

/*!
 用户信息的初始化方法
 
 @param userId      用户ID
 @param username    用户名称
 @param portrait    用户头像的URL
 @return            用户信息对象
 */
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait;
@end


@interface XLUserInfoCacheManager : NSObject

/**
 账户信息存储
 
 @param user 账户信息
 @return 是否存储成功
 */
+ (BOOL)saveUser:(XLUserInfo *)user;

/**
 账户信息获取
 
 @return 账户信息
 */
+ (XLUserInfo *)getUser;

/**
 账户信息删除
 
 @return 是否删除成功
 */
+ (BOOL)deleteUser;
@end
