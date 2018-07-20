//
//  UILabel+Tool.m
//  jinshanStrmear
//
//  Created by panhongliu on 2016/10/11.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "UILabel+Tool.h"
#import <CoreText/CoreText.h>

@implementation UILabel (Tool)
-(void )fuwenbenLabelWithFontNumber:(id)font AndRange:(NSRange)range andTwoRange:(NSRange)rangeTwo AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    [str addAttribute:NSFontAttributeName value:font range:rangeTwo];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:rangeTwo];
    self.attributedText = str;
    
}
-(void )fuwenbenLabelWithFontNumber:(UIFont *)font AndRange:(NSRange)range  AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    self.attributedText = str;
    
}
-(void)setLabelWithFontName:(NSString *)fontName andFontSize:(CGFloat)fontSize andTextColor:(UIColor *)color andTextAlignment:(NSTextAlignment)textAlignment{
    if (fontName) {
        self.font = [UIFont fontWithName:fontName size:fontSize];
    } else {
        self.font = [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
    }
    self.textAlignment = textAlignment;
    self.textColor = color;
}

- (void)setColumnSpace:(CGFloat)columnSpace
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    //调整间距
    [attributedString addAttribute:(__bridge NSString *)kCTKernAttributeName value:@(columnSpace) range:NSMakeRange(0, [attributedString length])];
    self.attributedText = attributedString;
}

- (void)setRowSpace:(CGFloat)rowSpace
{
    self.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    //调整行距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = rowSpace;
    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
    self.attributedText = attributedString;
}

@end
