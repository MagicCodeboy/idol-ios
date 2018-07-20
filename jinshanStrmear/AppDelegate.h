//
//  AppDelegate.h
//  jinshanStrmear
//
//  Created by mac on 16/5/15.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *currentController;


@property (strong, nonatomic) NSDictionary *messageDic;
//是否显示直播的目录
@property (assign, nonatomic) BOOL showLiveBar;

@property(nonatomic,strong)XMTabBarController *tabBar;
+ (AppDelegate *)shareInstance;

-(void)goFollowView;

-(void)gomain;

-(void)goLogin;

//获取当前的controller
-(void)currentViewCOntroller:(UIViewController *)controller;

-(void)requestAppPlayOrStreamDicWith:(NSString *)wsUrl;

@end

