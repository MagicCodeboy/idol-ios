//
//  SignInView.h
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnowView.h"

typedef void(^TextShouldChangeBlock)();
@interface SignInView : UIView

@property (nonatomic,copy) TextShouldChangeBlock changeTextBlock;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *starNameImageView;
@property (nonatomic, strong) UILabel *starNameLabel;
@property (nonatomic, strong) UIImageView *messageImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) SnowView *snowView;

@property (nonatomic,copy) NSString *textString;

-(void)setContentText:(NSString *)string;
-(void)showGoldCoindsViewWithPicName:(NSString *)name;
-(void)updateNameLabelContainsWithNameString:(NSString *)nameString;
@end
