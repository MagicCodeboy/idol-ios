//
//  UILabel+Tool.h
//  jinshanStrmear
//
//  Created by panhongliu on 2016/10/11.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Tool)
//设置不同字体颜色
-(void )fuwenbenLabelWithFontNumber:(id)font AndRange:(NSRange)range andTwoRange:(NSRange)rangeTwo AndColor:(UIColor *)vaColor;
-(void)setLabelWithFontName:(NSString *)fontName andFontSize:(CGFloat)fontSize andTextColor:(UIColor *)color andTextAlignment:(NSTextAlignment)textAlignment;
//设置不同字体颜色
-(void )fuwenbenLabelWithFontNumber:(UIFont *)font AndRange:(NSRange)range  AndColor:(UIColor *)vaColor;

/**
 *  设置字间距
 */
- (void)setColumnSpace:(CGFloat)columnSpace;
/**
 *  设置行距
 */
- (void)setRowSpace:(CGFloat)rowSpace;

@end
