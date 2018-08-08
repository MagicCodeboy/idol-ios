//
//  Y_StockChartRightYView.m
//  BTC-Kline
//
//  Created by yate1996 on 16/5/3.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "Y_StockChartRightYView.h"
#import "UIColor+Y_StockChart.h"
#import "Masonry.h"

@interface Y_StockChartRightYView ()

@property(nonatomic,strong) UILabel *maxValueLabel;

@property(nonatomic,strong) UILabel *middleValueLabel;

@property(nonatomic,strong) UILabel *minValueLabel;

@property (nonatomic, strong) UILabel *maxAndMiddleValueLabel;

@property (nonatomic, strong) UILabel *minAndMiddleValueLabel;

@end


@implementation Y_StockChartRightYView

-(void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    if (self.isShouldShowTheTwoLabel) {
        self.maxValueLabel.text = [NSString stringWithFormat:@"%.6f",maxValue * 1.5];
        self.maxAndMiddleValueLabel.text = [NSString stringWithFormat:@"%.6f",maxValue];
    } else {
        self.maxValueLabel.text = [NSString stringWithFormat:@"%.6f",maxValue];
    }
}

-(void)setMiddleValue:(CGFloat)middleValue
{
    _middleValue = middleValue;
    self.middleValueLabel.text = [NSString stringWithFormat:@"%.6f",middleValue];
}

-(void)setMinValue:(CGFloat)minValue
{
    _minValue = minValue;
    if (self.isShouldShowTheTwoLabel) {
        self.minValueLabel.text = [NSString stringWithFormat:@"%.6f",minValue * 0.5];
        self.minAndMiddleValueLabel.text = [NSString stringWithFormat:@"%.6f",minValue];
    } else {
        self.minValueLabel.text = [NSString stringWithFormat:@"%.6f",minValue];
    }
}

-(void)setMinLabelText:(NSString *)minLabelText
{
    _minLabelText = minLabelText;
    self.minValueLabel.text = minLabelText;
}

#pragma mark - get方法
#pragma mark maxPriceLabel的get方法
-(UILabel *)maxValueLabel
{
    if (!_maxValueLabel) {
        _maxValueLabel = [self private_createLabel];
        [self addSubview:_maxValueLabel];
        [_maxValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.width.equalTo(self);
            make.height.equalTo(@20);
        }];
    }
    return _maxValueLabel;
}

#pragma mark middlePriceLabel的get方法
-(UILabel *)middleValueLabel
{
    if (!_middleValueLabel) {
        _middleValueLabel = [self private_createLabel];
        [self addSubview:_middleValueLabel];
        [_middleValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.right.equalTo(self);
            make.height.width.equalTo(self.maxValueLabel);
        }];
    }
    return _middleValueLabel;
}

#pragma mark minPriceLabel的get方法
-(UILabel *)minValueLabel
{
    if (!_minValueLabel) {
        _minValueLabel = [self private_createLabel];
        [self addSubview:_minValueLabel];
        [_minValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.height.width.equalTo(self.maxValueLabel);
        }];
    }
    return _minValueLabel;
}

-(UILabel *)maxAndMiddleValueLabel{
    if (!_maxAndMiddleValueLabel) {
        _maxAndMiddleValueLabel = [self private_createLabel];
        [self addSubview:_maxAndMiddleValueLabel];
//        CGFloat margin = (self.height - 10 * 5) / 4;
        [_maxAndMiddleValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.right.equalTo(self.maxValueLabel);
            make.top.mas_equalTo(self.maxValueLabel.mas_bottom).offset(10);
        }];
    }
    return _maxAndMiddleValueLabel;
}
-(UILabel *)minAndMiddleValueLabel{
    if (!_minAndMiddleValueLabel) {
        _minAndMiddleValueLabel = [self private_createLabel];
        [self addSubview:_minAndMiddleValueLabel];
//        CGFloat margin = (self.height - 10 * 5) / 4;
        [_minAndMiddleValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.right.equalTo(self.maxValueLabel);
            make.bottom.mas_equalTo(self.minValueLabel.mas_top).offset(-10);
        }];
    }
    return _minAndMiddleValueLabel;
}

#pragma mark - 私有方法
#pragma mark 创建Label
- (UILabel *)private_createLabel
{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor assistTextColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:label];
    return label;
}
@end
