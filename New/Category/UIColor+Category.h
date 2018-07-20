//
//  UIColor+Category.h
//  jinshanStrmear
//
//  Created by panhongliu on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, GradientType) {
    GradientTypeTopToBottom = 0,//从上到下
    GradientTypeLeftToRight = 1,//从左到右
};

@interface UIColor (Category)

+(CAGradientLayer *)createByCAGradientLayer:(UIColor *)startColor endColor:(UIColor *)endColor layerFrame:(CGRect)frame direction:(GradientType)direction;

+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

//用法
//UIImageView *temp=[[UIImageView alloc]initWithImage:[UIColor  getGradientImageFromColors:@[UIColorFromRGB(0x3E206A),UIColorFromRGB(0x191919)] imgSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)]];
//    [self.view insertSubview:temp atIndex:0];
+(UIImage *)getGradientImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize;

@end
