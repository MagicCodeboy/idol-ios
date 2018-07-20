//
//  LuckFansOwn.h
//  云信全聚星
//
//  Created by 裴雪阳 on 16/6/16.
//  Copyright © 2016年 裴雪阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LuckFansOwn : UIView
@property (weak, nonatomic) IBOutlet UIImageView *GiftView;
+ (instancetype)LuckFansOwnView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UIButton *weixinQuan;
@property (weak, nonatomic) IBOutlet UIButton *weixin;
@property (weak, nonatomic) IBOutlet UIButton *weibo;
@property (weak, nonatomic) IBOutlet UIButton *qq;
@property (weak, nonatomic) IBOutlet UIButton *qqkongjian;
@property(nonatomic,strong)NSArray *ButtonArray;//分享的按钮存放的数组

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weixinContent;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weixinQuanContent;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerContent;

@property (weak, nonatomic) IBOutlet UILabel *GiftLable;

@end
