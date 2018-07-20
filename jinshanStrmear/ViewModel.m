//
//  ViewModel.m
//  jinshanStrmear
//
//  Created by panhongliu on 16/6/16.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "ViewModel.h"
#import "SearchModel.h"
#import "MJExtension.h"
#import "NIMKit.h"
#import "NIMTool.h"
@implementation ViewModel

-(NSString *)getRequestUrl:(RequestUrl)type{
    
    NSString *URL = nil;
    
    switch (type) {
        case 100:
            URL=@"/usersignlog/selectRecord";
            break;
        case 101:
            URL=@"/usersignlog/save";
            break;
        case RedBageRanking:
            URL=@"/rest/livegroupredpackstat/list";
            break;
        case LiveShareLog:
            URL=@"/liveshare/log";
            break;
        case Sellerorders:
            URL=@"/mall/ordernew/sellerorders";
            break;
        case ShopInfomation:
            URL=@"/mall/store/data";
            break;
        case Sellercompletedorders:
            URL=@"/mall/ordernew/sellercompletedorders";
            break;
        case ShopOrderdetails:
            URL=@"/mall/ordernew/orderdetails";
            
            break;
        case Selectdelivery:
            URL=@"/mall/ordernew/selectdelivery";
            break;
         case  Suredelivery:
            URL=@"/mall/ordernew/suredelivery";
            break;
          case Selectexpressinfo:
            URL=@"/mall/expressinfo/selectexpressinfo";
            break;
         case AddBuyCar:
            URL=@"/mall/cart/addCart";
            break;
        case CountryList:
            URL=@"/country/list";
            break;
        case CountryArealist:
            URL=@"/country/arealist";
            break;
        case Verifycode:
            URL=@"/sms/verifycode";
            break;
        case UserReg:
            URL=@"/user/reg";
            break;
        case PersonList:
            URL=@"/person/list";
            break;
        case FollowPerson :
            URL=@"/follow/person";
            break;
        case FollowCancel:
            URL=@"/follow/cancel";
            break;
        case DynamicList:
            URL=@"/person/dynamic/list";
            break;
        case CommentList:
            URL=@"/comment/list";
            break;
        case CommentAdd:
            URL=@"/comment/add";
            break;
        case VideoList:
            URL=@"/person/video/list";
            break;
        case VideoAddviewnum:
            URL=@"/person/video/addviewnum";
            break;
            
        case PraisePoint:
            URL=@"/person/praise/point";
            break;
        case PraiseCancel:
            URL=@"/person/praise/cancel";
            break;
        case AactionWatch:
            URL=@"/action/watch";
            break;
        case OrderDepth:
            URL=@"/order/depth";
            break;
        case OrderDelegate:
            URL=@"/order/delegate";
            break;
            
        case UserWallet:
            URL=@"/user/wallet";
            break;
        case OrderSubmit:
            URL=@"/order/submit";
            break;
        case CancelSubmit:
            URL=@"/order/undo";
            break;
        case GoodsDetail:
            URL=@"/goods/detail";
            break;
        case ReportMessage:
            URL=@"/report/message";
            break;
            
            
            
        default:
            break;
    }
    return URL;
    
    
    
}

-(NSMutableArray *)dataArray
{
    
    if (!_dataArray) {
        _dataArray=@[].mutableCopy;
        
    }
    return _dataArray;
    
}
-(NSMutableArray *)rechangeListArray
{
    
    if (!_rechangeListArray) {
        _rechangeListArray=@[].mutableCopy;
        
    }
    return _rechangeListArray;
    
}


-(NSMutableArray *)flowArray
{
    
    if (!_flowArray) {
        _flowArray=@[].mutableCopy;
        
    }
    return _flowArray;
    
}
-(NSMutableArray *)personStarArray
{
    
    if (!_personStarArray) {
        _personStarArray=@[].mutableCopy;
        
    }
    return _personStarArray;
    
}

-(NSMutableArray *)otherStarJuminArray
{
    
    if (!_otherStarJuminArray) {
        _otherStarJuminArray=@[].mutableCopy;
        
    }
    return _otherStarJuminArray;
    
}

