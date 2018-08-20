//
//  GroupInfoViewController.h
//  jinshanStrmear
//
//  Created by wsmbp on 2018/4/20.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "UIBaseViewController.h"
#import <NIMSDK/NIMSDK.h>

@interface GroupInfoViewController : UIBaseViewController
- (instancetype)initWithChatroom:(NIMChatroom *)chatroom;

@end
