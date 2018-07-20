//
//  HotRecommendCollectionViewCell.m
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import "HotRecommendCollectionViewCell.h"

@implementation HotRecommendCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.adView.placeholderImage=IMAGE(@"shipinjiazai");
    self.adView.bannerImageViewContentMode=UIViewContentModeScaleAspectFit;
    self.adView.autoScrollTimeInterval=3;
    self.adView.currentPageDotColor = UIColorFromRGB(0xFF403C);
    self.adView.pageDotColor = UIColorFromRGB(0xFFFFFF);
    self.adView.backgroundColor = [UIColor whiteColor];
    self.adView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    self.adView .pageControlDotSize=CGSizeMake(1,1);


}

-(void)setDataArray:(NSArray *)dataArray{
    _dataArray=dataArray;
    NSMutableArray *picArray=@[].mutableCopy;
    
    for (AdvertiseModel *model in dataArray) {
        [picArray addObject:model.picUrl];
    }
    
    if (dataArray.count==1)
    {
        self.adView.autoScroll =NO;
    }
    else
    {
        self.adView.autoScroll = YES;
    }
    

    self.adView.imageURLStringsGroup=picArray;
    
    
    
}

@end
