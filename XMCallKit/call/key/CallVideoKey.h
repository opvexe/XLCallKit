//
//  CallVideoKey.h
//  XMCallKit
//
//  Created by Facebook on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallVideoKey : NSObject

+ (NSString *) createMediaKeyByAppID:(NSString*)appID
                      appCertificate:(NSString*)appCertificate
                         channelName:(NSString*)channelName
                              unixTs:(uint32_t)unixTs
                           randomInt:(uint32_t)randomInt
                                 uid:(uint32_t)uid
                           expiredTs:(uint32_t)expiredTs
;

@end
