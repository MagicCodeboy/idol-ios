
//
//  AppDelegate.m
//  jinshanStrmear
//
//  Created by mac on 16/5/15.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "AppDelegate.h"
#import "JXTAlertTools.h"
#import "AdvertiseView.h"//启动页广告的页面
#import "Login_RegisController.h"//登录注册页面
#import "LiveViewController.h"//直播
#import "CZNavigationController.h"

#import "NIMSessionListViewController.h"//消息列表

#import "NewShopViewController.h"

//#import "StarController.h"//直播的xib的界面
#import "UIImage+Blur.h"
#import "YYCache+Cache.h"
#import <AudioToolbox/AudioToolbox.h>

#import "PXYAnchorController.h"
#import "PXYViewersViewController.h"
#import "AccountModel.h"
#import "CustomizeDecoder.h"
#import "CZFlashDowloadManager.h"

#import "YYCache+Cache.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "UIImage+Extend.h"
#import "AccountModel.h"
#import "MajorModel.h"
#import "NSString+Cache.h"

#import "PXYRequestAllViewers.h"
#import <UserNotifications/UserNotifications.h>
#import "CacheTool.h"
#import "NIMKit.h"
#import "NTESSessionViewController.h"
#import "NTESSessionListViewController.h"
#import <AdSupport/AdSupport.h>
#import "RegistrationView.h"
#import "UIButton+Block.h"
#import "LSHSplishView.h"
#import <NIMSDK/NIMSDK.h>
#import "StarHomePageViewController.h"
#import "FollowViewController.h"
#import "NewModel.h"
#import "NTESCellLayoutConfig.h"
#import "UIViewController+Swizzled.h"
@interface AppDelegate ()<NIMLoginManagerDelegate,NIMChatManagerDelegate,UINavigationControllerDelegate>
{
    NSDate* late;//存放进入后台的时间
}
@property (nonatomic, strong) CTCallCenter *center;

@property(nonatomic,strong)NSMutableArray *picUrlArray;//保存启动图的数组
//
//@property(nonatomic,strong)AdvertiseView *advertiseView;//系统启动图加载之前展示的页面

@property(nonatomic,copy)StartUpPic *model;
@property(nonatomic,assign) BOOL isDelete;//是否删除启动图
@property(nonatomic,strong) LSHSplishView *lshView;

@end

@implementation AppDelegate



#pragma mark - 系统判断应用加载完成的方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //状态栏变白色
    

    [CLNetworkingManager checkNetworkLinkStatus];
    
    [NIMSDKConfig sharedConfig].shouldConsiderRevokedMessageUnreadCount=YES;
    [NIMSDKConfig sharedConfig].enabledHttpsForInfo=NO;
    [NIMSDKConfig sharedConfig].enabledHttpsForMessage=NO;
    
    //   /正式/    yunxinPush   测试yunxinPushTest
    [[NIMSDK sharedSDK] registerWithAppID:RONGYUNAPPKEY
                                  cerName:[NSString stringWithFormat:@"yunxinPush%@",[NSString getAppLogo]]];
    [[YYCache shareCache]removeObjectForKey:@"AdafterShow"];


    [NIMCustomObject registerCustomDecoder:[[CustomizeDecoder alloc]init]];
    //注册 NIMKit 自定义排版配置
    [[NIMKit sharedKit] registerLayoutConfig:[NTESCellLayoutConfig new]];
 
    SWIZZ_IT_WITH_TAG(@"当前界面");
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    //状态栏变白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [[UINavigationBar appearance] setTranslucent:YES];

    if ([[YYCache shareCache]objectForKey:@"loginOrMain"]==nil) {
        [self goLogin];
    } else {
        NSString *userID=StringWithFormat([AccountModel read].userId);

        if (!ISNULL(userID)) {
            [self gomain];
        }
        else{
            [self goLogin];
        }
    }
    
    self.currentController = self.window.rootViewController;
    
    return YES;
}
-(void)showGuidView{
    if ([[YYCache shareCache]objectForKey:@"guide"] == nil) {
        NSArray *imageArray = nil;
        if (SCREEN_WIDTH < 375) {
            imageArray = @[@"剧场引导640-1136（1）.png",@"剧场引导640-1136（2）.png",@"剧场引导640-1136（3）.png",@"剧场引导640-1136（4）.png"];
        } else if (SCREEN_WIDTH == 375) {
            imageArray = @[@"剧场引导750-1334(1).png",@"剧场引导750-1334（2）.png",@"剧场引导750-1334（3）.png",@"剧场引导750-1334（4）.png"];
        } else {
            imageArray = @[@"剧场引导1242-2208（1）.png",@"剧场引导1242-2208（2）.png",@"剧场引导1242-2208（3）.png",@"剧场引导1242-2208（4）.png"];
        }
        _lshView = [[LSHSplishView alloc]initWithArray:imageArray andFrame:[UIScreen mainScreen].bounds gobackBlock:^{
            [[YYCache shareCache]setObject:@"notFirst" forKey:@"guide"];
            [_lshView removeFromSuperview];
        }];
        [KeyWindow addSubview:_lshView];
    }
}


