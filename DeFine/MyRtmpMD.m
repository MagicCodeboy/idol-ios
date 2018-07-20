//
//  MyRtmpMD.m
//  jinshanStrmear
//
//  Created by lalala on 16/7/19.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "MyRtmpMD.h"

@implementation MyRtmpMD

-(NSDictionary *)md5SignWithDic:(NSDictionary *)dic
{
    
    
    NSTimeInterval atime= [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f",atime];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:dic];
    [resultDict setObject:timeString forKey:@"wsTime"];
    
    
    
    return nil;
}

@end
