//
//  NTESChatroomViewController.m
//  NIM
//
//  Created by chris on 15/12/11.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESChatroomViewController.h"
#import "NTESChatroomConfig.h"
#import "NTESSessionMsgConverter.h"
#import "NTESChatroomManager.h"
#import "NIMKitEvent.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIViewController+JZExtension.h"
#import "UIColor+Category.h"
#import "GroupInfoViewController.h"
#import "IQKeyboardManager.h"
#import "MWPhotoBrowser.h"
#import "NewModel.h"
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface NTESChatroomViewController ()
{
    BOOL _isRefreshing;
}

@property (nonatomic,strong) NTESChatroomConfig *config;

@property (nonatomic,strong) NIMChatroom *chatroom;
@property(nonatomic,strong)NSMutableArray *photosArray;

@end

@implementation NTESChatroomViewController

- (instancetype)initWithChatroom:(NIMChatroom *)chatroom
{
    self = [super initWithSession:[NIMSession session:chatroom.roomId type:NIMSessionTypeChatroom]];
    if (self) {
        _chatroom = chatroom;
    }
    return self;
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (NSString *)sessionTitle
{
//    return [super sessionTitle];

    return _chatroom.name;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _photosArray=@[].mutableCopy;

    self.navigationController.navigationBar.translucent=NO;
    self.fd_interactivePopDisabled = YES;
    self.jz_navigationBarTintColor=UIColorFromRGB(0x3E206A);
    self.tableView.backgroundColor=[UIColor clearColor];
    [self.view.layer insertSublayer:[UIColor setGradualChangingColor:self.view fromColor:nil toColor:nil] atIndex:0];

    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [historyBtn addTarget:self action:@selector(enterHistory:) forControlEvents:UIControlEventTouchUpInside];
    [historyBtn setImage:[UIImage imageNamed:@"xiaoxi_chak_"] forState:UIControlStateNormal];
    UIBarButtonItem *historyButtonItem = [[UIBarButtonItem alloc] initWithCustomView:historyBtn];

    self.navigationItem.rightBarButtonItems = @[historyButtonItem];

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
- (void)enterHistory:(id)sender{

    GroupInfoViewController *vc=[[GroupInfoViewController alloc]initWithChatroom:self.chatroom];

    [self.navigationController pushViewController:vc animated:YES];
}

- (id<NIMSessionConfig>)sessionConfig{
    return self.config;
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                   };
    });
    return actions;
}

- (BOOL)onTapCell:(NIMKitEvent *)event
{
   
    NSLog(@"点击");
    BOOL handled = [super onTapCell:event];
    NSString *eventName = event.eventName;
    if([eventName isEqualToString:NIMKitEventNameTapLabelLink] || [eventName isEqualToString:NIMKitEventNameTapRobotLink])
    {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    }else  if ([eventName isEqualToString:NIMKitEventNameTapContent])
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
    
    if (!handled)
    {
        NSAssert(0, @"invalid event");
    }
    return handled;
}


- (BOOL)onTapMediaItem:(NIMMediaItem *)item
{
    SEL  sel = item.selctor;
    BOOL response = [self respondsToSelector:sel];
    if (response) {
        SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:item]);
    }
    return response;
}

- (void)onTapMediaItemJanKenPon:(NIMMediaItem *)item{
  
}


- (void)sendMessage:(NIMMessage *)message
{
    NIMChatroomMember *member = [[NTESChatroomManager sharedInstance] myInfo:self.chatroom.roomId];
    message.remoteExt = @{@"type":@(member.type)};
    
    //这几行代码去掉进入退出直播间提示
    if(message.messageType==NIMMessageTypeNotification) {
        NIMNotificationObject *object = message.messageObject;
        NIMChatroomNotificationContent *content = (NIMChatroomNotificationContent *)object.content;
        
        if (content.eventType==NIMChatroomEventTypeEnter||content.eventType==NIMChatroomEventTypeExit) {
            return;
        }
    }

    [super sendMessage:message];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offset = 44.f;
        if (self.tableView.contentOffset.y <= -offset && !_isRefreshing && self.tableView.isDragging) {
            _isRefreshing = YES;
            UIRefreshControl *refreshControl = [self findRefreshControl];
            [refreshControl beginRefreshing];
            [refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
            [self.tableView endEditing:YES];
        }
        else if(self.tableView.contentOffset.y >= 0)
        {
            _isRefreshing = NO;
        }
    }
}

- (UIRefreshControl *)findRefreshControl
{
    for (UIRefreshControl *subView in self.tableView.subviews) {
        if ([subView isKindOfClass:[UIRefreshControl class]]) {
            return subView;
        }
    }
    return nil;
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


#pragma mark - Get
- (NTESChatroomConfig *)config{
    if (!_config) {
        _config = [[NTESChatroomConfig alloc] initWithChatroom:self.chatroom.roomId];
    }
    return _config;
}


#pragma mark - Cell Actions

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



@end
