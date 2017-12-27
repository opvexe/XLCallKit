//
//  XLEncryptionType.m
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "XLEncryptionType.h"

@implementation XLEncryptionType

+ (NSString *)modeStringWithEncrypType:(EncrypType)type {
    switch (type) {
        case EncrypTypeXTS128: return @"aes-128-xts"; break;
            
        case EncrypTypeXTS256: return @"aes-256-xts"; break;
            
        default: return @""; break;
    }
}

+ (NSString *)descriptionWithEncrypType:(EncrypType)type {
    switch (type) {
        case EncrypTypeXTS128: return @"AES 128"; break;
            
        case EncrypTypeXTS256: return @"AES 256"; break;
            
        default: return @""; break;
    }
}

+ (NSArray *)encrypTypeArray {
    return @[@(EncrypTypeXTS128), @(EncrypTypeXTS256)];
}

@end