-(NSMutableArray *)otherLiveArray
{
    
    if (!_otherLiveArray) {
        _otherLiveArray=@[].mutableCopy;
        
    }
    return _otherLiveArray;
    
}


+(ViewModel *)shareViewModel
{
    static ViewModel *viewModel= nil;

    static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    
    viewModel=[[ViewModel alloc ]init];

  });
    return viewModel;
    

}



-(void)requestWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter requestType:(RequestType)type  succees:(Success)succeed fail:(failur)failed
{
    NSString *urlString=[self getRequestUrl:url];
    
    if (type==GET) {
        
        [CLNetworkingManager getNetworkRequestWithUrlString:urlString parameters:parmter isCache:NO succeed:^(id data) {
            
            succeed(data);
            
        } fail:^(NSString *error) {
            failed(error);
            
        } ];

        
    }
    else{
        [CLNetworkingManager postNetworkRequestWithUrlString:urlString parameters:parmter isCache:NO succeed:^(id data){
            succeed(data);
        } fail:^(NSString *error) {
            failed(error);
        }];
        
        
        
    }
    
    
    
}


-(void)requestAddFollowApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{

    NSLog(@"参数：%@",parmter);
    [CLNetworkingManager shareManager].hideBaseMBProgress = YES;
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/follow/add" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"%@",data);
        
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
}

-(void)requestdelegateFollowApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    NSLog(@"参数：%@",parmter);
    [CLNetworkingManager shareManager].hideBaseMBProgress = YES;
    [CLNetworkingManager deleteRequestWithUrlString:url parameters:parmter succeed:^(id data) {
        NSLog(@"%@",data);
        succeed(data);
        

    } fail:^(NSString *error) {
        failed(error);

    } ];
    
}
//我的星球
-(void)requestMyStarApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/star/mylist" parameters:parmter isCache:NO succeed:^(id data) {
        succeed(data);
 
    } fail:^(NSString *error) {
        failed(error);

    } ];
    
}
-(void)requestAttentionViewControllerApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager getNetworkRequestWithUrlString:url parameters:parmter isCache:NO succeed:^(id data) {
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);
        
    } ];
 
    
}
//非明星主页的星球列表
-(void)requestPersonStarListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/star/listbyuserid" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"指定人关注列表：%@",data);
        
        if (fresh) {
            [self.personStarArray removeAllObjects];
            
        }

        for (NSDictionary *dic in data[@"stars"]) {
            
            MyStar *model=[MyStar mj_objectWithKeyValues:dic];
            
            [self.personStarArray addObject:model];
        }
        
        succeed(self.personStarArray);
        
        
        
    } fail:^(NSString *error) {
        
    }];
    

    
}


//指定人的关注列表
-(void)requestIndexAttentionApiurl:(NSString *)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject)) succeed fail:(failur)failed
{
       [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/follow/userList" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"指定人关注列表：%@",data);
           
           if (fresh) {
               [self.flowArray removeAllObjects];
               
           }
           
           

        for (NSDictionary *dic in data[@"ufList"]) {
            
            UserFollow *model=[UserFollow mj_objectWithKeyValues:dic];
            
            [self.flowArray addObject:model];
        }
        
        succeed(self.flowArray);
        
        
        
    } fail:^(NSString *error) {
        
    }];
    

    
}
-(void)requestFansApiurl:(NSString *)url parmters:(NSDictionary *)parmter isfresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
      [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/fans/userList" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"粉丝：%@",data);
          if (fresh) {
              [self.dataArray removeAllObjects];
              
          }

        for (NSDictionary *dic in data[@"ufList"]) {
            
            UserFollow *model=[UserFollow mj_objectWithKeyValues:dic];

            [self.dataArray addObject:model];
        }
        
        succeed(self.dataArray);

        
    } fail:^(NSString *error) {
        
    }];
    
    
    
}

//我的回放列表
-(void)requestMyPlaybackrApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/userlive/playback" parameters:parmter isCache:NO succeed:^(id data) {
        succeed(data);
        
        
    } fail:^(NSString *error) {
        failed(error);
        
    } ];
}

-(void)requestDelMyPlaybackrParmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userlive/userdelstoplive" parameters:parmter isCache:NO succeed:^(id data) {
        succeed(data);
        
      
    } fail:^(NSString *error) {
        failed(error);
        
    } ];

    
}
//明星用户主页的直播信息
-(void)requestLivesApiurl:(NSString *)url parmters:(NSDictionary *)parmter isfresh:(BOOL )isfresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
       [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/lives" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"明星用户主页的直播信息：%@",data);
           
           if (isfresh) {
               [self.flowArray removeAllObjects];
 
           }
           
           

        for (NSDictionary *dic in data[@"userLives"]) {
            
            MajFollowModel *model=[MajFollowModel mj_objectWithKeyValues:dic];
            
                      [self.flowArray addObject:model];
        }
        
        succeed(self.flowArray);
        
        
        
    } fail:^(NSString *error) {
        
    }];
    
    
    
}




//第三方登录
-(void)requestThirdLoginApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    
    [CLNetworkingManager postNetworkRequestWithUrlString:url parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"第三封登录信息：%@",data);
        
        AccountModel *model=[AccountModel mj_objectWithKeyValues:data[@"user"]];
        
        
        [model write];
      succeed(data[@"firstReg"]);
        
        [[NIMTool sharedManager]loginWithId:model.userId andToken:model.roomToken andModel:model];
        
               
  
        NSLog(@"++++++++++++++++++++++++++++++++++++%@",[AccountModel read].roomToken);
        
        
    } fail:^(NSString *error) {
       
        failed(error);
        
    }];
    
    
    
}


-(void)requestBlackListApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/black/list" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"粉丝：%@",data);
        for (NSDictionary *dic in data[@"userBlacks"]) {
            
            SearchModel *model=[SearchModel mj_objectWithKeyValues:dic];
            
            [self.dataArray addObject:model];
        }
        
        succeed(self.dataArray);
        
        
    } fail:^(NSString *error) {
        
    }];
    
    
    
}

-(void)requestOtherStarDataApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed{
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/star/index" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"请求数据：%@",data);
        
     SearchModel*model=[SearchModel mj_objectWithKeyValues:data[@"star"]];
        
        succeed(model);
        
        
    } fail:^(NSString *error) {
        
    }];

    
}

//请求星球主页直播数据
-(void)requestOtherStarZhiBoApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)shuaxin succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/star/lives" parameters:parmter  isCache:NO succeed:^(id data) {
        
        NSLog(@"直播数据：%@",data);
        NSArray *array=data[@"userLives"];
        if (shuaxin==YES) {
            [self.otherLiveArray removeAllObjects];
            
        }
        
        if (array.count>0) {
            
            
            for (NSDictionary *dict in array)
            {
                MajFollowModel *model=[MajFollowModel mj_objectWithKeyValues:dict];
                [self.otherLiveArray addObject:model];
                //NSLog(@"居民页面的数据%@",data);
            }

            succeed(self.otherLiveArray);
            
        }
        else{

            succeed(self.otherLiveArray);
        }
        
    } fail:^(NSString *error) {
        
        failed(error);

    }];

}
//请求星球主页居民数据
-(void)requestOtherStarUserApiurl:(NSString *)url parmters:(NSDictionary *)parmter isreFresh:(BOOL)refresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/star/users" parameters:parmter  isCache:NO succeed:^(id data) {
        
        
        NSArray *array=data[@"starUsers"];
        
        if (refresh) {
            [self.otherStarJuminArray removeAllObjects];
            
        }
        if (array.count>0) {
            
            
            for (NSDictionary *dict in array)
            {
                SearchModel *model=[SearchModel mj_objectWithKeyValues:dict];
                NSLog(@"星球居民名字：%@",model.user.nickName);

                [self.otherStarJuminArray addObject:model];
                //NSLog(@"居民页面的数据%@",data);
            }
            NSLog(@"星球居民：%@",self.otherStarJuminArray);

            succeed(self.otherStarJuminArray);
            
        }
        else
            succeed(self.otherStarJuminArray);

        
    } fail:^(NSString *error) {
        failed(error);

        
    }];

    
}
-(void)requestJoinStarApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/star/join" parameters:parmter isCache:NO succeed:^(id data) {
               succeed(data[@"message"]);
        
        
        
           } fail:^(NSString *error) {
               failed(error);

    }];
}
-(void)requestOutStarApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/star/out" parameters:parmter isCache:NO succeed:^(id data) {
       
        succeed(data[@"message"]);

    } fail:^(NSString *error) {
        failed(error);
 
    }];

    
}

