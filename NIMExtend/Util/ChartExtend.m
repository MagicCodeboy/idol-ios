//
//  ChartExtend.m
//  jinshanStrmear
//
//  Created by wsmbp on 2018/4/4.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "ChartExtend.h"
#import "NTESBundleSetting.h"
#import <NIMSDK/NIMSDK.h>
#import "SVProgressHUD.h"
#import "NTESChatroomViewController.h"
#import "NTESChatroomManager.h"
#import "UIView+Toast.h"
@implementation ChartExtend
+(void)chartRoomWithRoomID:(NSString *)roomid controller:(UIViewController *)controller{
    NIMChatroom *chatroom = [[NIMChatroom alloc]init];
    chatroom.roomId=roomid;
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:[NIMSDK sharedSDK].loginManager.currentAccount];
    NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
    request.roomId = chatroom.roomId;
    request.roomNickname = user.userInfo.nickName;
    request.roomAvatar = user.userInfo.avatarUrl;
    request.retryCount = [[NTESBundleSetting sharedConfig] chatroomRetryCount];
//    __weak typeof(self) wself = self;
    [SVProgressHUD show];

    [[[NIMSDK sharedSDK] chatroomManager] enterChatroom:request
                                             completion:^(NSError *error,NIMChatroom *chatroom,NIMChatroomMember *me) {
                                                 [SVProgressHUD dismiss];
                                                 if (error == nil)
                                                 {
                                                     [[NTESChatroomManager sharedInstance] cacheMyInfo:me roomId:chatroom.roomId];

                                                     NTESChatroomViewController *vc = [[NTESChatroomViewController alloc] initWithChatroom:chatroom];
                                                     [controller.navigationController pushViewController:vc animated:YES];
                                                 }
                                                 else
                                                 {
                                                     NSString *toast = [NSString stringWithFormat:@"进入失败 code:%zd",error.code];
                                                     [controller.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                                                     NSLog(@"enter room %@ failed %@",chatroom.roomId,error);
                                                 }

                                             }];

}
@end
