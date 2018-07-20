//
//  FollowTableViewCell.m
//  jinshanStrmear
//
//  Created by lalala on 16/5/26.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "FollowTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation FollowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userImage.layer.cornerRadius=self.userImage.frame.size.width/2;
    self.userImage.layer.masksToBounds=YES;
    
    self.vipImage.layer.cornerRadius=self.vipImage.frame.size.width/2;
    self.vipImage.layer.masksToBounds=YES;
    
    self.liveView.layer.cornerRadius=self.liveView.frame.size.height/2;
    self.liveView.layer.masksToBounds=YES;
    
    self.livingImage.layer.cornerRadius= self.livingImage.height/2;
    self.livingImage.layer.masksToBounds= YES;
    //self.livingImage.contentMode=UIViewContentModeScaleAspectFill;
    
    self.morenImage.hidden=YES;
    self.morenLabel.hidden=YES;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)cellFuZhi:(MajFollowModel *)model
{
    [self.livePicture sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:model.user.avatar]];
    
    self.userName.text=model.user.nickName;
    
    if (ISNULL(model.cityName)||[model.cityName isEqualToString:@""]) {
        self.locationLabel.text= @"火星";

    }
    else{
        self.locationLabel.text= model.cityName;

    }
    
    //观看人数
    self.lookNumber.text = model.liveHitsStr;
    self.liveTime.text=model.startTimeStr;
    
    self.liveTitle.text=[NSString stringWithFormat:@"  %@",model.relationStar];
    
}


@end
