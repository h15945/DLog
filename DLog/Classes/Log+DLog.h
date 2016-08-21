//
//  Log + DLog.h
//  DLog
//
//  Created by roryhuang on 16-08-21.
//  Copyright (c) 2014年 roryhuang. All rights reserved.
//


#import "DLog.h"


#define NSLog(FORMAT, ...) [[DLog shareInstance] DDLog:[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] function:__FUNCTION__ file:__FUNCTION__ line:__LINE__];
