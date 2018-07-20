//
//  NSString+Tool.h
//  jinshanStrmear
//
//  Created by panhongliu on 16/7/20.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tool)
//获取当前的时间戳 yyyy-MM-dd HH:mm:ss
+(NSString *)stringWithDate;
//获取时间
+(NSString *)stringWithDateTime:(NSString *)time;
+(NSString *)getCurrentDateStr;


/**
 *  时间戳转换【YYYY-MM-dd】
 *
 *  @param string 时间戳
 *
 *  @return 时间戳转换【YYYY-MM-dd】
 */

+ (nullable NSString *)getDateWithTimeString:(nullable NSString *)string;
/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */

//分别根据时间戳与标准时间计算: 几分钟之前，几小时之前
+ (NSString *)timeBeforeInfoWithString:(NSTimeInterval)timeIntrval;

- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

+ (CGFloat)getStringSizeWith:(NSString *)goalString withStringFont:(CGFloat)font withWidthOrHeight:(CGFloat)fixedSize isWidthFixed:(BOOL)isWidth;

//获取某个位置的字符串
+(NSString *)getNSString:(NSString *)_string atIndex:(int)_index;


@end
NS_ASSUME_NONNULL_END
