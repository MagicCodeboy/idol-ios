//
//  MyRecruitTopView.m
//  jinshanStrmear
//
//  Created by panhongliu on 2016/11/29.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "MyRecruitTopView.h"

@implementation MyRecruitTopView
+(id)AllocInitView
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
