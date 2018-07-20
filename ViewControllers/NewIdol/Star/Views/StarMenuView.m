//
//  StarMenuView.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "StarMenuView.h"
#import "UILabel+Tool.h"
#import "UIButton+EnlargeEdge.h"

@interface StarMenuView()
@property(nonatomic, strong) NSMutableArray * picArray;
@property(nonatomic, strong) UIView *buttonViews;
@end

@implementation StarMenuView

-(NSMutableArray *)picArray{
    if (_picArray == nil) {
        _picArray = [NSMutableArray arrayWithArray:@[@"zbuye_tv_",@"zhuye_dongtai_",@"zhueye_xiaoxi_",@"zhuye_huodong_",@"zhuye_yingyuan_",@"zhuye_shop_",@"zhuye_tuji_",@"zhuye_jiaoyisuo_"]];
    }
    return _picArray;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        [self setUpViews];
    }
    return self;
}
-(void)setViewWithButtonArrays:(NSArray *)buttonArray andHaveShopOrNot:(BOOL)isHaveShop{
    [self setUpViewswithShopOrNot:isHaveShop];
}
-(void)setUpViewswithShopOrNot:(BOOL)isHaveShopOrNot{
    if (_theBottomView == nil) {
        _theBottomView = [[UIView alloc] init];
        _theBottomView.backgroundColor = [UIColor clearColor];
        [self addSubview:_theBottomView];
    }
    if (_starImageView == nil) {
        _starImageView = [[UIImageView alloc] init];
        _starImageView.contentMode = UIViewContentModeScaleAspectFill;
        _starImageView.layer.cornerRadius = 25;
        _starImageView.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
        _starImageView.layer.borderWidth = 1;
        _starImageView.layer.masksToBounds = YES;
        _starImageView.image = [UIImage imageNamed:@"22"];
        [self.theBottomView addSubview:_starImageView];
    }
    if (_attentionButton == nil) {
        _attentionButton = [[UIButton alloc] init];
        [_attentionButton setImage:[UIImage imageNamed:@"guanzhu_jia_"] forState:UIControlStateNormal];
        [_attentionButton setImage:[UIImage imageNamed:@"guanzhu_jian_-1"] forState:UIControlStateSelected];
        [_attentionButton setEnlargeEdgeWithTop:10 right:10 bottom:15 left:10];
        _attentionButton.adjustsImageWhenHighlighted = YES;
        _attentionButton.tag = 2008;
         [_attentionButton addTarget:self action:@selector(buttonsClickMethond:) forControlEvents:UIControlEventTouchUpInside];
        [self.theBottomView addSubview:_attentionButton];
    }
    if (_fansNumberLabel == nil) {
        _fansNumberLabel = [[UILabel alloc] init];
        [_fansNumberLabel setLabelWithFontName:@"Helvetica" andFontSize:13 andTextColor:UIColorFromRGB(0xFFFFFF) andTextAlignment:NSTextAlignmentCenter];
        _fansNumberLabel.text = @"5000800";
        [self.theBottomView addSubview:_fansNumberLabel];
    }
    if (_buttonViews == nil) {
        _buttonViews = [[UIView alloc] init];
        _buttonViews.backgroundColor = [UIColor clearColor];
        [self.theBottomView addSubview:_buttonViews];
    }
    _oneButton = [[UIButton alloc] init];
    _oneButton.tag = 2000;
    _twoButton = [[UIButton alloc] init];
    _twoButton.tag = 2001;
    _threeButton = [[UIButton alloc] init];
    _threeButton.tag = 2002;
    _fourButton = [[UIButton alloc] init];
    _fourButton.tag = 2003;
    _fiveButton = [[UIButton alloc] init];
    _fiveButton.tag = 2004;
    _sixButton = [[UIButton alloc] init];
    _sixButton.tag = 2005;
    _sevenButton = [[UIButton alloc] init];
    _sevenButton.tag = 2006;
    _eightButton = [[UIButton alloc] init];
    _eightButton.tag = 2007;
    [self setUpWithButton:_oneButton andImage:self.picArray[0]];
    [self setUpWithButton:_twoButton andImage:self.picArray[1]];
    [self setUpWithButton:_threeButton andImage:self.picArray[2]];
    [self setUpWithButton:_fourButton andImage:self.picArray[3]];
    [self setUpWithButton:_fiveButton andImage:self.picArray[4]];
    [self setUpWithButton:_sixButton andImage:self.picArray[5]];
    [self setUpWithButton:_sevenButton andImage:self.picArray[6]];
    [self setUpWithButton:_eightButton andImage:self.picArray[7]];
    [_oneButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_twoButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_threeButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_fourButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_fiveButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_sixButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_sevenButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [_eightButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [self.buttonViews addSubview:self.oneButton];
    [self.buttonViews addSubview:self.twoButton];
    [self.buttonViews addSubview:self.threeButton];
    [self.buttonViews addSubview:self.fourButton];
    [self.buttonViews addSubview:self.fiveButton];
   
    
    [self.theBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self);
    }];
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(self.theBottomView);
        make.height.width.equalTo(@50);
    }];
    [self.attentionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.starImageView);
        make.height.width.equalTo(@15);
    }];
    [self.fansNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.theBottomView);
        make.top.mas_equalTo(self.starImageView.mas_bottom).offset(8);
        make.height.equalTo(@13);
    }];
    [self.buttonViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.theBottomView);
        make.top.mas_equalTo(self.theBottomView).offset(55);
        make.bottom.mas_offset(-5);
    }];
    
    NSArray * array = nil;
    
    if (isHaveShopOrNot) {
        [self.buttonViews addSubview:self.sixButton];
        [self.buttonViews addSubview:self.sevenButton];
        [self.buttonViews addSubview:self.eightButton];
         array = @[self.oneButton,self.twoButton,self.sevenButton];
    } else {
        [self.buttonViews addSubview:self.sevenButton];
        [self.buttonViews addSubview:self.eightButton];
        array = @[self.oneButton,self.twoButton,self.sevenButton];
    }
    CGFloat padding = 22;
    [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedItemLength:30 leadSpacing:padding tailSpacing:padding];
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.height.equalTo(@30);
    }];
}
-(void)setUpWithButton:(UIButton *)btn andImage:(NSString *)imageName{
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = YES;
    [btn addTarget:self action:@selector(buttonsClickMethond:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)buttonsClickMethond:(UIButton *)btn{
    if (self.buttonClick) {
        self.buttonClick(btn.tag);
    }
}


@end
