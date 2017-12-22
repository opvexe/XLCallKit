//
//  XLCallColorFontDefine.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#ifndef XLCallColorFontDefine_h
#define XLCallColorFontDefine_h

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
#define XLCallButtonLength Number(64.0f)
#define XLCallLabelHeight NumberHeight(25.0f)
#define XLCallVerticalMargin NumberHeight(67.0f)
#define XLCallHorizontalMargin Number(37.0f)
#define XLCallInsideMargin Number(5.0f)
#define XLCallPaddingMargin Number(20.0f)

#endif /* XLCallColorFontDefine_h */
