//
//  SpokesmanViewController.h
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

typedef NS_ENUM(NSUInteger ,MenuType) {
    HOTRECOMMEND=0,//新版热门推荐
    SHAREMAKEMONEY=1,//分享赚钱
    SPOKESNMANVC=2,//代言人
    REWARD=3,//悬赏代言(已经不要了)
    TOPGOODS=4,//全球尖货
    
};
#import "UIBaseViewController.h"

@interface SpokesmanViewController : UIBaseViewController

@property(assign,nonatomic)MenuType type;
-(void)loadDataWithCateID:(NSString *)cateId isFromBack:(BOOL)isfromback;
//推荐点击更多滑动至某个栏目 cateId栏目ID
@property (strong, nonatomic) void(^selectCateMenu)(NSInteger cateId);


@end
