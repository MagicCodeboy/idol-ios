//
//  ViewModel.h
//  jinshanStrmear
//
//  Created by panhongliu on 16/6/16.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLNetworkingManager.h"
#import "MajorModel.h"
#import "AccountModel.h"
#import "ShopModel.h"

typedef void (^Success)( id responseProject);
typedef void (^failur)(NSString *error);

typedef NS_ENUM(NSInteger ,RequestUrl){
    //签到记录查询
    UserSignSelectRecord=100,
    UsersignlogSave=101,
    RedBageRanking=102,//红包排行
    LiveShareLog=103,//分享记录
    Sellerorders=104,//商家列表进行中
    Sellercompletedorders=106,//订单列表已完成
    ShopInfomation=105,//店铺信息
    ShopOrderdetails =107,//订单详情
    Selectdelivery=108,//我要发货
    Suredelivery=109,//确认发货
    Selectexpressinfo=110,//查询物流信息
    AddBuyCar=111,//添加购物车
    
    CountryArealist=121,//选择地区
    CountryList=120,//选择国家
    Verifycode=122,//验证验证码
    UserReg=123,//注册
    PersonList=124,//明星列表
    FollowPerson=125,//加关注
    FollowCancel=126,//取消关注
    DynamicList=127,//动态列表
    CommentList=128,//评论列表
    CommentAdd=129,//发表评论
    
    VideoList=130,//获取视频列表
    VideoAddviewnum=133,//视频点击量
    PraisePoint=131,//点赞
    PraiseCancel=132,//取消点赞
    AactionWatch=134,//观看时长记录
    OrderDepth=135,//深度
    OrderDelegate=136,//委托
    UserWallet =137,//钱包信息
    OrderSubmit=138,//提交订单
    CancelSubmit=139,//撤销订单
    GoodsDetail = 140,//商品详情
    ReportMessage = 141,//举报

};

typedef NS_ENUM(NSInteger ,RequestType){
    //签到记录查询
    GET=0,
    POST=1,
    
    
};

@interface ViewModel : NSObject

@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *Token;

@property(nonatomic,strong)NSMutableArray *dataArray;
//指定人关注列表
@property(nonatomic,strong)NSMutableArray *flowArray;
//个人主页星球列表
@property(nonatomic,strong)NSMutableArray *personStarArray;
//他人星球主页居民数据
@property(nonatomic,strong)NSMutableArray *otherStarJuminArray;
@property(nonatomic,strong)NSMutableArray *otherLiveArray;

/**
 *  充值记录
 */

@property(nonatomic,strong)NSMutableArray *rechangeListArray;

@property(nonatomic,copy)Success succeed;
@property(nonatomic,copy)failur fail;


+(ViewModel *)shareViewModel;
//通用型POST请求
-(void)postRequestWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter succees:(Success)succeed fail:(failur)failed;
-(void)getRequestWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter  succees:(Success)succeed fail:(failur)failed;

//首页栏目标题
-(void)requestWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter requestType:(RequestType)type  succees:(Success)succeed fail:(failur)failed;

//加关注
-(void)requestAddFollowApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//取消关注
-(void)requestdelegateFollowApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//我的星球
-(void)requestMyStarApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//我的关注列表
-(void)requestAttentionViewControllerApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//返回指定用户关注列表  个人星球主页关注列表
-(void)requestIndexAttentionApiurl:(NSString *)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject)) succeed fail:(failur)failed;
//非明星个人星球主页关注列表
-(void)requestPersonStarListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//粉丝列表
-(void)requestFansApiurl:(NSString *)url parmters:(NSDictionary *)parmter isfresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//我的回放列表
-(void)requestMyPlaybackrApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;


//删除我的回放
-(void)requestDelMyPlaybackrParmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//明星用户主页的直播信息
-(void)requestLivesApiurl:(NSString *)url parmters:(NSDictionary *)parmter isfresh:(BOOL )isfresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;


//第三方登录
-(void)requestThirdLoginApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//请求黑名单的数据
-(void)requestBlackListApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//请求他人星球主页头部数据
-(void)requestOtherStarDataApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//请求星球主页直播数据
-(void)requestOtherStarZhiBoApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)shuaxin succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//请求星球主页居民数据
-(void)requestOtherStarUserApiurl:(NSString *)url parmters:(NSDictionary *)parmter isreFresh:(BOOL)refresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//加入星球
-(void)requestJoinStarApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//退出星球
-(void)requestOutStarApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
//获取用户推送状态
-(void)restUserNoticerApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//设置用户推送状态
-(void)restUserUpdateNoticerApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
/**
 * 获取系统消息 跟通知无关
 */
