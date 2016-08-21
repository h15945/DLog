//
//  DLViewController.m
//  DLog
//
//  Created by h15945 on 08/21/2016.
//  Copyright (c) 2016 h15945. All rights reserved.
//

#import "DLViewController.h"
#import "Log+DLog.h"


@interface DLViewController ()

@end

@implementation DLViewController

-(IBAction)tap:(id)sender{
  NSLog(@"wotapsldasd%d",1234);
}


-(void)checkmain{
  if ([NSThread isMainThread]) {
    NSLog(@"在主线程中");
  }else{
    NSLog(@"不在主线程中");
  }
}

-(void)searchFinish:(NSNotification*)notify
{
  // 取得广播内容
  NSDictionary *userinfo = [notify userInfo];
  [self checkmain];
}
- (void)viewDidLoad
{
  
  [super viewDidLoad];
  NSNotificationCenter *nc2 = [NSNotificationCenter defaultCenter];
  [nc2 addObserver:self selector:@selector(searchFinish:) name:@"searchfinishnc" object:nil];
  
  [self checkmain];
  
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