//获取用户推送状态
-(void)restUserNoticerApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/user/notice" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"推送状态：%@",data);
        
        NoticModel *model=[NoticModel mj_objectWithKeyValues:data[@"userNotice"]];
                           
        succeed(model);
        
    } fail:^(NSString *error) {
        failed(error);
  
    }];
 
}

//设置用户推送状态
-(void)restUserUpdateNoticerApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/user/updatenotice" parameters:parmter isCache:NO succeed:^(id data) {
        
        
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);

    }];
    
}

-(void)restMessageListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isRefresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
//    MessageModel
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/msg/list" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"系统消息%@",data);
        
        if (isRefresh==YES) {
            [self.dataArray removeAllObjects];
            
        }
        
        for (NSDictionary *dic in data[@"userMsg"]) {
            
            SystemMessageModel *model=[SystemMessageModel mj_objectWithKeyValues:dic[@"msg"]];
            
            [self.dataArray  addObject:model];
            
        }
        
        succeed(self.dataArray);
        
    } fail:^(NSString *error) {
        failed(error);

    }];

    
}
-(void)restUserBandinglistApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/user/bindinglist" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"账户安全%@",data);

        AccountSafe *model=[AccountSafe mj_objectWithKeyValues:data];
        
        
        succeed(model);
        
    } fail:^(NSString *error) {
        failed(error);
 
    }];
    
}

-(void)restUserBandingReglistApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/user/unbundling" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"账户安全%@",data);
        
//        AccountSafe *model=[AccountSafe mj_objectWithKeyValues:data];
        
        
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);

    }];
    
}



/**
 *  返回体力充值列表
 *
 */
-(void)restUserRechargesetupApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/userrecharge/setup" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"充值列表%@",data);

        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
}
//掌声转星币
-(void)restUserRechargePayApplauseurl:(NSString *)url parmeters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed{
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userrecharge/payApplause" parameters:parmter isCache:NO succeed:^(id data){
        NSLog(@"掌声转星币%@",data);
        succeed(data);
    } fail:^(NSString *error) {
        failed(error);
    }];
}

-(void)restUserRechargeListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isShuaXin succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/userrecharge/list" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"2333333333323%@",data);
        
        if (isShuaXin==YES) {
            [self.rechangeListArray removeAllObjects];
            
        }
        
        for (NSDictionary *dic in data[@"userRechargeRecords"]) {
            
            RechangeAboutModel *model=[RechangeAboutModel mj_objectWithKeyValues:dic];
            
            [self.rechangeListArray addObject:model];

        }
    
        succeed(self.rechangeListArray);
        
    } fail:^(NSString *error) {
        failed(error);
 
    }];
}
//GET

-(void)restUserTiXianListApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isShuaXin succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/cash/list" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"体现记录%@",data);
        
        if (isShuaXin==YES) {
            [self.rechangeListArray removeAllObjects];
            
        }
        
        for (NSDictionary *dic in data[@"userCashRecords"]) {
            
            RechangeAboutModel *model=[RechangeAboutModel mj_objectWithKeyValues:dic];
            
            [self.rechangeListArray addObject:model];
            
        }
        
        succeed(self.rechangeListArray);
        
    } fail:^(NSString *error) {
        failed(error);
  
    }];
}


/**
 *  体力和掌声信息
 *
 */
-(void)restUserOtherInfoApiurl:(NSString *)url parmters:(NSDictionary *)parmter isShuaXin:(BOOL)isRefresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/otherinfo" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"体力掌声%@",data);
        
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);

    }];

    
}


