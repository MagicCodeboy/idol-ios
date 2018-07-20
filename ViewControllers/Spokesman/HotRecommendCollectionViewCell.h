//
//  HotRecommendCollectionViewCell.h
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDCycleScrollView.h"
#import "MajorModel.h"

@interface HotRecommendCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet SDCycleScrollView *adView;
@property(nonatomic,strong)NSArray *dataArray;



@end
