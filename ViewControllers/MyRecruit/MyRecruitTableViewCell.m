//
//  MyRecruitTableViewCell.m
//  jinshanStrmear
//
//  Created by panhongliu on 2016/11/29.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "MyRecruitTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation MyRecruitTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellFuzhiWithModel:(UserSendStatsModel *)model
{
    self.userImageView.layer.cornerRadius= self.userImageView.height/2;
    self.userImageView.layer.masksToBounds=YES;
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:model.user.avatar] placeholderImage:IMAGE(@"") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
        self.userImageView.image=IMAGE(@"morentouxiang120px");
            
        }
    }];
    self.zhangShengLabel.text=[NSString stringWithFormat:@"掌声%@",model.applauseNum];
    self.nameLabel.text=model.user.nickName;
    
    
    
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
