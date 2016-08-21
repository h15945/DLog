//
//  DLog.m
//  DLog
//
//  Created by roryhuang on 16-08-21.
//  Copyright (c) 2014年 roryhuang. All rights reserved.
//

#import "DLog.h"
#define CMD_PushLog @10
#define CMD_HeartPack @11
#define CMD_Response @101
@interface DLog ()
@property(strong,nonatomic)SRWebSocket *webSocket;
@property(assign,nonatomic)NSInteger logPushSwitch;//0 log不事实上报 1log实时上报

@property(copy,nonatomic) NSString* websocketAddress;
@property(copy,nonatomic) NSString* mac;

@end

@implementation DLog



static DLog* _instance = nil;

+(instancetype) shareInstance
{
  static dispatch_once_t onceToken ;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init] ;
  }) ;
  return _instance ;
}

-(id)init{
  self = [super init];
  _logPushSwitch=0;
  _logLevel = 1;
  return self;
}

-(void)initWebsocket{
  _webSocket.delegate = nil;
  [_webSocket close];
  _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_websocketAddress]]];
  _webSocket.delegate = self;
  [_webSocket open];

}
-(void)backselector{
  
  [self initWebsocket];
  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
  NSRunLoop *runloop = [NSRunLoop currentRunLoop];
  [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
  [runloop run];
}
-(void)initWithWSRequest:(NSString*)ws andMac:(NSString*)mac{
  self.websocketAddress = ws;
  self.mac = mac;
  [self performSelectorInBackground:@selector(backselector) withObject:nil];
}






-(void)timerFired{
  if (_webSocket==nil) {
    [self initWebsocket];
  }else if(_webSocket.readyState == SR_CLOSED){
    [self initWebsocket];
  }
  
  NSLog(@"state is %ld",_webSocket.readyState);
}




/*
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"asgsadgsdfgdshdfrhershjdrzghderhs!   %@",message);
}
*/

-(void)DDLog:(NSString*)content function:(const char*)fun file:(const char*)file line:(int)line{
  //fprintf(stderr,"\nfunction:%s\n", f);
  NSString * string;
  NSString *filestr = [NSString stringWithUTF8String:file];
  NSString *funstr = [NSString stringWithUTF8String:fun];
  NSString *linestr = [NSString stringWithFormat:@"%d",line];
  switch (_logLevel) {
    case 0:
      string = @"";
      break;
    case 1:
      string = content;
      break;
    case 2:
      string = [NSString stringWithFormat:@"File:%@ Function:%@ Line:%@ Content:%@",filestr,funstr,linestr,content];
      break;
    default:
      break;
  }
  NSLog(@"%@",string);
  if (_logPushSwitch==1) {
    [self sendMessageWithCmd:CMD_PushLog andContent:string andMessageid:nil];
    
  }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    [self sendMessageWithCmd:CMD_HeartPack andContent:@"" andMessageid:nil];
    //self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
  
  NSLog(@"Received \"%@\"", message);
  NSDictionary *weatherDic;
  @try {
    NSError *error;
    weatherDic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
      NSLog(@"解析错误");
      return;
    }
  }
  @catch (NSException *exception) {
    
  }
  @finally {
    
  }
  
  if (!weatherDic) {
    return;
  }
  if ([weatherDic[@"messagecmd"] integerValue]==101) {//下发了命令
    NSString *str = [NSString stringWithFormat:@"App info:frameWidth%f,frameHeight:%f",[UIApplication sharedApplication].keyWindow.frame.size.width,[UIApplication sharedApplication].keyWindow.frame.size.height];
    [self sendMessageWithCmd:CMD_Response andContent:str andMessageid:weatherDic[@"messageid"]];
    return;
  }
  if ([weatherDic[@"messagecmd"] integerValue]==102) {//设置log上传开关
    _logPushSwitch = [weatherDic[@"message"] integerValue];
    return;
  }
  if ([weatherDic[@"messagecmd"] integerValue]==103) {//设置log等级
    _logLevel = [weatherDic[@"message"] integerValue];
    return;
  }
  if ([weatherDic[@"messagecmd"] integerValue]==104) {//通知匹配成功
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"searchfinishnc" object:self userInfo:weatherDic[@"message"]];
    return;
  }
  if ([weatherDic[@"messagecmd"] integerValue]==105) {//在广场页的通知匹配成功
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"comparesuccessnc" object:self userInfo:weatherDic[@"message"]];
    return;
  }
  
  
}







- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    //self.title = @"Connection Closed! (see logs)";
    webSocket = nil;
}
-(void)sendMessageWithCmd:(NSNumber*)cmd andContent:(NSString*)content andMessageid:(NSNumber*)messageid{
  if (messageid==nil) {
    messageid = @0;
  }
  
  NSDictionary*postdic = @{@"messageid":messageid,
                           @"messagetype":@"iphone",
                           @"message":content,
                           @"messagecmd":cmd,
                           @"mac":_mac};
  
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postdic options:NSJSONWritingPrettyPrinted error:&error];
  if (_webSocket.readyState && (!error)) {
    [_webSocket send:jsonData];
  }
  
  /*
  if (!error) {
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }else{
    return nil;
  }
  */
  
  
}


@end