/**
 *  登录回调
 *
 *  @param step 登录步骤
 *  @discussion 这个回调主要用于客户端UI的刷新
 */
- (void)onLogin:(NIMLoginStep)step
{
    if (step==NIMLoginStepLoginOK) {
        NSLog(@"云信登录成功");
        [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
        
    }
    
    if (step==NIMLoginStepLoseConnection) {
        NSLog(@"网络断开了");
        
    }
    
    if (10==step) {
        NSLog(@"网络切换了");
    }
    
    
}
- (void)onAutoLoginFailed:(NSError *)error
{
    NSLog(@"登录失败：%@",error);
}

- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages
{
    NIMMessage *message = messages.firstObject;
    
    NSLog(@"收到消息了%@",message);
    NIMCustomObject *object = (NIMCustomObject *)message.messageObject;
    if (message.messageType==100) {
        Customize *customize = (Customize *)object.attachment;
        NSLog(@"商品名字：%@",customize.name);
    }
    
    if (message.session.sessionType==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recvMessagesNotificationCenter" object:self userInfo:@{@"message":message.text}];
        
        
    }
}


+ (AppDelegate *)shareInstance
{
    
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
}

-(void)goFollowView{
    [self.window.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.window.rootViewController = nil;
    [self.window removeFromSuperview];
    [self.window makeKeyAndVisible];
    
    [[StarListModel shareModel].followList removeAllObjects];
    ALLOC(FollowViewController, view);
    view.fromRootController=YES;
    CZNavigationController *followNa = [[CZNavigationController alloc]initWithRootViewController:view];
    AppDelegate *de=[AppDelegate shareInstance];
    de.window.rootViewController= followNa;
    [self.window makeKeyAndVisible];
}
-(void)gomain

{
    
    [AppDelegate shareInstance].showLiveBar=YES;

    //登录云信
    NIMAutoLoginData *data=[[NIMAutoLoginData alloc]init];
    
    data.account=[AccountModel read].userId;
    data.token=[AccountModel read].roomToken;
    data.forcedMode=YES;
    
    [[[NIMSDK sharedSDK] loginManager]  addDelegate:self];
    
    [[[NIMSDK sharedSDK] loginManager] autoLogin:data];
    

    //移除uiwindow
    [self.window.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.window.rootViewController = nil;
    [self.window removeFromSuperview];
    [self.window makeKeyAndVisible];


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    });
    if ([NIMSDK sharedSDK].loginManager.isLogined==YES) {
        
        if ([NIMSDK sharedSDK].conversationManager.allUnreadCount > 0) {
            NSLog(@"读取未读消息个数0号位置%ld",(long)[NIMSDK sharedSDK].conversationManager.allUnreadCount);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recvMessagesNotificationCenter" object:self userInfo:nil];
        }
    }
    

    
    if ([AccountModel read ].followerNum <=0) {
        ALLOC(FollowViewController, view);
        view.fromRootController=YES;
        CZNavigationController *followNa = [[CZNavigationController alloc]initWithRootViewController:view];
        self.window.rootViewController= followNa;
    }else{
        ALLOC(StarHomePageViewController, home);
        CZNavigationController *fetterNa = [[CZNavigationController alloc]initWithRootViewController:home];
        self.window.rootViewController= fetterNa;

    }
        
    
    [self.window makeKeyAndVisible];
    
  
    
}


-(void)goLogin
{
    
    

    Login_RegisController *login_regisVc=[[Login_RegisController alloc]init];
    CZNavigationController *navLogin=[[CZNavigationController alloc]initWithRootViewController:login_regisVc];
    
    self.window.rootViewController=navLogin;
    
}






-(void)currentViewCOntroller:(UIViewController *)controller
{
    
    
    self.currentController=controller;
}






-(void)joinLiveView:(NSString *)type andliveId:(NSString *)liveID andController:(UIViewController *)currentViewController
{
    PXYRequestAllViewers * PXYrequest = [[PXYRequestAllViewers alloc]init];
    [PXYrequest PlayLive:type Id:liveID theaterInfo:nil controller:currentViewController];
}
//退出登录
-(void)exitLogin:(NSString *)content idStr:(NSString *)strId andViewController:(UIViewController *)viewCOntroller
{
    [JXTAlertTools showAlertWith:viewCOntroller title:@"通知" message:content callbackBlock:^(NSInteger btnIndex) {
        
        [[[NIMSDK sharedSDK] loginManager]logout:^(NSError * _Nullable error) {
            NSLog(@"云信退出登录了");
        }];
        [CacheTool clearAllCachewithSuccessBlock:^{
            
        }];
        
        Class class = NSClassFromString(@"Login_RegisController");
        UIViewController *controler=class.new;
        CZNavigationController  *nav=[[CZNavigationController alloc]initWithRootViewController:controler];
        
        [viewCOntroller presentViewController:nav animated:YES completion:nil];
        
    } cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
}


- (void)applicationWillResignActive:(UIApplication *)application {

}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    

}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
   
    
}
- (void)applicationWillTerminate:(UIApplication *)application {

}


@end
