//
//  HotCategoryMakeMoneyCollectionViewCell.h
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowVideoModel.h"
@interface HotCategoryMakeMoneyCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property(nonatomic,strong)ShareVideoModelItem *model;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
