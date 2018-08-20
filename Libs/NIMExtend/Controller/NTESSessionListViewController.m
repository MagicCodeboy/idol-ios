//
//  NTESSessionListViewController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionListViewController.h"
#import "NTESSessionViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESListHeader.h"
#import "NTESSessionUtil.h"
#define SessionListTitle @"云信 Demo"

@interface NTESSessionListViewController ()<NIMLoginManagerDelegate,NTESListHeaderDelegate,NIMEventSubscribeManagerDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) NTESListHeader *header;

@property (nonatomic,assign) BOOL supportsForceTouch;

@property (nonatomic,strong) NSMutableDictionary *previews;

@end

@implementation NTESSessionListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _previews = [[NSMutableDictionary alloc] init];
        self.autoRemoveRemoteSession = [[NTESBundleSetting sharedConfig] autoRemoveRemoteSession];
    }
    return self;
}

- (void)dealloc{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.supportsForceTouch = [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
    
    self.header = [[NTESListHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    [self.view addSubview:self.header];

    self.emptyTipLabel = [[UILabel alloc] init];
    self.emptyTipLabel.text = @"还没有会话，在通讯录中找个人聊聊吧";
    [self.emptyTipLabel sizeToFit];
    self.emptyTipLabel.hidden = self.recentSessions.count;
    [self.view addSubview:self.emptyTipLabel];
    
    NSString *userID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    self.navigationItem.titleView  = [self titleView:userID];
    [self setUpNavItem];
}

- (void)setUpNavItem{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setImage:[UIImage imageNamed:@"icon_sessionlist_more_normal"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"icon_sessionlist_more_pressed"] forState:UIControlStateHighlighted];
    [moreBtn sizeToFit];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)refresh{
    [super refresh];
    self.emptyTipLabel.hidden = self.recentSessions.count;
}

- (void)more:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *markAllMessagesReadAction = [UIAlertAction actionWithTitle:@"标记所有消息为已读"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [[NIMSDK sharedSDK].conversationManager markAllMessagesRead];
                                                        }];
    [vc addAction:markAllMessagesReadAction];
    
    
    UIAlertAction *cleanAllMessagesAction = [UIAlertAction actionWithTitle:@"清理所有消息"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                         BOOL removeRecentSessions = [NTESBundleSetting sharedConfig].removeSessionWhenDeleteMessages;
                                                                         BOOL removeTables = [NTESBundleSetting sharedConfig].dropTableWhenDeleteMessages;

                                                                         NIMDeleteMessagesOption *option = [[NIMDeleteMessagesOption alloc] init];
                                                                         option.removeSession = removeRecentSessions;
                                                                         option.removeTable = removeTables;

                                                                         [[NIMSDK sharedSDK].conversationManager deleteAllMessages:option];
                                                                     }];
    [vc addAction:cleanAllMessagesAction];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                                     style:UIAlertActionStyleCancel
                                                                   handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onSelectedRecent:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onSelectedAvatar:(NIMRecentSession *)recent
             atIndexPath:(NSIndexPath *)indexPath{
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        if ([[NIMSDK sharedSDK].robotManager isValidRobot:recent.session.sessionId])
        {
        }
        else
        {
        }
    }
}


- (void)onDeleteRecentAtIndexPath:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    [super onDeleteRecentAtIndexPath:recent atIndexPath:indexPath];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self refreshSubview];
}


- (NSString *)nameForRecentSession:(NIMRecentSession *)recent{
    if ([recent.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        return @"我的电脑";
    }
    return [super nameForRecentSession:recent];
}

#pragma mark - SessionListHeaderDelegate

- (void)didSelectRowType:(NTESListHeaderType)type{
    //多人登录
    NSLog(@"多段登录");
}


#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step{
    [super onLogin:step];
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(未连接)"];
            break;
        case NIMLoginStepLinking:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(连接中)"];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.titleLabel.text = SessionListTitle;
            break;
        case NIMLoginStepSyncing:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(同步数据)"];
            break;
        default:
            break;
    }
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    [self.header refreshWithType:ListHeaderTypeNetStauts value:@(step)];
    [self refreshSubview];
}

- (void)onMultiLoginClientsChanged
{
    [self.header refreshWithType:ListHeaderTypeLoginClients value:[NIMSDK sharedSDK].loginManager.currentLoginClients];
    [self refreshSubview];
}