//用户体现
-(void)restUserTiXianApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/cash/cash" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"体现%@",data);
        
        //        AccountSafe *model=[AccountSafe mj_objectWithKeyValues:data];
        
        
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);
  
    }];
    
}

-(void)restUserRechargeApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userrecharge/recharge" parameters:parmter isCache:NO succeed:^(id data) {
        NSLog(@"充值%@",data);
        
        //        AccountSafe *model=[AccountSafe mj_objectWithKeyValues:data];
        
        
        succeed(data);
        
    } fail:^(NSString *error) {
        failed(error);
  
    }];

}

-(void)restAppByVerifyApiurl:(NSString *)url parmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    NSLog(@"充值验证");
 
    
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userrecharge/appleByVerify" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"充值验证结果%@",data);

        succeed(data);
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];

    
}
-(void)requestPraiseWithparmters:(NSDictionary *)parmter succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager shareManager].hideBaseMBProgress=YES;
    [CLNetworkingManager shareManager].isHideErrorTip=YES;
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/userlive/praise" parameters:parmter isCache:NO succeed:^(id data) {
        
        succeed(data);
        
        NSLog(@"点赞%@",data);
        
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];

    
}


-(void)requestSortListWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/livesend/sortlist" parameters:parmter isCache:NO succeed:^(id data) {
        
        
        if (fresh) {
            [self.dataArray removeAllObjects];
            
        }
        
        for (NSDictionary *dic in data[@"userSendStats"]) {
            
            FansListSort *model=[FansListSort mj_objectWithKeyValues:dic];
            
            [self.dataArray addObject:model];
            
        }
        NSLog(@"粉丝榜：%@",self.dataArray);

        succeed(self.dataArray);

        
    } fail:^(NSString *error) {
        failed(error);
        
    }];

    
    
}

-(void)requestWXPayWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/mall/order/pay" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"订单支付：%@",data);
        
        succeed(data);
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];

}

-(void)requestNewPayWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/mall/ordernew/pay" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"订单支付：%@",data);
        
        succeed(data);
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];
}

-(void)requestWXPayResultQueryWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userrecharge/orderquery" parameters:parmter isCache:NO succeed:^(id data) {
        
        NSLog(@"订单验证：%@",data);
        
        succeed(data);
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];
    

    
}

-(void)requestUserIdListWithparmters:(NSDictionary *)parmter isFresh:(BOOL)fresh succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/follow/userIdList" parameters:parmter isCache:NO succeed:^(id data) {
      
        succeed(data[@"userIds"]);
        
        
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];
    

    
}


-(void)requestUserIdIsFollowWithparmters:(NSString *)userID  succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    
    [CLNetworkingManager shareManager].isHideErrorTip=YES;
    [CLNetworkingManager shareManager].hideBaseMBProgress=YES;
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/follow/userIdIsFollow" parameters:@{@"userId":userID} isCache:NO succeed:^(id data) {
        NSLog(@"%@",data);
        
        succeed(data);
        
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];
    
    
    

    
}


-(void)requestUserLevelMessageWithparmters:(NSString *)userID  succees:(void (^)(id responseProject))succeed fail:(failur)failed
{
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/userLevelInfo" parameters:@{@"userId":userID} isCache:NO succeed:^(id data) {
   

        succeed([UserLevel mj_objectWithKeyValues:data]);
        
        
    } fail:^(NSString *error) {
        
        failed(error);
        
    }];
    

}


-(void)restFollowUserShareApiurl:(NSString *)url parmters:(NSDictionary *)parmter isRefresh:(BOOL)isRefresh succees:(void (^)(id responseProject,LiveShare  *shareModel,RecruitUserExtend *extendModel))succeed fail:(failur)failed

{
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/followusershare/list" parameters:parmter isCache:NO succeed:^(id data) {
        
        
        if (isRefresh==YES) {
            [self.dataArray removeAllObjects];
            
        }
        LiveShare *liveSharModel=[LiveShare mj_objectWithKeyValues:data[@"liveShare"]];
        
        RecruitUserExtend *extendModle=[RecruitUserExtend mj_objectWithKeyValues:data[@"userExtend"]];
                                        
        
        for (NSDictionary *dic in data[@"userSendStats"]) {
            
            UserSendStatsModel *model=[UserSendStatsModel mj_objectWithKeyValues:dic];
            
            [self.dataArray  addObject:model];
            
        }
        
        
        
        succeed(self.dataArray,liveSharModel,extendModle);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
}


