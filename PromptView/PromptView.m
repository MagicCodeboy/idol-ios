//
//  PromptView.m
//  jinshanStrmear
//
//  Created by lalala on 16/6/22.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "PromptView.h"

@implementation PromptView
+(id)inPutAlertView
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
}
-(void)awakeFromNib
{
    self.goLook.layer.cornerRadius=self.goLook.height/2;
    self.goLook.layer.borderColor=UIColorFromRGB(0xFF403C).CGColor;
    self.goLook.layer.borderWidth=1;
    self.goLook.layer.masksToBounds=YES;
}

@end
