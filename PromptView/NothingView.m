//
//  NothingView.m
//  jinshanStrmear
//
//  Created by lalala on 16/6/22.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "NothingView.h"

@implementation NothingView

+(id)inputThingView
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
    
}
-(void)awakeFromNib
{
    
}
@end
