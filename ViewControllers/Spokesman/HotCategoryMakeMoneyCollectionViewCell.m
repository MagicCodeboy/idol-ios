//
//  HotCategoryMakeMoneyCollectionViewCell.m
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import "HotCategoryMakeMoneyCollectionViewCell.h"
#import "UIImageView+WebCache.h"
@implementation HotCategoryMakeMoneyCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(ShareVideoModelItem *)model{
    _model=model;
    NSLog(@"上皮你名字：%@",model.shortStore.name);
    if (model.shortStore.name.length > 20) {
        self.titleLabel.text = [model.shortStore.name substringToIndex:20];
    } else {
        self.titleLabel.text = model.shortStore.name;
    }
   
    self.subTitle.text=model.shortVideo.title;
    


    self.timeLabel.text=model.shortVideo.durationStr;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.shortVideo.picUrl] placeholderImage:IMAGE(@"shipinjiazai")];
    
    
}

@end
