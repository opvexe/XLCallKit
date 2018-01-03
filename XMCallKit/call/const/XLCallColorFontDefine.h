//
//  XLCallColorFontDefine.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#ifndef XLCallColorFontDefine_h
#define XLCallColorFontDefine_h

//防止循环引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define WSSTRONG(strongSelf) __strong typeof(weakSelf) strongSelf = weakSelf;

///color
#define ColorRandom  [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define LSSCALWIDTH (SCREEN_WIDTH/375.0)
#define LSSCALHEIGHT (SCREEN_HEIGHT/667.0)
#define Number(num)                      (num*LSSCALWIDTH)
#define NumberHeight(num)                (num*LSSCALHEIGHT)

#define LSWMCallHeaderLength Number(80.0f)
#define LSWMCallButtonLength Number(64.0f)
#define LSWMCallLabelHeight NumberHeight(25.0f)
#define LSWMCallVerticalMargin NumberHeight(32.0f)
#define LSWMCallHorizontalMargin Number(25.0f)
#define LSWMCallInsideMargin Number(5.0f)


#endif /* XLCallColorFontDefine_h */
