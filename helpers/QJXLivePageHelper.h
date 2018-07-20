//
//  QJXLivePageManager.h
//  jinshanStrmear
//
//  Created by 曹志宇 on 16/9/14.
//  Copyright © 2016年 曹志宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJXLivePageHelper : NSObject

@property (nonatomic, copy) NSMutableArray<UIViewController *> *livePageArray;

//没关注的人是否有消息未读
@property (nonatomic, copy) NSString * unFollowMessage;
//是否在直播中
@property (nonatomic, assign) BOOL isLiveing;
//正在看直播
@property (nonatomic, assign) BOOL isSeeLiveing;

+ (QJXLivePageHelper *)sharedManager;

@end
