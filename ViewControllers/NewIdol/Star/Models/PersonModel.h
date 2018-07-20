//
//  PersonModel.h
//  jinshanStrmear
//
//  Created by lalala on 2018/3/23.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "BaseModel.h"

@class PersonSignVideoModel;

@interface PersonModel : BaseModel
@property (nonatomic, copy) NSString *avatar;//用户头像
@property (nonatomic, assign) BOOL follow;//登录用户是否关注此明星
@property (nonatomic, copy) NSString *followNum;//被关注人数
@property (nonatomic, assign) BOOL mallFlag;// 影人主页 商城按钮 是否存在
@property (nonatomic, copy) NSString *name;//影人名称
@property (nonatomic, assign) NSInteger personId;//影人编号
@property (nonatomic, copy) NSString *personNameCn;//中文名
@property (nonatomic, copy) NSString *personNameEn;//英文名
@property (nonatomic, copy) NSString *picUrl;//封面图
@property (nonatomic, assign) BOOL sign;//今日登录用户是否针对此明星签到
@property (nonatomic, strong) NSMutableArray *userSignDateList;//用户针对次明星当月的签到记录
@property (nonatomic, strong) NSMutableArray *personPlotSignAfter;//签到后的剧情
@property (nonatomic, strong) NSMutableArray *personPlotSignBefore;//签到前的剧情
@property (nonatomic, strong) NSMutableArray *personSignPic;//签到明星图片
@property (nonatomic, strong) NSMutableArray *personSignPicHomePage;//主页明星图片
@property (nonatomic, strong) PersonSignVideoModel *personSignVideo;//签到明星视频呢
@property (nonatomic, strong) PersonSignVideoModel *personSignVideoHomePage;//主页明星视频
@property (nonatomic, copy) NSString *userSignDirections;//签到说明
@property (nonatomic, copy) NSString *roomId;//聊天室ID
@property (nonatomic, copy) NSString *teamId;//聊天室ID
@property (nonatomic, assign) NSInteger userId;//影人用户Id


@end

@interface PersonPlotModel : BaseModel
@property (nonatomic, copy) NSString *content;//剧情内容
@property (nonatomic, assign) NSInteger personId;//影人ID
@property (nonatomic, assign) NSInteger type;//类型 1-签到前  2-签到后
@end

@interface PersonSignPic : BaseModel
@property (nonatomic, assign) NSInteger personId;//影人ID
@property (nonatomic, copy) NSString *picUrl;//图片地址
@property (nonatomic, assign) NSInteger type;//类型 1-签到  2-主页
@end

@interface PersonSignVideoModel : BaseModel
@property (nonatomic, assign) NSInteger duration;//时长 秒
@property (nonatomic, assign) NSInteger personId;//影人ID
@property (nonatomic, copy) NSString *picUrl;//视频配图
@property (nonatomic, copy) NSString *playUrl;//视频地址
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, assign) NSInteger type;//类型 1-签到 2-主页
@end
