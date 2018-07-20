//
//  MyCalendarCell.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/20.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "MyCalendarCell.h"
#import "UILabel+Tool.h"
@implementation MyCalendarCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    if (_bottomImageView == nil) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.image = [UIImage imageNamed:@"xuyao_qiandao"];
        _bottomImageView.backgroundColor = [UIColor clearColor];
        _bottomImageView.contentMode = UIViewContentModeScaleAspectFit;
        _bottomImageView.hidden = YES;
        [self.contentView addSubview:_bottomImageView];
    }
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setLabelWithFontName:@"PingFangSC-Regular" andFontSize:14 andTextColor:UIColorFromRGB(0x000000) andTextAlignment:NSTextAlignmentCenter];
        _textLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_textLabel];
    }
    if (_haveSignImageView == nil) {
        _haveSignImageView = [[UIImageView alloc] init];
        _haveSignImageView.image = [UIImage imageNamed:@"yi_"];
        _haveSignImageView.hidden = YES;
        _haveSignImageView.backgroundColor = [UIColor clearColor];
        _haveSignImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_haveSignImageView];
    }
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.mas_equalTo(self.contentView);
    }];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self.contentView);
        make.height.equalTo(@14);
        make.width.equalTo(@17);
    }];
    [self.haveSignImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).offset(0);
        make.centerX.mas_equalTo(self.contentView).offset(2);
        make.height.equalTo(@17);
        make.width.equalTo(@12);
    }];
}
@end
