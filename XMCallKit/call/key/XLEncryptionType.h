//
//  XLEncryptionType.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 加密类型
 */

typedef NS_ENUM(int, EncrypType) {
    /*!
     AES_128加密
     */
    EncrypTypeXTS128,
    
    /*!
     AES_256加密
     */
    EncrypTypeXTS256       
};

@interface XLEncryptionType : NSObject

+ (NSString *)modeStringWithEncrypType:(EncrypType)type;

+ (NSString *)descriptionWithEncrypType:(EncrypType)type;

+ (NSArray *)encrypTypeArray;
@end
