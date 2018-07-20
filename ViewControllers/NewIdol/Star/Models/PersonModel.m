//
//  PersonModel.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/23.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "PersonModel.h"

@implementation PersonModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"personPlotSignAfter" : @"PersonPlotModel",
             @"personPlotSignBefore" : @"PersonPlotModel",
             @"personSignPic" : @"PersonSignPic",
             @"personSignPicHomePage" : @"PersonSignPic"
             };
}
@end

@implementation PersonPlotModel

@end

@implementation PersonSignPic

@end

@implementation PersonSignVideoModel

@end
