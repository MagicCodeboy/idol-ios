//
//  NTESSessionViewController.m
//  NIM
//
//  Created by amao on 8/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESSessionViewController.h"
@import MobileCoreServices;
@import AVFoundation;
#import "Reachability.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESSessionConfig.h"
#import "NIMMediaItem.h"
#import "NTESSessionMsgConverter.h"
#import "NTESSessionMsgConverter.h"
#import "UIView+Toast.h"
#import "NSDictionary+NTESJson.h"
#import "NIMAdvancedTeamCardViewController.h"
#import "NIMNormalTeamCardViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"

#import "UIAlertView+NTESBlock.h"
#import "NIMKit.h"
#import "NTESSessionUtil.h"
#import "NIMKitMediaFetcher.h"
#import "NIMKitLocationPoint.h"
#import "NIMLocationViewController.h"
#import "NIMInputAtCache.h"
#import "NTESCellLayoutConfig.h"
#import "NTESTimerHolder.h"
#import "MWPhotoBrowser.h"
#import "NewModel.h"
#import "IQKeyboardManager.h"
#import "UIViewController+Cloudox.h"
#import "UIColor+Category.h"
#import "UIViewController+JZExtension.h"
#import "GroupInfoViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "NIMGlobalMacro.h"
NSString *const NIMDemoEventNameOpenSnapPicture  = @"NIMDemoEventNameOpenSnapPicture";
NSString *const NIMDemoEventNameCloseSnapPicture = @"NIMDemoEventNameCloseSnapPicture";

@interface NTESSessionViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
NIMSystemNotificationManagerDelegate,
NIMMediaManagerDelegate,
NTESTimerHolderDelegate,
NIMTeamManagerDelegate,
MWPhotoBrowserDelegate>

@property (nonatomic,strong)    NTESSessionConfig       *sessionConfig;
@property (nonatomic,strong)    UIImagePickerController *imagePicker;
@property (nonatomic,strong)    NTESTimerHolder         *titleTimer;
@property (nonatomic,strong)    UIView *currentSingleSnapView;
@property(nonatomic,strong)NSMutableArray *photosArray;

@property (nonatomic,strong)    NIMKitMediaFetcher *mediaFetcher;
@end



@implementation NTESSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _photosArray=@[].mutableCopy;

    self.navigationController.navigationBar.translucent=NO;
    self.fd_interactivePopDisabled = YES;
//    self.jz_navigationBarBackgroundAlpha=0;
    self.jz_navigationBarTintColor=UIColorFromRGB(0x3E206A);
    [self setUpNav];
    BOOL disableCommandTyping = self.disableCommandTyping || (self.session.sessionType == NIMSessionTypeP2P &&[[NIMSDK sharedSDK].userManager isUserInBlackList:self.session.sessionId]);
    if (!disableCommandTyping) {
        _titleTimer = [[NTESTimerHolder alloc] init];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    }
    self.tableView.backgroundColor=[UIColor clearColor];
    
    [self.view.layer insertSublayer:[UIColor setGradualChangingColor:self.view fromColor:nil toColor:nil] atIndex:0];

   
    
    if (self.session.sessionType == NIMSessionTypeP2P && !self.disableOnlineState)
    {
        //临时订阅这个人的在线状态
//        [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
    }
    
    //删除最近会话列表中有人@你的标记
    [NTESSessionUtil removeRecentSessionAtMark:self.session];
    
}
// 递归获取子视图
- (void)getSub:(UIView *)view andLevel:(int)level {
    NSArray *subviews = [view subviews];
    
    // 如果没有子视图就直接返回
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        
        // 根据层级决定前面空格个数，来缩进显示
        NSString *blank = @"";
        for (int i = 1; i < level; i++) {
            blank = [NSString stringWithFormat:@"  %@", blank];
        }
        subview.backgroundColor=[UIColor clearColor];
        
        
        // 打印子视图类名
        NSLog(@"%@%d: %@", blank, level, subview.class);
        
        // 递归获取此视图的子视图
        [self getSub:subview andLevel:(level+1)];
        
    }
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    if (self.session.sessionType == NIMSessionTypeP2P && !self.disableOnlineState)
    {
//        [[NIMSDK sharedSDK].subscribeManager removeDelegate:self];
    }
}



- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
 
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyboardManager =  [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = NO;
    self.navigationController.navigationBar.translucent=NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

//    self.navBarBgAlpha = @"0";
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NIMSDK sharedSDK].mediaManager stopRecord];
    [[NIMSDK sharedSDK].mediaManager stopPlay];
    self.navigationController.navigationBar.translucent=YES;

    IQKeyboardManager *keyboardManager =  [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = YES;

}

- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[NTESSessionConfig alloc] init];
        _sessionConfig.session = self.session;
    }
    return _sessionConfig;
}

#pragma mark - NIMEventSubscribeManagerDelegate
- (void)onRecvSubscribeEvents:(NSArray *)events
{
    for (NIMSubscribeEvent *event in events) {
        if ([event.from isEqualToString:self.session.sessionId]) {
            [self refreshSessionSubTitle:[NTESSessionUtil onlineState:self.session.sessionId detail:YES]];
        }
    }
}
#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    if (!notification.sendToOnlineUsersOnly) {
        return;
    }
    NSData *data = [[notification content] dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict jsonInteger:@"id"] == (1) && self.session.sessionType == NIMSessionTypeP2P && [notification.sender isEqualToString:self.session.sessionId])
        {
            [self refreshSessionTitle:@"正在输入..."];
            [_titleTimer startTimer:5
                           delegate:self
                            repeats:NO];
        }
    }
    
    
}

- (void)onNTESTimerFired:(NTESTimerHolder *)holder
{
    [self refreshSessionTitle:self.sessionTitle];
}


- (NSString *)sessionTitle
{
    if ([self.session.sessionId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        return  @"我的电脑";
    }
    return [super sessionTitle];
}

- (NSString *)sessionSubTitle
{
    if (self.session.sessionType == NIMSessionTypeP2P && ![self.session.sessionId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        return [NTESSessionUtil onlineState:self.session.sessionId detail:YES];
    }
    return @"";
}

- (void)onTextChanged:(id)sender
{
}

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId
{
  
}


#pragma mark - 石头剪子布
- (void)onTapMediaItemJanKenPon:(NIMMediaItem *)item
{
  
}

#pragma mark - 实时语音
- (void)onTapMediaItemAudioChat:(NIMMediaItem *)item
{
   
}

#pragma mark - 视频聊天
- (void)onTapMediaItemVideoChat:(NIMMediaItem *)item
{
   
}

#pragma mark - 群组会议
- (void)onTapMediaItemTeamMeeting:(NIMMediaItem *)item
{
   
}


#pragma mark - 文件传输
- (void)onTapMediaItemFileTrans:(NIMMediaItem *)item
{
    
}

#pragma mark - 阅后即焚
- (void)onTapMediaItemSnapChat:(NIMMediaItem *)item
{
   
}

- (void)sendSnapchatMessagePath:(NSString *)path
{
  
}

- (void)sendSnapchatMessage:(UIImage *)image
{
   
}

#pragma mark - 白板
- (void)onTapMediaItemWhiteBoard:(NIMMediaItem *)item
{
   
}



#pragma mark - 提示消息
- (void)onTapMediaItemTip:(NIMMediaItem *)item
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"输入提醒" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 1:{
                UITextField *textField = [alert textFieldAtIndex:0];
                NIMMessage *message = [NTESSessionMsgConverter msgWithTip:textField.text];
                [self sendMessage:message];

            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - 红包
- (void)onTapMediaItemRedPacket:(NIMMediaItem *)item
{
}

#pragma mark - 群已读回执
- (void)onTapMediaItemTeamReceipt:(NIMMediaItem *)item
{
   
}


#pragma mark - 消息发送时间截获
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if (error.code == NIMRemoteErrorCodeInBlackList)
    {
        //消息打上拉黑拒收标记，方便 UI 显示
        message.localExt = @{NTESMessageRefusedTag:@(true)};
        [[NIMSDK sharedSDK].conversationManager updateMessage:message forSession:self.session completion:nil];
        
        //插入一条 Tip 提示
        NIMMessage *tip = [NTESSessionMsgConverter msgWithTip:@"消息已发送，但对方拒收"];
        [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:self.session completion:nil];
    }
    [super sendMessage:message didCompleteWithError:error];
}

#pragma mark - 录音事件
- (void)onRecordFailed:(NSError *)error
{
    [self.view makeToast:@"录音失败" duration:2 position:CSToastPositionCenter];
}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    NSURL    *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength > 2;
}

- (void)showRecordFileNotSendReason
{
    [self.view makeToast:@"录音时间太短" duration:0.2f position:CSToastPositionCenter];
}

#pragma mark - Cell事件
- (BOOL)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = [super onTapCell:event];
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink])
    {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMDemoEventNameOpenSnapPicture])
    {
        NIMCustomObject *object = event.messageModel.message.messageObject;
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
       
        UIView *sender = event.data;
//        self.currentSingleSnapView = [NTESGalleryViewController alertSingleSnapViewWithMessage:object.message baseView:sender];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMDemoEventNameCloseSnapPicture])
    {
        //点击很快的时候可能会触发两次查看，所以这里不管有没有查看过 先强直销毁掉
        NIMCustomObject *object = event.messageModel.message.messageObject;
        UIView *senderView = event.data;
        [senderView dismissPresentedView:YES complete:nil];
        
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
       
        NIMMessage *message = object.message;
        if ([NTESBundleSetting sharedConfig].autoRemoveSnapMessage) {
            [[NIMSDK sharedSDK].conversationManager deleteMessage:message];
            [self uiDeleteMessage:message];
        }else{
            [[NIMSDK sharedSDK].conversationManager updateMessage:message forSession:message.session completion:nil];
            [self uiUpdateMessage:message];
        }
//        [[NSFileManager defaultManager] removeItemAtPath:attachment.filepath error:nil];
        self.currentSingleSnapView = nil;
        handled = YES;
    }
    else if([eventName isEqualToString:NIMKitEventNameTapRobotLink])
    {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    }
   
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
    return handled;
}

