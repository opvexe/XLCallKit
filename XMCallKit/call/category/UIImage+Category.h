//
//  UIImage+Category.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

/**
 Description

 @param color color description
 @param size size description
 @param radius radius description
 @return return value description
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)radius;

/**
 Description

 @param color color description
 @param size size description
 @return return value description
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


/**
 Description

 @param color color description
 @return return value description
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


@end
