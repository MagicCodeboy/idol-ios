//
//  SignInView.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "SignInView.h"
#import "UILabel+Tool.h"
#import "NSString+Tool.h"

@implementation SignInView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = RGBA(0, 0, 0, 0.6);
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColorFromRGB(0x0B0B0B);
        _contentView.alpha = 0.6;
        [self addSubview:_contentView];
    }
    if (_messageImageView == nil) {
        _messageImageView = [[UIImageView alloc] init];
        _messageImageView.image = [UIImage imageNamed:@"duihuakuang_1"];
        _messageImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_messageImageView];
    }
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        [_messageLabel setLabelWithFontName:@"PingFangSC-Regular" andFontSize:11 andTextColor:UIColorFromRGB(0x111010) andTextAlignment:NSTextAlignmentLeft];
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = @"感谢宝宝来观看，你对我的支持我已明记，给你点奖励哦，记得查收！";
        [self addSubview:_messageLabel];
    }
    if (_starNameImageView == nil) {
        _starNameImageView = [[UIImageView alloc] init];
        _starNameImageView.image = [UIImage imageNamed:@"duihuak_bt"];
        _starNameImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_starNameImageView];
    }
    if (_starNameLabel == nil) {
        _starNameLabel = [[UILabel alloc] init];
        [_starNameLabel setLabelWithFontName:@"PingFangSC-Regular" andFontSize:14 andTextColor:UIColorFromRGB(0xFFFFFF) andTextAlignment:NSTextAlignmentCenter];
        _starNameLabel.text = @"Angelababy";
        [self addSubview:_starNameLabel];
    }
    [self setLayoutSubViews];
}
-(void)setContentText:(NSString *)string{
    _messageLabel.text=string;
//    self.textString= string;
//    _thread = [[NSThread alloc]initWithTarget:self selector:@selector(animationLabel) object:nil];
//    [self.thread start];
}
- (void)animationLabel
{
//    for (NSInteger i = 0; i < self.textString.length; i++)
//    {
//        [self performSelectorOnMainThread:@selector(refreshUIWithContentStr:) withObject:[self.textString substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
//        [NSThread sleepForTimeInterval:0.2];
//        if (i == self.textString.length - 1) {
//            [self.thread cancel];
//            if (self.changeTextBlock) {
//                self.changeTextBlock();
//            }
//        }
//    }
}
- (void)refreshUIWithContentStr:(NSString *)contentStr
{
    self.messageLabel.text = contentStr;
}
-(void)setLayoutSubViews{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
    [self.messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(-20);
        make.centerX.mas_equalTo(self);
        make.width.equalTo(@292);
        make.height.equalTo(@70.5);
    }];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageImageView).offset(15);
        make.left.mas_equalTo(self.messageImageView).offset(20);
        make.right.mas_equalTo(self.messageImageView.mas_right).offset(-20);
    }];
    [self.starNameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.messageImageView);
        make.bottom.mas_equalTo(self.messageLabel.mas_top).offset(-8.5);
        make.height.equalTo(@26);
        make.width.equalTo(@105);
    }];
    [self.starNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.starNameImageView);
    }];
}
-(void)showGoldCoindsViewWithPicName:(NSString *)name{
    _snowView = [[SnowView alloc]initWithFrame:self.bounds];
    NSString *imageType = self.width > 750.f ? @"3x" : @"2x";
//    NSString * picName = [NSString stringWithFormat:@"%@%@.png", @"jinbi_1", imageType];
    UIImage * image = [UIImage imageNamed:@"jinbi_1"];
    [_snowView showGoldCoinsImage:image inView:self.contentView];
}
-(void)updateNameLabelContainsWithNameString:(NSString *)nameString{
    CGFloat width = [nameString widthWithFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14] constrainedToHeight:18];
    NSLog(@"计算出来的明星的名字的宽度%f",width);
    [self.starNameImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.messageImageView);
        make.bottom.mas_equalTo(self.messageLabel.mas_top).offset(-8.5);
        make.height.equalTo(@26);
        make.width.equalTo(@(width + 50));
    }];
    [self.starNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.starNameImageView);
    }];
    [self layoutIfNeeded];
}

@end
