//
//  StarMenuView.h
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ButtonClick)(NSInteger tag);

@interface StarMenuView : UIView

@property (nonatomic,copy) ButtonClick buttonClick;
@property (nonatomic, strong) UIView *theBottomView;
@property (nonatomic, strong) UIImageView *starImageView;
@property (nonatomic, strong) UIButton *attentionButton;
@property (nonatomic, strong) UILabel *fansNumberLabel;
@property (nonatomic, strong) UIButton * oneButton;
@property (nonatomic, strong) UIButton * twoButton;
@property (nonatomic, strong) UIButton * threeButton;
@property (nonatomic, strong) UIButton * fourButton;
@property (nonatomic, strong) UIButton * fiveButton;
@property (nonatomic, strong) UIButton * sixButton;
@property (nonatomic, strong) UIButton * sevenButton;
@property (nonatomic, strong) UIButton * eightButton;

-(void)setViewWithButtonArrays:(NSArray *)buttonArray andHaveShopOrNot:(BOOL)isHaveShop;

@end