- (BOOL)onTapAvatar:(NIMMessage *)message{
    NSString *userId = [self messageSendSource:message];
    UIViewController *vc = nil;
    if ([[NIMSDK sharedSDK].robotManager isValidRobot:userId])
    {
//        vc = [[NTESRobotCardViewController alloc] initWithUserId:userId];
    }
    else
    {
//        vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    return YES;
}


- (BOOL)onLongPressAvatar:(NIMMessage *)message
{
    NSString *userId = [self messageSendSource:message];
    if (self.session.sessionType == NIMSessionTypeTeam && ![userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount])
    {
        [self.view makeToast:@"onLongPressAvatar"];
    }
    return YES;
    
}

- (BOOL)onPressReadLabel:(NIMMessage *)message
{
    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        [self.view makeToast:@"onPressReadLabel"];

    }
    return YES;
}


- (NSString *)messageSendSource:(NIMMessage *)message
{
    NSString *from = nil;
    if (message.messageType == NIMMessageTypeRobot)
    {
        NIMRobotObject *object = (NIMRobotObject *)message.messageObject;
        if (object.isFromRobot)
        {
            from = object.robotId;
        }
    }
    if (!from)
    {
        from = message.from;
    }
    return from;
}


#pragma mark - Cell Actions
- (void)showImage:(NIMMessage *)message
{
   
    [_photosArray removeAllObjects];
    
    
    MWPhoto *photo;
    
    NIMImageObject *object = message.messageObject;
    PhotoItem *item=[[PhotoItem alloc]init];
    item.url=[object url];
    item.name=[object displayName];
    item.thumbPath=[object thumbPath];
    
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[object url]]];
    photo.caption=[object displayName];
    
    [_photosArray insertObject:photo atIndex:0];

    [self pushPhotoOrVideoController];

  
}
-(void)pushPhotoOrVideoController
{
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:^{
        
        
    }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photosArray.count)
        return [_photosArray objectAtIndex:index];
    return nil;
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)showVideo:(NIMMessage *)message
{
    [_photosArray removeAllObjects];
    
    
    MWPhoto *photo;
    
    NIMVideoObject *object = message.messageObject;
    
    photo = [MWPhoto photoWithURL: [NSURL fileURLWithPath:[object coverPath]]];
    photo.caption=[object displayName];
    photo.videoURL = [NSURL URLWithString:[object url]];
    
    [_photosArray insertObject:photo atIndex:0];
    
    [self pushPhotoOrVideoController];

  
}

- (void)showLocation:(NIMMessage *)message
{
    
}

- (void)showFile:(NIMMessage *)message
{
   
}

- (void)showCustom:(NIMMessage *)message
{
   //普通的自定义消息点击事件可以在这里做哦~
}

- (void)openSafari:(NSString *)link
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:link];
    if (components)
    {
        if (!components.scheme)
        {
            //默认添加 http
            components.scheme = @"http";
        }
        [[UIApplication sharedApplication] openURL:[components URL]];
    }
}


#pragma mark - 导航按钮
- (void)enterPersonInfoCard:(id)sender{
   
}

- (void)enterRobotInfoCard:(id)sender{
  
}

- (void)enterHistory:(id)sender{
    
}

- (void)enterTeamCard:(id)sender{
   
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    if (defaultItems) {
        [items addObjectsFromArray:defaultItems];
    }
    
   
//    if ([NTESSessionUtil canMessageBeRevoked:message]) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeMessage:)]];
//    }
    
    if (message.messageType == NIMMessageTypeAudio) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转文字" action:@selector(audio2Text:)]];
    }
    
    return items;
    
}

- (void)audio2Text:(id)sender
{
    
}