#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.supportsForceTouch) {
        id<UIViewControllerPreviewing> preview = [self registerForPreviewingWithDelegate:self sourceView:cell];
        [self.previews setObject:preview forKey:@(indexPath.row)];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.supportsForceTouch) {
        id<UIViewControllerPreviewing> preview = [self.previews objectForKey:@(indexPath.row)];
        [self unregisterForPreviewingWithContext:preview];
        [self.previews removeObjectForKey:@(indexPath.row)];
    }
}


- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)context viewControllerForLocation:(CGPoint)point {
    UITableViewCell *touchCell = (UITableViewCell *)context.sourceView;
    if ([touchCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:touchCell];
     
        return nil;
    }
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    UITableViewCell *touchCell = (UITableViewCell *)previewingContext.sourceView;
    if ([touchCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:touchCell];
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
        [self.navigationController showViewController:vc sender:nil];
    }
}


#pragma mark - NIMEventSubscribeManagerDelegate

- (void)onRecvSubscribeEvents:(NSArray *)events
{
    NSMutableSet *ids = [[NSMutableSet alloc] init];
    for (NIMSubscribeEvent *event in events) {
        [ids addObject:event.from];
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        if (recent.session.sessionType == NIMSessionTypeP2P) {
            NSString *from = recent.session.sessionId;
            if ([ids containsObject:from]) {
                [indexPaths addObject:indexPath];
            }
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}



#pragma mark - Private

- (void)refreshSubview{
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    if (@available(iOS 11.0, *))
    {
        self.header.top = self.view.safeAreaInsets.top;
        self.tableView.top = self.header.bottom;
        CGFloat offset = self.view.safeAreaInsets.bottom;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
    }
    else
    {
        self.tableView.top = self.header.height;
        self.header.bottom    = self.tableView.top + self.tableView.contentInset.top;
    }
    self.tableView.height = self.view.height - self.tableView.top;
    
    self.emptyTipLabel.centerX = self.view.width * .5f;
    self.emptyTipLabel.centerY = self.tableView.height * .5f;
}

- (UIView*)titleView:(NSString*)userID{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text =  SessionListTitle;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [self.titleLabel sizeToFit];
    UILabel *subLabel  = [[UILabel alloc] initWithFrame:CGRectZero];
    subLabel.textColor = [UIColor grayColor];
    subLabel.font = [UIFont systemFontOfSize:12.f];
    subLabel.text = userID;
    subLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [subLabel sizeToFit];
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width  = subLabel.width;
    titleView.height = self.titleLabel.height + subLabel.height;
    
    subLabel.bottom = titleView.height;
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:subLabel];
    return titleView;
}


- (NSAttributedString *)contentForRecentSession:(NIMRecentSession *)recent{
    NSAttributedString *content;
    if (recent.lastMessage.messageType == NIMMessageTypeCustom)
    {
//        NIMCustomObject *object = recent.lastMessage.messageObject;
        NSString *text = @"";
     
            text = @"[未知消息]";
        if (recent.session.sessionType != NIMSessionTypeP2P)
        {
            NSString *nickName = [NTESSessionUtil showNick:recent.lastMessage.from inSession:recent.lastMessage.session];
            text =  nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
        }
        content = [[NSAttributedString alloc] initWithString:text];
    }
    else
    {
        content = [super contentForRecentSession:recent];
    }
    NSMutableAttributedString *attContent = [[NSMutableAttributedString alloc] initWithAttributedString:content];
    [self checkNeedAtTip:recent content:attContent];
    [self checkOnlineState:recent content:attContent];
    return attContent;
}


- (void)checkNeedAtTip:(NIMRecentSession *)recent content:(NSMutableAttributedString *)content
{
    if ([NTESSessionUtil recentSessionIsAtMark:recent]) {
        NSAttributedString *atTip = [[NSAttributedString alloc] initWithString:@"[有人@你] " attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        [content insertAttributedString:atTip atIndex:0];
    }
}

- (void)checkOnlineState:(NIMRecentSession *)recent content:(NSMutableAttributedString *)content
{
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NSString *state  = [NTESSessionUtil onlineState:recent.session.sessionId detail:NO];
        if (state.length) {
            NSString *format = [NSString stringWithFormat:@"[%@] ",state];
            NSAttributedString *atTip = [[NSAttributedString alloc] initWithString:format attributes:nil];
            [content insertAttributedString:atTip atIndex:0];
        }
    }
    
}

@end
