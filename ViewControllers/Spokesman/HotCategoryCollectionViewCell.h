//
//  HotCategoryCollectionViewCell.h
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorModel.h"
#import "ShowVideoModel.h"

typedef NS_ENUM(NSUInteger ,MenuTypes) {
    SHAREMAKEMONEYS=1,//分享赚钱
    SPOKESNMANVCS=2,//代言人
};
//g) ShareMoneyDataModel *shareMoneyData;
//@property(nonatomic,strong) RewardAgentDataModel *rewardAgentData;
//@property(nonatomic,strong) ShareStoreDataModel

@interface HotCategoryCollectionViewCell : UICollectionViewCell <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) void(^selectRow)(id model);

@property (strong, nonatomic) void(^didselectTitle)(id model);

@property (strong, nonatomic)UICollectionViewFlowLayout *flowLayout;
@property (assign, nonatomic)MenuTypes type;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property(nonatomic,strong)NSArray *dataArray;


-(void)initCollectionviewWithType:(MenuTypes)type;

@end
