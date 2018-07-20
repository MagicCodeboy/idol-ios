//
//  UIColor+Category.m
//  jinshanStrmear
//
//  Created by panhongliu on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor{
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = [UIScreen mainScreen].bounds;
    //  创建渐变色数组，需要转换为CGColor颜色
    UIColor *fromColorTemp=nil,*ToColorTemp=nil;
    if (!fromColor) {
        fromColorTemp=UIColorFromRGB(0x3E206A);
    }else{
        fromColorTemp=fromColor;

    }
    if (!ToColorTemp) {
        ToColorTemp=UIColorFromRGB(0x191919);
    }else{
        ToColorTemp=toColor;

    }
    gradientLayer.colors = @[(__bridge id)fromColorTemp.CGColor,(__bridge id)ToColorTemp.CGColor];
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@0.6,@1];
    
    return gradientLayer;
}

+(CAGradientLayer *)createByCAGradientLayer:(UIColor *)startColor endColor:(UIColor *)endColor layerFrame:(CGRect)frame direction:(GradientType)direction{
    
    CAGradientLayer *layer = [CAGradientLayer new];
    //存放渐变的颜色的数组
    layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    //起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
    switch (direction) {
        case GradientTypeTopToBottom:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(0.0, 1);
            break;
        case GradientTypeLeftToRight:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(1, 0.0);
            break;
        default:
            break;
    }
    
    layer.frame = frame;
//    layer.locations = @[@0,@1];

    return layer;
    
}
+(UIImage *)getGradientImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize {
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientTypeTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, imgSize.height);
            break;
        case GradientTypeLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imgSize.width, 0.0);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}
@end
