//
//  NewLiveStopView.m
//  jinshanStrmear
//
//  Created by lalala on 16/8/29.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "NewLiveStopView.h"

@implementation NewLiveStopView

+ (instancetype)newLiveStopView
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}
-(void)awakeFromNib
{
    
    self.bottmVIew.layer.cornerRadius = 5;
    self.bottmVIew.layer.masksToBounds = YES;
    
    self.liveUserImage.layer.cornerRadius = self.liveUserImage.height/2;
    self.liveUserImage.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    self.liveUserImage.layer.borderWidth = 2;
    self.liveUserImage.layer.masksToBounds = YES;
    
    self.comeBackBtn.layer.cornerRadius = self.comeBackBtn.height/2;
    self.comeBackBtn.layer.borderWidth = 1;
    self.comeBackBtn.layer.borderColor= UIColorFromRGB(0xFF554C).CGColor;
    self.comeBackBtn.layer.masksToBounds = YES;
    
    self.viewBottomContent.constant = 158 * SHIJI_HEIGHT;

}

@end
