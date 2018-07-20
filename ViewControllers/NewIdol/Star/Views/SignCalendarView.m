//
//  SignCalendarView.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/20.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "SignCalendarView.h"
#import "UILabel+Tool.h"
#import "UIColor+Category.h"
#import "BPPCalendar.h"
#import "UIButton+EnlargeEdge.h"

@interface SignCalendarView()
@property(nonatomic, strong) BPPCalendar *calender;
@end
@implementation SignCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self setupViews];
    }
    return self;
}
-(void)setupViews{
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 92)];
        CAGradientLayer *layer = [UIColor createByCAGradientLayer:UIColorFromRGB(0x4D2BB8) endColor:UIColorFromRGB(0xB264D5) layerFrame:_topView.frame direction:GradientTypeLeftToRight];
        [_topView.layer addSublayer:layer];
        _topView.layer.cornerRadius = 10;
        _topView.layer.masksToBounds = YES;
        [self addSubview:_topView];
    }
    if (_closeButton == nil) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"tanchuang_gb_h_"] forState:UIControlStateNormal];
        [_closeButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [self.topView addSubview:_closeButton];
    }
    if (_signRuleLabel == nil) {
        _signRuleLabel = [[UILabel alloc] init];
        [_signRuleLabel setLabelWithFontName:@"PingFangSC-Regular" andFontSize:12 andTextColor:UIColorFromRGB(0xFFFFFF) andTextAlignment:NSTextAlignmentRight];
        _signRuleLabel.text = LocalizedOtherStr(@"SignRules");
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.maximumLineHeight = 14;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        _signRuleLabel.attributedText = [[NSAttributedString alloc] initWithString:_signRuleLabel.text attributes:dic];
        [self.topView addSubview:_signRuleLabel];
    }
    if (_signRuleDetailLabel == nil) {
        _signRuleDetailLabel = [[UILabel alloc] init];
        [_signRuleDetailLabel setLabelWithFontName:@"PingFangSC-Regular" andFontSize:13 andTextColor:UIColorFromRGB(0xFFFFFF) andTextAlignment:NSTextAlignmentLeft];
        _signRuleDetailLabel.numberOfLines = 0;
        _signRuleDetailLabel.text = @"Daily check-ins to get a favorite star of the star, the total check-in 110 days ranked 11th.";
        [self.topView addSubview:_signRuleDetailLabel];
    }
    if (_calendarView == nil) {
        _calendarView = [[UIView alloc] init];
        _calendarView.backgroundColor = [UIColor clearColor];
        [self addSubview:_calendarView];
    }
    if (_calender == nil) {
        _calender = [[BPPCalendar alloc] initWithFrame:CGRectMake(0, 0, 300, 240)];
        WeakSelf(weakSelf, self);
        _calender.signDoneBlock = ^(BOOL isSignSuccess) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userHaveSignCurrentStarWithStarId:)]) {
                [weakSelf.delegate userHaveSignCurrentStarWithStarId:0];
            }
        };
        [self.calendarView addSubview:_calender];
    }
    [self setLayoutSubviews];
}
-(void)setLayoutSubviews{
    [self.calendarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(85);
        make.left.right.bottom.mas_equalTo(self);
    }];
    [self.calender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.calendarView);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.equalTo(@92);
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self).offset(15);
        make.height.width.equalTo(@11);
    }];
    [self.signRuleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.top.mas_offset(8.5);
        make.height.equalTo(@12);
    }];
    [self.signRuleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.closeButton);
        make.top.mas_offset(40);
        make.right.mas_offset(-15);
    }];
    
}
-(void)setPersonModel:(PersonModel *)personModel{
    self.signRuleDetailLabel.text = personModel.userSignDirections;
    self.calender.personModel = personModel;
}

@end
