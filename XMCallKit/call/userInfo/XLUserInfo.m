//
//  XLUserInfo.m
//  XMCallKit
//
//  Created by Facebook on 2018/1/3.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "XLUserInfo.h"

#define UserPath  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"xlUserInfoCache.plist"]
@implementation XLUserInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.portraitUri forKey:@"portraitUri"];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.portraitUri = [aDecoder decodeObjectForKey:@"portraitUri"];
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait{
    if (self = [super init]) {
        self.userId = userId;
        self.name = username;
        self.portraitUri = portrait;
    }
    return self;
}
@end
 


@implementation  XLUserInfoCacheManager 

//账户信息存储
+ (BOOL)saveUser:(XLUserInfo *)user
{
    return [NSKeyedArchiver archiveRootObject:user toFile:UserPath];
}

//账户信息获取
+ (XLUserInfo *)getUser
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:UserPath];
}

//账户信息删除
+ (BOOL)deleteUser
{
    return [[NSFileManager defaultManager] removeItemAtPath:UserPath error:nil];
}

@end