-(void)requestRedBagRankingWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
        if (fresh) {
            [self.dataArray removeAllObjects];
            
        }
        
        for (NSDictionary *dic in responseProject[@"liveGroupRedPackStats"]) {
            
            FansListSort *model=[FansListSort mj_objectWithKeyValues:dic];
            
            [self.dataArray addObject:model];
            
        }
        NSLog(@"红包排行榜：%@",self.dataArray);
        
        succeed(self.dataArray);
    } fail:^(NSString *error) {
        failed(error);

    }];
    
    
    
    
}


-(void)requestShareLogIsTheart:(BOOL )isTheater liveId:(NSString *)liveID shareTag:(NSInteger)tag succees:(Success)succeed fail:(failur)failed

{
    NSInteger umengType=0;
    
    NSString *typeString=nil;
    switch (tag) {
        case 600:
            typeString =@"朋友圈";
            umengType=1;
            
            break;
        case 601:
            typeString =@"微信";
            umengType=2;
            
            break;
        case 602:
            typeString =@"微博";
            umengType=3;
            
            break;
        case 603:
            typeString =@"QQ";
            umengType=4;
            
            break;
        case 604:
            typeString =@"空间";
            umengType=5;
            
            break;
        default:
            typeString =@"未知分享类型";
            
            break;
    }
    
    NSDictionary *dic=@{@"relatedType": isTheater?@"2":@"1",@"relatedId":liveID,@"sharePlatformType":[NSString stringWithFormat:@"%ld",(long)umengType]};
   
            

    
    
    [CLNetworkingManager shareManager].isHideErrorTip=YES;
    [CLNetworkingManager shareManager].hideBaseMBProgress=YES;

    
    [self requestWithUrlType:LiveShareLog parmters:dic requestType:0 succees:^(id responseProject) {
        
        succeed(responseProject);
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}



-(void)requestSellerordersWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
       
        succeed(responseProject);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}

-(void)requestShopInfomationWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
        
        if (fresh) {
            [self.dataArray removeAllObjects];
            
        }
        
        ShopModel *model=[ShopModel mj_objectWithKeyValues:responseProject];
        [self.dataArray addObject:model];

        
        
        succeed(self.dataArray);
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}


-(void)requestShopOrderDetailInfomationWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
        
     
        
        ShopGoodsOrder *model=[ShopGoodsOrder mj_objectWithKeyValues:responseProject[@"goodsOrder"]];
        if (ISNULL(model.orderId)) {
            
        }else{
        succeed(model);

        }
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}


-(void)requestSelectdeliveryWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
        
        if (fresh) {
            [self.dataArray removeAllObjects];
            
        }
        
        DeliveryResultModel *model=[DeliveryResultModel mj_objectWithKeyValues:responseProject];
        [self.dataArray addObject:model];
        succeed(self.dataArray);
        
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}
//确认发货
-(void)requestSuredeliveryWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:1 succees:^(id responseProject) {
      
        succeed(responseProject);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}

-(void)requestSelectexpressinfoWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter isFresh:(BOOL)fresh  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
        SelectexpressinfoModel *model=[SelectexpressinfoModel mj_objectWithKeyValues:responseProject];
        
        succeed(model);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}



//通用型POST请求
-(void)postRequestWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:1 succees:^(id responseProject) {
        
        succeed(responseProject);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}
-(void)getRequestWithUrlType:(RequestUrl)url parmters:(NSDictionary *)parmter  succees:(Success)succeed fail:(failur)failed

{
    
    
    [self requestWithUrlType:url parmters:parmter requestType:0 succees:^(id responseProject) {
        
        succeed(responseProject);
        
    } fail:^(NSString *error) {
        failed(error);
        
    }];
    
    
    
    
}


@end
