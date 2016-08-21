//
//  DLog.h
//  DLog
//
//  Created by roryhuang on 16-08-21.
//  Copyright (c) 2014年 roryhuang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SRWebSocket.h"


@interface DLog : NSObject<SRWebSocketDelegate>
@property(assign,nonatomic)NSInteger logLevel;//0 不打印log 1打印正常log 2打印lig的文件、方法、行数

+(instancetype) shareInstance;
-(void)DDLog:(NSString*)content function:(const char*)fun file:(const char*)file line:(int)line;
-(void)initWithWSRequest:(NSString*)ws andMac:(NSString*)mac;
-(void)setLogLevel:(NSInteger)level;
@end

