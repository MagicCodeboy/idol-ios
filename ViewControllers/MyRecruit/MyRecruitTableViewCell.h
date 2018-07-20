//
//  MyRecruitTableViewCell.h
//  jinshanStrmear
//
//  Created by panhongliu on 2016/11/29.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorModel.h"
@interface MyRecruitTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftContant;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhangShengLabel;
@property (weak, nonatomic) IBOutlet UIImageView *xuHaoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

-(void)cellFuzhiWithModel:(UserSendStatsModel *)model;

@end