- (void)revokeMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatManager revokeMessage:message completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送时间超过2分钟的消息，不能被撤回" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                [weakSelf.view makeToast:@"消息撤回失败，请重试" duration:2.0 position:CSToastPositionCenter];
            }
        }
        else
        {
            NIMMessageModel *model = [self uiDeleteMessage:message];
            NIMMessage *tip = [NTESSessionMsgConverter msgWithTip:[NTESSessionUtil tipOnMessageRevoked:nil]];
            tip.timestamp = model.messageTime;
            [self uiInsertMessages:@[tip]];
            
            tip.timestamp = message.timestamp;
            // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
            [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:message.session completion:nil];
        }
    }];
}

 - (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
}

#pragma mark - 辅助方法
- (void)sendImageMessagePath:(NSString *)path
{

    [self sendSnapchatMessagePath:path];
}


- (BOOL)checkRTSCondition
{
    BOOL result = YES;
    
    if (![[Reachability reachabilityForInternetConnection] isReachable])
    {
        [self.view makeToast:@"请检查网络" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    if (self.session.sessionType == NIMSessionTypeP2P && [currentAccount isEqualToString:self.session.sessionId])
    {
        [self.view makeToast:@"不能和自己通话哦" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.session.sessionId];
        NSInteger memberNumber = team.memberNumber;
        if (memberNumber < 2)
        {
            [self.view makeToast:@"无法发起，群人数少于2人" duration:2.0 position:CSToastPositionCenter];
            result = NO;
        }
    }
    return result;
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeLocation) : @"showLocation:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

- (NIMKitMediaFetcher *)mediaFetcher
{
    if (!_mediaFetcher) {
        _mediaFetcher = [[NIMKitMediaFetcher alloc] init];
        _mediaFetcher.limit = 1;
        _mediaFetcher.mediaTypes = @[(NSString *)kUTTypeImage];;;
    }
    return _mediaFetcher;
}

- (void)setUpNav{
    UIButton *enterTeamCard = [UIButton buttonWithType:UIButtonTypeCustom];
    [enterTeamCard addTarget:self action:@selector(enterTeamCard:) forControlEvents:UIControlEventTouchUpInside];
    [enterTeamCard setImage:[UIImage imageNamed:@"xiaoxi_chak_"] forState:UIControlStateNormal];
    [enterTeamCard setImage:[UIImage imageNamed:@"xiaoxi_chak_"] forState:UIControlStateHighlighted];
    [enterTeamCard sizeToFit];
    UIBarButtonItem *enterTeamCardItem = [[UIBarButtonItem alloc] initWithCustomView:enterTeamCard];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoBtn addTarget:self action:@selector(enterPersonInfoCard:) forControlEvents:UIControlEventTouchUpInside];
    [infoBtn setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
    [infoBtn setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
    [infoBtn sizeToFit];
    UIBarButtonItem *enterUInfoItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    
    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [historyBtn addTarget:self action:@selector(enterHistory:) forControlEvents:UIControlEventTouchUpInside];
    [historyBtn setImage:[UIImage imageNamed:@"icon_history_normal"] forState:UIControlStateNormal];
    [historyBtn setImage:[UIImage imageNamed:@"icon_history_pressed"] forState:UIControlStateHighlighted];
    [historyBtn sizeToFit];
    UIBarButtonItem *historyButtonItem = [[UIBarButtonItem alloc] initWithCustomView:historyBtn];
    
    
    UIButton *robotInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [robotInfoBtn addTarget:self action:@selector(enterRobotInfoCard:) forControlEvents:UIControlEventTouchUpInside];
    [robotInfoBtn setImage:[UIImage imageNamed:@"icon_robot_card_normal"] forState:UIControlStateNormal];
    [robotInfoBtn setImage:[UIImage imageNamed:@"icon_robot_card_pressed"] forState:UIControlStateHighlighted];
    [robotInfoBtn sizeToFit];
    UIBarButtonItem *robotInfoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:robotInfoBtn];

    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        self.navigationItem.rightBarButtonItems  = @[enterTeamCardItem,historyButtonItem];
    }
    else if(self.session.sessionType == NIMSessionTypeP2P)
    {
        if ([self.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]])
        {
            self.navigationItem.rightBarButtonItems = @[historyButtonItem];
        }
        else if([[NIMSDK sharedSDK].robotManager isValidRobot:self.session.sessionId])
        {
            self.navigationItem.rightBarButtonItems = @[historyButtonItem,robotInfoButtonItem];
        }
        else
        {
            self.navigationItem.rightBarButtonItems = @[enterUInfoItem,historyButtonItem];
        }
    }
}

- (BOOL)shouldAutorotate{
    return !self.currentSingleSnapView;
}

@end
