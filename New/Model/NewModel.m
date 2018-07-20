//
//  NewModel.m
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/24.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "NewModel.h"

@implementation NewModel

@end

@implementation CountryModel

@end

@implementation StarListModel
+ (StarListModel *)shareModel {
    static dispatch_once_t once;
    static StarListModel * instance;
    dispatch_once(&once, ^{
        instance = [StarListModel new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _followList = [[NSMutableArray alloc] init];
        
    }
    return self;
}
@end

@implementation DynamicItemModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"content" : @"DynamicContentModel"
             };
}
@end


@implementation DynamicContentModel

@end
@implementation VideoItemModel

@end

@implementation PhotoItem

@end
@implementation BuyDealItemsMdoel

@end

@implementation DepthResult
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"buyDepthItems" : @"BuyDealItemsMdoel",
             @"sellDepthItems" : @"BuyDealItemsMdoel"
             };
}

@end
@implementation UserWalletMdoel

@end







