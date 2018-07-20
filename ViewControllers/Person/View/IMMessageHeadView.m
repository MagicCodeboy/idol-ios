//
//  IMMessageHeadView.m
//  jinshanStrmear
//
//  Created by lalala on 16/10/18.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "IMMessageHeadView.h"

@implementation IMMessageHeadView

+(instancetype)customMessageHeadView{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
}
@end
