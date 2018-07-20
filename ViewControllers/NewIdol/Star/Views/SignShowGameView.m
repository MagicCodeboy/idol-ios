

//
//  SignShowGameView.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/22.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "SignShowGameView.h"
#import "UILabel+Tool.h"
#import "NSString+Tool.h"
@implementation SignShowGameView
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
        _contentView.backgroundColor = [UIColor clearColor];
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
        _messageLabel.text = @"";
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
    if (_skipButton == nil) {
        _skipButton = [[UIButton alloc] init];
//        [_skipButton setImage:[UIImage imageNamed:@"tiaoguo_"] forState:UIControlStateNormal];
        _skipButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tiaoguo_"]];
        _skipButton.adjustsImageWhenHighlighted = YES;
        [_skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [_skipButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
        _skipButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_skipButton];
    }
    [self setLayoutSubViews];
}
-(void)setlabelTextWithString:(NSString *)string{
    if (self.isNotFirstShow) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.textString= string;
            _thread = [[NSThread alloc]initWithTarget:self selector:@selector(animationLabel) object:nil];
            [self.thread start];
        });
    } else {
        self.textString= string;
        _thread = [[NSThread alloc]initWithTarget:self selector:@selector(animationLabel) object:nil];
        [self.thread start];
        self.isNotFirstShow = YES;
    }
    
    NSLog(@"self.thread%@",self.thread);
    NSLog(@"mainThread%@",[NSThread mainThread]);
}
- (void)animationLabel
{
    for (NSInteger i = 0; i < self.textString.length; i++)
    {
        [self performSelectorOnMainThread:@selector(refreshUIWithContentStr:) withObject:[self.textString substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
        [NSThread sleepForTimeInterval:0.2];
        if ([NSThread currentThread].isCancelled) {
            return;
        }
        if (i == self.textString.length - 1) {
            [self.thread cancel];
            self.thread = nil;
            if (self.changeTextBlock) {
                self.changeTextBlock();
            }
        }
    }
}
-(void)cancelTheMainMethond{
    [self.thread cancel];
    self.thread = nil;
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
    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.bottom.mas_offset(-35);
        make.height.equalTo(@26);
        make.width.equalTo(@82);
    }];
}
-(void)updateNameLabelContainsWithString:(NSString *)nameString{
    CGFloat width = [nameString widthWithFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14] constrainedToHeight:18];
    NSLog(@"计算出来的明星的名字的宽度%f",width);
    [self.starNameImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.messageImageView);
        make.bottom.mas_equalTo(self.messageLabel.mas_top).offset(-8.5);
        make.height.equalTo(@26);
        make.width.equalTo(@(width + 40));
    }];
    [self.starNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.starNameImageView);
    }];
    [self layoutIfNeeded];
}
@end