-(void)restMessageListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isRefresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;


/**
 * 账户与安全 返回第三方绑定列表
 */
-(void)restUserBandinglistApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
/**
 *  第三方回调注册
 *
 */
-(void)restUserBandingReglistApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
/**
 *  返回体力充值列表
 *
 */
-(void)restUserRechargesetupApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  充值记录
 *
 */
-(void)restUserRechargeListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isShuaXin succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  提现记录
 *
 */
-(void)restUserTiXianListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isShuaXin succees:(void (^)(id responseProject))succeed fail:(failur)failed;


/**
 *  体力和掌声信息
 *
 */
-(void)restUserOtherInfoApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isRefresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 * 掌声转星币
 */
-(void)restUserRechargePayApplauseurl:(NSString *)url parmeters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  用户体现
 *
 */
-(void)restUserTiXianApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  @author 王森, 16-07-25 12:07:42
 *
 *  苹果内购用户充值
 */
-(void)restUserRechargeApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  @author 王森, 16-07-25 12:07:42
 *
 *  苹果支付提交

 */
-(void)restAppByVerifyApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
/**
 *  @author 王森, 16-08-24 16:08:52
 *
 *  点赞接口
 *
 *  @param url     地址
 *  @param parmter 参数
 *  @param succeed 成功
 *  @param failed  失败
 */
-(void)requestPraiseWithparmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed;
/**
 *  @author 王森, 16-08-24 16:08:52
 *
 *  送礼排行
 *
 *  @param url     地址
 *  @param parmter 参数
 *  @param succeed 成功
 *  @param failed  失败
 */
-(void)requestSortListWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;
/**
 *  @author 王森, 16-09-13 17:09:31
 *
 *  微信支付订单支付
 *
 *  @param parmter 参数
 *  @param fresh   是否刷新
 *  @param succeed 成功
 *  @param failed  失败
 
 */
-(void)requestWXPayWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;


//新版支付

-(void)requestNewPayWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;


/**
 *  @author 王森, 16-09-13 17:09:31
 *
 *  微信支付订验证
 *
 *  @param parmter 参数
 *  @param fresh   是否刷新
 *  @param succeed 成功
 *  @param failed  失败
 
 */
-(void)requestWXPayResultQueryWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  @author 王森, 16-09-13 17:09:31
 *
 *  返回关注列表ID
 *
 *  @param parmter 参数
 *  @param fresh   是否刷新
 *  @param succeed 成功
 *  @param failed  失败
 
 */
-(void)requestUserIdListWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed;


/**
 *  @author 王森, 16-09-13 17:09:31
 *
 *  是否关注了用户
 *
 *  @param parmter 参数
 *  @param fresh   是否刷新
 *  @param succeed 成功
 *  @param failed  失败
 
 */
-(void)requestUserIdIsFollowWithparmters:(NSString *)userID  succees:(void (^)(id responseProject))succeed fail:(failur)failed;

/**
 *  @author 王森, 16-09-13 17:09:31
 *
 *  用户等级信息
 *
 *  @param parmter 参数
 *  @param fresh   是否刷新
 *  @param succeed 成功
 *  @param failed  失败
 
 */
-(void)requestUserLevelMessageWithparmters:(NSString *)userID  succees:(void (^)(id responseProject))succeed fail:(failur)failed;

//招募的粉丝及贡献

-(void)restFollowUserShareApiurl:(NSString *)url parmters:(NSDictionary *)parmter isRefresh:(BOOL)isRefresh succees:(void (^)(id responseProject,LiveShare  *shareModel,RecruitUserExtend *extendModel))succeed fail:(failur)failed;

//红包排行榜

-(void)requestRedBagRankingWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;

-(void)requestShareLogIsTheart:(BOOL )isTheater liveId:(NSString *)liveID shareTag:(NSInteger)tag succees:(Success)succeed fail:(failur)failed;

//商家列表进行中 和已完成
-(void)requestSellerordersWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;
//店铺信息
-(void)requestShopInfomationWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;
//商品详情
-(void)requestShopOrderDetailInfomationWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;
//我要发货
-(void)requestSelectdeliveryWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;

//确认发货
-(void)requestSuredeliveryWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;
//查询物流信息
-(void)requestSelectexpressinfoWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed;










@end
