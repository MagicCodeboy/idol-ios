//
//  NSString+Tool.m
//  jinshanStrmear
//
//  Created by panhongliu on 16/7/20.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "NSString+Tool.h"

@implementation NSString (Tool)
+(NSString *)stringWithDate{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString*strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"%@",strDate);
    
    return strDate;
}
+(NSString *)stringWithDateTime:(NSString *)time{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:time];
     return  [dateFormatter stringFromDate:[NSDate date]];
}
+(NSString *)getCurrentDateStr
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}
+ (nullable NSString *)getDateWithTimeString:(nullable NSString *)string
{
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateStyle:NSDateFormatterMediumStyle];
    //    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //    [formatter setDateFormat:@"YYYY-MM-dd"];
    //    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[string intValue]];
    //
    
    NSTimeInterval _interval=[string doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"YYYY-MM-dd"];
    //获取本地的时区 设置时区
    NSString *currentTimeZone = [[NSTimeZone localTimeZone] name];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:currentTimeZone];
    [objDateformat setTimeZone:timeZone];
    //    [objDateformat setDateFormat:@"yyyy-MM-dd  HH:mm"];
    
    
    NSString *confromTimespStr = [objDateformat stringFromDate:date];
    
    return confromTimespStr;
}
//分别根据时间戳与标准时间计算: 几分钟之前，几小时之前
+ (NSString *)timeBeforeInfoWithString:(NSTimeInterval)timeIntrval{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *conformTime = [NSDate dateWithTimeIntervalSince1970:timeIntrval];
    //获取此时时间戳长度
    NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970] *1000;
    int timeInt = (nowTimeinterval - timeIntrval) / 1000; //时间差
    
    int year = timeInt / (3600 * 24 * 30 *12);
    int month = timeInt / (3600 * 24 * 30);
    int day = timeInt / (3600 * 24);
    int hour = timeInt / 3600;
    int minute = timeInt / 60;
    if (year > 0) {
        NSString *yearsString = [dateFormatter stringFromDate:conformTime];
//        NSString *yearsString = LocalizedOtherStr(@"Years ago");
//        [NSString stringWithFormat:@"%d %@",year,yearsString];
        return yearsString;
    }else if(month > 0){
        NSString *monthString = LocalizedOtherStr(@"Months ago");
        return [NSString stringWithFormat:@"%d %@",month,monthString];
    }else if(day > 0){
        NSString *dayString = LocalizedOtherStr(@"Days ago");
        return [NSString stringWithFormat:@"%d %@",day,dayString];
    }else if(hour > 0){
        NSString *hourString = LocalizedOtherStr(@"Hours ago");
        return [NSString stringWithFormat:@"%d %@",hour,hourString];
    }else if(minute > 0){
        NSString *minuteString = LocalizedOtherStr(@"Minutes ago");
        return [NSString stringWithFormat:@"%d %@",minute,minuteString];
    }else{
        return LocalizedOtherStr(@"just now");
    }
}

/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.height);
}

/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width);
}


#pragma mark - 根据一定高度/宽度返回宽度/高度
/**
 *  @brief  根据一定高度/宽度返回宽度/高度
 *  @category
 *  @param  goalString            目标字符串
 *  @param  font;                 字号
 *  @param  fixedSize;            固定的宽/高
 *  @param  isWidth;              是否是宽固定(用于区别宽/高)
 **/
// 根据文字（宽度/高度一定,字号一定的情况下）  算出高度/宽度
+ (CGFloat)getStringSizeWith:(NSString *)goalString withStringFont:(CGFloat)font withWidthOrHeight:(CGFloat)fixedSize isWidthFixed:(BOOL)isWidth{
    CGSize   sizeC ;
    if (isWidth) {
        sizeC = CGSizeMake(fixedSize ,MAXFLOAT);
    }else{
        sizeC = CGSizeMake(MAXFLOAT ,fixedSize);
    }
    CGSize   sizeFileName = [goalString boundingRectWithSize:sizeC
                                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Bauhaus93" size:font]}
                                                     context:nil].size;
    return sizeFileName.width;
}

#pragma mark 从一个字符串中提取指定位置的字符

+(NSString *)getNSString:(NSString *)_string atIndex:(int)_index
{
    NSString *tempString;
    tempString = nil;
    if((_string)&&(_index>=0))
    {
        //先计算索引值是否大于字符串的长度，如果大于字符串的长度则索引指向字符串的最后一个位置
        if(_index>=[_string length])
        {
            _index = (int)[_string length];
        }
        if(_index==0)
        {
            _index = 1;
            tempString = [_string substringToIndex:_index];
        }
        else
        {
            tempString = [[_string substringToIndex:_index]substringFromIndex:(_index-1)];
        }
    }
    return tempString;
}
@end
