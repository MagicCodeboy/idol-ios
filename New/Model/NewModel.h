//
//  NewModel.h
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/24.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "BaseModel.h"
#import "MJExtension.h"

@interface NewModel : BaseModel

@end


@interface CountryModel : BaseModel

@property(nonatomic,copy)NSString *areaCode;
@property(nonatomic,copy)NSString *firstLetter;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *areaId;


@end

@interface StarListModel : BaseModel

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *personId;
@property(nonatomic,copy)NSString *picUrl;
@property(nonatomic,copy)NSString *avatar;
@property(nonatomic,copy)NSString *followNum;
@property(nonatomic,assign)BOOL follow;
@property(nonatomic,copy)NSString *teamId;


@property(nonatomic,copy)NSMutableArray *followList;
+(StarListModel *)shareModel;


@end

@interface DynamicItemModel : BaseModel
@property(nonatomic,copy)NSArray *content;
@property(nonatomic,copy)NSString * commentNum;
@property(nonatomic,copy)NSString *dynamicSource;
@property(nonatomic,assign)BOOL praise;
@property(nonatomic,copy)NSString * praiseNum;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *shareNum;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *personPicUrl;
@property(nonatomic,copy)NSString *dynamicId;


@property(nonatomic,copy)NSString *personId;




@end


@interface DynamicContentModel : BaseModel
//orderNo (integer, optional): 排序号 ,
//type (integer, optional): 类型 1-图片 2-视频 ,
//url (string, optional): 图片或者视频地址
@property(nonatomic,copy)NSString *orderNo;
@property(nonatomic,assign)NSInteger type;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *videoPic;
@property(nonatomic,copy)NSString *bigUrl;


@end


@interface VideoItemModel : BaseModel

@property(nonatomic,assign)NSInteger fee;
@property(nonatomic,copy)NSString *picUrl;
@property(nonatomic,copy)NSString *playUrl;
@property(nonatomic,assign)BOOL praise;
@property(nonatomic,copy)NSString * praiseNum;
@property(nonatomic,copy)NSString *shareNum;
@property(nonatomic,copy)NSString *summary;
@property(nonatomic,copy)NSString *videoId;
@property(nonatomic,copy)NSString *viewNum;
@property(nonatomic,assign)NSInteger watchTime;
@property(nonatomic,copy)NSString *personName;


@end

@interface PhotoItem : NSObject
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *thumbPath;
@property(nonatomic,strong)NSString *name;


@end
@interface BuyDealItemsMdoel : NSObject
@property(nonatomic,strong)NSString *price;
@property(nonatomic,strong)NSString *tradeNumStr;
@property(nonatomic,strong)NSString *time;
@property(nonatomic,assign)NSInteger direction;//方向 1-买入 2-卖出 ,
@property(nonatomic,assign)NSInteger status;//1-交易中 2-交易完成(不可撤销) ,
@property(nonatomic,assign)NSInteger orderId; // 订单Id ,
@property(nonatomic,strong)NSString *shortName;//币简称
@property(nonatomic,copy)NSString * num; //购买的数量

@property(nonatomic,assign)long long  totalNum;//总量
@property(nonatomic,assign)long long tradeNum; // 交易量 ,
@property(nonatomic,copy)NSString * totalNumStr; //总数量



@end

@interface DepthResult : NSObject
@property(nonatomic,strong)NSArray *buyDepthItems;
@property(nonatomic,strong)NSArray *sellDepthItems;
@property(nonatomic,assign)NSInteger type;//判断涨跌 0-涨 1-跌
@property(nonatomic,strong)NSString *nowPrice;
@property(nonatomic,assign)long price;



@end

@interface UserWalletMdoel : NSObject
@property(nonatomic,assign)NSInteger personCurrencyId;//明星代币Id ,
@property(nonatomic,assign)long personCurrencyNum;
@property(nonatomic,strong)NSString *personCurrencyNumStr;//  明星代币数量(字符串) ,
@property(nonatomic,assign)long idolNum;
@property(nonatomic,strong)NSString *idolNumStr;//  IDOL币数量 ,,
@property(nonatomic,assign)long price;
@property(nonatomic,strong)NSString *nowPrice;

@end


