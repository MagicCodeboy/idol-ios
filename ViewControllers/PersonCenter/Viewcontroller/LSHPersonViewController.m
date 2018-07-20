  //
//  LSHPersonViewController.m
//  jinshanStrmear
//
//  Created by lalala on 16/6/4.
//  Copyright © 2016年 王森. All rights reserved.
//

#define  FOCUSCELL @"focus"
#define  FanseCel @"fabs"
#import "LSHPersonViewController.h"
#import "CommonDefin.h"
#import "UserModel.h"
#import "UIImage+Blur.h"
#import "OtherUserHeadView.h"
#import "FollowTableViewCell.h"
#import "PersonLiveCell.h"
#import "AppDelegate.h"
#import "MJExtension.h"
#import "CLNetworkingManager.h"
#import "UIImageView+WebCache.h"
#import "UIButton+Block.h"
#import "LaheiView.h"
#import "UIView+Toast.h"
#import "ViewModel.h"
#import "WSPersonStarListTableViewCell.h"
#import "SDWebImageManager.h"
#import "UIView+BlockGesture.h"
#import "FansListViewController.h"
#import "AccountModel.h"
#import "EmptyContantTableViewCell.h"

#import "BaseWebViewViewController.h"

#import "KLCPopup.h"

#import "QJXLivePageHelper.h"
#import "PXYAnchorController.h"
#import "PXYViewersViewController.h"
#import "UIButton+EnlargeEdge.h"

#import "ChartWithOtherMan.h"
#import "PersonTableHeaderView.h"
#import "WSSetMenuTableViewCell.h"
#import "MJRefresh.h"
#import "WSAttentionViewController.h"
#import "WSFansViewController.h"
#import "OtherUserToolBarView.h"
#import "UIImage+Blur.h"
#import "ShopInfomationTableViewCell.h"
#import "ShopQRcodeViewController.h"

static  CGFloat const tableHeaderViewHeight=210;
static  CGFloat const tableSection0HeaderHeight=52;



typedef enum : NSUInteger {
    ONESTYPE=0,
    TWOSTYPE,
    THREESTYPE,
} MyCellType;

static  NSString * const kSwitchLiveAlertHint = @"您正在直播中，请结束当前直播进行观看";

@interface LSHPersonViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate>
{
    NSInteger selectIndex;
    
       BOOL isFocus;//是否关注的判断值
    BOOL isFirstReload;//是否第一次刷新

    OtherUserToolBarView *toolBarView;
    
    CGFloat myOffeset;
    
}
@property(nonatomic,strong)PersonTableHeaderView * personTableHeadView;


@property(nonatomic,strong)ViewModel *requestModel;
@property(nonatomic,strong)ShopModel *shopModel;


@property(nonatomic,strong)UIButton *livingBtn;//正在直播的按钮的按钮(判断用户是否正在直播，如果是，显示，否则隐藏)
@property(nonatomic,strong)UIButton *backView;
@property(nonatomic,strong)UIView *navBarBottomImageView;
@property(nonatomic,strong)UILabel *userTitlelabel;//用于上滑的时候显示用户的名字

@property(nonatomic,assign)BOOL gag;//是否禁言了
@property(nonatomic,assign)BOOL follow;//是否关注了
@property(nonatomic,assign)BOOL black;//是否拉黑了
@property(nonatomic,assign)BOOL living;//是否正在直播
@property(nonatomic,assign)MyCellType cellState;
@property(nonatomic,assign) __block int  fansIndex;

@property(nonatomic,strong) UIImageView * bigImageView;

@property(nonatomic,strong) KLCPopup * popup;


@property(nonatomic,strong)NSMutableArray *personArray;
@property(nonatomic,strong)NSArray *userinfoTitleArray;
@property(nonatomic,strong)NSArray *userinfoDetailArray;
@property(nonatomic,strong)NSArray *shopInfomationTitleArray;
@property(nonatomic,strong)NSArray *shopInfomationContenteArray;


//关注数组
@property(nonatomic,strong)NSArray *followArray;
//星球数组
@property(nonatomic,strong)NSArray *liveArray;//直播的数据存放的数组

@property(nonatomic,strong)NSArray *stararray;

@property(nonatomic,strong)OtherUserHeadView *tableHeadView;

@property(nonatomic,strong)UIButton *tempBtn;

@property(nonatomic,strong)LaheiView *laheiView;//点击之后弹出提示框举报还是拉黑

@property(nonatomic,strong)UIButton* leftButton;//左边的按钮

@property(nonatomic,strong)UIButton *rightButton;//右边的按钮

@property(nonatomic,strong)SearchModel *model;

@property(nonatomic,copy)NSString *myUserID;//传递过来的用户的ID

@property(nonatomic,copy)NSString *liveId;//获得的直播的ID 从接口请求的直播ID赋值给此全局变量

@property(nonatomic,copy)NSString *bgPicUrl;//用户的头像的底部的背景图

@property(nonatomic,strong)UserModel *userModel;//全局的用户的数据的Model

@property(nonatomic,strong)NSMutableArray *dataSource;//用来存放数据的类型
@property(nonatomic,strong)NSMutableArray *applauseListArray;//贡献榜


@property(nonatomic,strong)UserBalanceModel *balabceModel;//用户的掌声的数据模型

@property(nonatomic,strong)NSMutableArray *balanceArray;//用户掌声的数据存放的数组

@end

@implementation LSHPersonViewController

//懒加载数组 用到的时候在进行初始化数组
-(NSMutableArray *)balanceArray{
    if (_balanceArray==nil){
        _balanceArray=[NSMutableArray array];
    }
    return _balanceArray;
}
-(NSMutableArray *)dataSource{
    if (_dataSource==nil){
        _dataSource=[NSMutableArray array];
    }
    return _dataSource;
}

-(NSMutableArray *)applauseListArray
{
    if (!_applauseListArray) {
        _applauseListArray=@[].mutableCopy;
        
    }
    return _applauseListArray;
    
    
}
-(instancetype)initWithString:(NSString *)myuserId{
    if (self==[super init]){
        self.myUserID=myuserId;
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self hiddenTabBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followLiveEnd:) name:@"followLivingEnd" object:nil];
}
-(void)followLiveEnd:(NSNotification *)notificationInfo{
    NSDictionary * dict = notificationInfo.userInfo;
    if(self.liveArray.count){
        for (int i = 0; i<self.liveArray.count; i++) {
             MajFollowModel *model=self.liveArray[i];
            if ([dict[@"endLiveID"] isEqualToString:model.liveId]) {
                //刷新直播列表的数据
                [self loadLives:YES];
                break;
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO
     ];
    if (myOffeset > 30) {
        //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    [self hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    


}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewBackgroundColor:nil];
    
    _userinfoTitleArray=@[[NSString stringWithFormat:@"%@ID",APPName],@"收到掌声",@"送出星币",@"所在城市"];
    

    _shopInfomationTitleArray=@[@"店铺名称",@"店铺二维码",@"开店时间"];
    
    _bigImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    
    _fansIndex=1;
    
    [self addLeftBackBtn:nil frame:CGRectMake(0, 0, 0, 0)];
    
    _requestModel=[[ViewModel alloc]init];
    
    [self configUI];
    
    [self loadData];
    
    
    
    [self regisCELl];
}
//注册tableview上面的cell的方法
-(void)regisCELl
{
        [self.tableview registerNib:[UINib nibWithNibName:@"WSSetMenuTableViewCell" bundle:nil] forCellReuseIdentifier:FOCUSCELL];
    [self.tableview registerNib:[UINib nibWithNibName:@"FollowTableViewCell" bundle:nil] forCellReuseIdentifier:FanseCel];
    [self.tableview registerClass:[ShopInfomationTableViewCell class] forCellReuseIdentifier:@"ShopInfomationTableViewCell"];
    
    
     
}
//布局UI界面
-(void)configUI
{
    [self setViewBackgroundColor:nil];
    
    selectIndex=ONESTYPE;
    _tableHeadView=[OtherUserHeadView inPutHeadView];

    [self loadLives:YES];
    
    [self customTableView];
    
    if (![self.myUserID isEqualToString:[self getUserId]]) {
        self.tableview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TabbarHeight);

    }
    else{
        self.tableview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    }

    self.tableview.backgroundColor = UIColorFromRGB(0xf5f5f5);
    
    [self registerNib:@"EmptyContantTableViewCell"];
    
    WeakSelf(weakSelf, self);
 
//    [self setTableHeaderRefresh:^{
//        weakSelf.currentIndex=1;
//        [weakSelf loadLives:YES ];
//    }];
//    [self setFooterfresh:^{
//        
//       if (selectIndex==TWOSTYPE){
//            weakSelf.currentIndex++;
//           [weakSelf loadLives:NO];
//
//        }else{
//        }
//    }];
    self.tableview.hidden=YES;
    

    
    _personTableHeadView=[[PersonTableHeaderView alloc]initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, tableHeaderViewHeight)];
    
    self.tableview.tableHeaderView =_personTableHeadView;
    
    
    
    _backView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, NAVBARSTATUSBARHEIGHT)];
    _backView.backgroundColor=[UIColor clearColor];
    _backView.userInteractionEnabled=YES;
    _backView.enabled=YES;
    ADD_TARGET_INSIDE(_backView, emptyButtonPress)
    
    [self.view addSubview:_backView];
    _navBarBottomImageView=[[UIImageView alloc]init];
//    _navBarBottomImageView.backgroundColor=UIColorFromRGB(0xababab);
    _navBarBottomImageView.backgroundColor=UIColorFromRGB(0xb2b2b2);
    _navBarBottomImageView.alpha=0;
    
    [_backView addSubview:_navBarBottomImageView];
    
    [_navBarBottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(weakSelf.backView);
        make.height.mas_equalTo(@(0.5));
    }];
    _userTitlelabel=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-100/2, NAVBARHEIGHT, 100, 40)];
    _userTitlelabel.textAlignment=NSTextAlignmentCenter;
    
    _leftButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 3+NAVBARHEIGHT, 20, 19)];
   
    [_leftButton setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(onback) forControlEvents:UIControlEventTouchUpInside];
    [_leftButton setEnlargeEdgeWithTop:30 right:30 bottom:20 left:30];

    [self.view addSubview:_leftButton];
    
   // [self.view insertSubview:_backView aboveSubview:self.tableview];
    //[self.view insertSubview:_tableHeadView aboveSubview:self.tableview];

    _rightButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, 5+NAVBARHEIGHT, 26, 35)];
    [_rightButton setEnlargeEdgeWithTop:30 right:30 bottom:5 left:30];

    [_rightButton setImage:[UIImage imageNamed:@"percenteropenMenu"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(onRightClick) forControlEvents:UIControlEventTouchUpInside];

    NSLog(@"%@  %@",self.myUserID,[self getUserId]);
    
    if (![self.myUserID isEqualToString:[self getUserId]]) {
       
        [self.view addSubview:_rightButton];
       
    toolBarView=[OtherUserToolBarView inPutToolBarView];
        
        FRAME(toolBarView, 0, SCREEN_HEIGHT-TabbarHeight, SCREEN_WIDTH, 49);
        [self.view insertSubview:toolBarView aboveSubview:self.tableview];
        [toolBarView.followButton addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if (_follow==false){
                [weakSelf addFocusDic:@{@"followUserId":self.myUserID,@"liveId":@"0"}];
            }else{
                [weakSelf deleteFocus:@{@"followUserId":self.myUserID}];
            }

            
        }];
        
        [toolBarView.connectButton addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            //点击进入私信的页面
            
            [ChartWithOtherMan chartWithOtherManWithId:_myUserID andViewController:self addIsPresent:NO isHaveFollow: self.follow isFromLive:NO isFromShopDetail:NO];

        }];

    }
    
    
   
}


-(void)onRightClick
{
    
    NSString *isLahei= self.black?@"取消拉黑":@"拉黑";
    
   
    
    [JXTAlertTools showArrayActionSheetWith:self title:nil message:nil callbackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex==1) {
            [self showalertView];
            
        }
        if (btnIndex==2) {
            
            if (self.black) {
                [self deleteBlack :self.myUserID];
                
            }
            else{
                
                [JXTAlertTools showAlertWith:self title:@"确定要拉黑该用户么？" message:nil callbackBlock:^(NSInteger btnIndex) {
                    
                    if (btnIndex==1) {
                        [self addBlack:@{@"blackUserId":self.myUserID,@"liveId":@"0"}];
                    }
                } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
                
        
              
    
            }

        }
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitleArray:@[@"举报",isLahei] otherButtonStyleArray:nil];
    
}
//查看大图
-(void)showBigImageWithPicturewithImage:(NSString *)bigImage{
    KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)KLCPopupHorizontalLayoutCenter,
                                               (KLCPopupVerticalLayout)KLCPopupVerticalLayoutCenter);
    _popup = [KLCPopup popupWithContentView:self.bigImageView
                                  showType:KLCPopupShowTypeFadeIn
                               dismissType:KLCPopupDismissTypeFadeOut
                                  maskType:KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:YES
                     dismissOnContentTouch:NO];
    _popup.backgroundColor=[UIColor blackColor];
    _popup.dimmedMaskAlpha = 0.8;
    [_popup showWithLayout:layout duration:0.0];
    [_popup show];
    @weakify(self);
    
    [self.bigImageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self.popup dismissPresentingPopup];
        
        
    }];
    
}

-(void)emptyButtonPress
{
    NSLog(@"-------=====");
}
//点击左侧按钮的时候返回上一个页面
-(void)onback{
    if (self.isPresent){
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark--添加网络请求的方法
-(void)loadData{
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/userInfo" parameters:@{@"userId":self.myUserID} isCache:NO succeed:^(id data) {
        //请求用户的基本的信息
        NSLog(@"用户基本信息：%@",data);
        for (NSDictionary *dic in data[@"userSendStats"]) {
            UserSendStatsModel *userSendStar=[UserSendStatsModel mj_objectWithKeyValues:dic];
            [self.applauseListArray addObject:userSendStar];
        }

        ShopModel *userStoreModel=[ShopModel mj_objectWithKeyValues:data[@"userStore"]];
        self.shopModel=userStoreModel;
        
        self.shopInfomationContenteArray=@[UseSpaceReplaceNil(userStoreModel.storeName),UseSpaceReplaceNil(userStoreModel.shareUrl),UseSpaceReplaceNil(userStoreModel.openTime)];
        
        
        UserModel *model=[UserModel mj_objectWithKeyValues:data[@"user"]];
        //请求用户的掌声的数据信息
        
     UserBalanceModel *balanceModel=[UserBalanceModel mj_objectWithKeyValues:data[@"userBalance"]];
        [self.balanceArray addObject:balanceModel];
        
        self.gag=[data[@"gag"] integerValue];
        self.follow=[data[@"follow"]integerValue];
        self.black=[data[@"black"]integerValue];
        self.living=[data[@"liveIng"]integerValue];
        self.liveId=data[@"liveId"];
        self.bgPicUrl=data[@"bgPicUrl"];
        [self.dataSource addObject:model];

        self.userID=model.userId;
        
        self.tableview.hidden=NO;
        self.userModel=[self.dataSource firstObject];

        toolBarView.followButton.selected= self.follow;
         [toolBarView.followButton setImage:IMAGE(@"jiaguanzhu") forState:UIControlStateNormal];
         [toolBarView.followButton setImage:[UIImage imageWithColor:UIColorFromRGB(0xffffff)]forState:UIControlStateSelected];
        
       
        [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:self.userModel.bigAvatar]];
        WeakSelf(weakself, self);
        [_personTableHeadView.userHeaderImageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if (ISNULL(weakself.userModel.bigAvatar)) {
                
            } else {
                [weakself showBigImageWithPicturewithImage: weakself.userModel.bigAvatar];
            }
        }];

        [_personTableHeadView addDataWithModel: self.userModel ];
        

        
        [self.tableview reloadData];

        
        NSLog(@"+++++++++%@-----------%@",data[@"follow"],data);
    } fail:^(NSString *error) {
        
    }];
}
//调用添加关注的接口地址 添加关注
-(void)addFocusDic:(NSDictionary *)dic{
    [CLNetworkingManager shareManager].hideBaseMBProgress=YES;
    [CLNetworkingManager shareManager].isHideErrorTip = NO;
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/follow/add" parameters:dic isCache:NO succeed:^(id data) {
        //[self.view makeToast:data[@"message"]];
        
        [UserModel shareUserInfo].followCount=@"关注了某人";
        _follow=YES;
        toolBarView.followButton.selected=YES;
        
        //直播观众页面关注
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"guanzhu",@"textTwo",[dic valueForKey:@"followUserId"], @"followUserId", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"baseguanzhu" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    } fail:^(NSString *error) {
        //[self.view makeToast:error];
    }];
}
//删除关注的方法
-(void)deleteFocus:(NSDictionary *)dic{
       [CLNetworkingManager shareManager].isHideErrorTip = NO;
    [CLNetworkingManager deleteRequestWithUrlString:@"/rest/follow/del" parameters:dic succeed:^(id data) {
        _follow=NO;
        toolBarView.followButton.selected=NO;

        //[self.view makeToast:data[@"message"]];
        
              [UserModel shareUserInfo].followCount=@"取消关注了某人";
        
        //取消关注的通知
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"quxiaoguanzhu",@"textTwo",[dic valueForKey:@"followUserId"], @"followUserId", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"baseguanzhu" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    } fail:^(NSString *error) {
        //[self.view makeToast:error];
    }];
}
//添加用户到黑名单
-(void)addBlack:(NSDictionary *)dic{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/black/add" parameters:dic isCache:NO succeed:^(id data) {
       
        self.black=YES;
        _follow=YES;

        if (_follow==YES) {
            _follow=NO;
            toolBarView.followButton.selected=NO;

        }


        [self.view makeToast:data[@"message"]];
    } fail:^(NSString *error) {
        
    }];
}
//删除黑名单用户
-(void)deleteBlack:(NSString *)blackUserId{
    [CLNetworkingManager deleteRequestWithUrlString:@"/rest/black/del" parameters:@{@"blackUserId":blackUserId} succeed:^(id data) {
        
        self.black=NO;
        

            [self.view makeToast:data[@"message"]];
    } fail:^(NSString *error) {
        
    }];
}
//用户的举报请求
-(void)addReportWithDict:(NSDictionary *)dic{
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userreport/report" parameters:dic isCache:NO succeed:^(id data) {
        [self.view makeToast:data[@"message"]];
    } fail:^(NSString *error) {
        
    }];
}

//直播；列表
-(void)loadLives:(BOOL)isfresh{
    [self.dictionary setObject:self.myUserID forKey:@"userId"];
    [self.dictionary setObject:cunrrenIndex forKey:@"pageIndex"];
    [self.dictionary setObject:@"" forKey:@"liveId"];

    [_requestModel  requestLivesApiurl:@"/rest/user/lives" parmters:self.dictionary isfresh:isfresh succees:^(id responseProject) {
        self.liveArray=responseProject;

        [self endReFresh];
        
        [self.tableview reloadData];
        
        
    } fail:^(NSString *error) {
        [self endReFresh];
 
    }];
}

//进入直播间
-(void)pushLiveRoomWithLiveModel:(MajFollowModel *)model{
   

    //点击直播按钮的时候调用，进入相应的直播间
            //如果用户有直播的时候 显示红色的按钮  点击按钮的时候跳转到用户的直播页面
            WeakSelf(weakSelf, self);
            if ([QJXLivePageHelper sharedManager].livePageArray.count > 0) {
                    UIViewController *viewCtr = [[QJXLivePageHelper sharedManager].livePageArray objectAtIndex:0];
                    if ([viewCtr isKindOfClass:[PXYAnchorController class]]) {
                        [JXTAlertTools showAlertWith:weakSelf title:nil message:kSwitchLiveAlertHint callbackBlock:^(NSInteger btnIndex) {
                        } cancelButtonTitle:nil destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    } else if ([viewCtr isKindOfClass:[PXYViewersViewController class]]) {
                        PXYViewersViewController *pxyViewCtr = (PXYViewersViewController *)viewCtr;
                        UIViewController *presentingCtr = pxyViewCtr.presentingViewController;
                        [pxyViewCtr readyToExitLivePage];
                        [presentingCtr dismissViewControllerAnimated:NO completion:nil];
                        [self starLiveWithSpecial:NO status:model.status liveId:model.liveId userLive:model theaterInfo:nil andLiveIDArray:nil  controller:presentingCtr];
                        }
                } else {
                    [self starLiveWithSpecial:NO status:model.status liveId:model.liveId userLive:model theaterInfo:nil andLiveIDArray:nil  controller:weakSelf];
                }
}


#pragma mark--弹出的警告框相关
-(void)showalertView
{
    UIActionSheet  *sheetView=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"广告欺骗",@"淫秽色情",@"骚扰谩骂",@"反动政治",@"其他内容", nil];
    [sheetView showInView:self.view];
    
}
-(void)showAlear:(NSString *)title
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    
}
//警告框按钮的点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case  0:
            
            break;
        case 1:
            
            break;
            
        default:
            break;
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0 :
            [self addReportWithDict:@{@"userId":self.userModel.userId,@"status":self.userModel.status,@"type":@1}];
            break;
        case 1:
            [self addReportWithDict:@{@"userId":self.userModel.userId,@"status":self.userModel.status,@"type":@2}];
            break;
        case 2:
            [self addReportWithDict:@{@"userId":self.userModel.userId,@"status":self.userModel.status,@"type":@3}];
            break;
        case 3:
            [self addReportWithDict:@{@"userId":self.userModel.userId,@"status":self.userModel.status,@"type":@4}];
            break;
        case 4:
            [self addReportWithDict:@{@"userId":self.userModel.userId,@"status":self.userModel.status,@"type":@10}];
            break;
        case 5:
            
            break;
        default:
            break;
    }
}
//点击按钮的时候调用的方法
-(void)switchStype:(UIButton *)btn
{
    if (btn.selected==YES) {
        //当前的按钮是被选中的状态的时候不做任何的操作
    }
    else
    {
        [_tempBtn setSelected:NO];
        [btn setSelected :YES];
        _tempBtn=btn;
    }

    if (btn.tag==252 )
    {
        
        selectIndex=ONESTYPE;
        self.tableview.mj_footer.hidden=NO;
        
        self.currentIndex=1;
        _tableHeadView.shopInfomationRedLabel.hidden=NO;

        _tableHeadView.otherFocusRedLabel.hidden=YES;
        _tableHeadView.otherFansRedLabel.hidden=YES;
    }
  else if (btn.tag==253 )
    {
        
        selectIndex=TWOSTYPE;
        self.tableview.mj_footer.hidden=YES;

        self.currentIndex=1;
        _tableHeadView.shopInfomationRedLabel.hidden=YES;

         _tableHeadView.otherFocusRedLabel.hidden=NO;
        _tableHeadView.otherFansRedLabel.hidden=YES;
    }
    else if (btn.tag==254)
    {
        
        selectIndex=THREESTYPE;
        self.fansIndex=1;
        self.tableview.mj_footer.hidden=YES;
        _tableHeadView.shopInfomationRedLabel.hidden=YES;
        _tableHeadView.otherFocusRedLabel.hidden=YES;
        _tableHeadView.otherFansRedLabel.hidden=NO;
    }
    
    
    [self.tableview reloadData];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(selectIndex == ONESTYPE)
    {
        
        if (_shopInfomationTitleArray.count>0) {
            return _shopInfomationTitleArray.count;
            
        }else
            return 1;
        
    }
    if (selectIndex==THREESTYPE) {
        NSLog(@"数组个数：%@",self.liveArray);
        if (self.liveArray.count>0) {
            return self.liveArray.count;
            
        }else
            return 1;
    }
    if (selectIndex==TWOSTYPE) {
        if (_userinfoTitleArray.count>0) {
            return _userinfoTitleArray.count;
            
        }else
            return 1;
    }
    else
        return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.tableview)
    {
        
        if (selectIndex==ONESTYPE){

        ShopInfomationTableViewCell *cell= [self.tableview dequeueReusableCellWithIdentifier:@"ShopInfomationTableViewCell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            cell.shopImageView.hidden=YES;
        
            if (indexPath.row==0||indexPath.row==2) {
                cell.content.hidden=NO;
            }
            else{
                cell.content.hidden=YES;
            }
            
            if (indexPath.row==1 || indexPath.row == 0) {
                [cell updateContentConstraints];
                cell.cellJianTouImage.hidden=NO;
            }
            else{
                cell.cellJianTouImage.hidden=YES;
            }
                cell.titleLabel.text=_shopInfomationTitleArray[indexPath.row];
        
            
            if (self.shopInfomationContenteArray.count>0) {
                cell.content.text= self.shopInfomationContenteArray[indexPath.row];
                
            }

        return cell;
        
        }
    
        else if (selectIndex==THREESTYPE)
        {
            NSLog(@"关注LIEBIAO");
            
            if (self.liveArray.count>0) {

                FollowTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:FanseCel];
                cell.topView.hidden=YES;
                cell.livePictureTopContant.constant=0;
                cell.liveBackGroundTopContant.constant=8;
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                MajFollowModel *model=self.liveArray[indexPath.row];
                NSLog(@"他人直播信息de ：%@", self.liveArray[indexPath.row]);

                [cell cellFuZhi:model isNewStarHotViewController:NO];
                
                return cell;
                
            }
            else
            {
                
            EmptyContantTableViewCell *cell= [self.tableview dequeueReusableCellWithIdentifier:@"EmptyContantTableViewCell"];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.alertMessage.text=@"Ta没有直播/回放视频";
                cell.alertImage.image=IMAGE(@"meiyouzhibo1");
                cell.goLook.hidden=YES;
                cell.imageViewTopContant.constant=10;

                return cell;

                

            }
        }
        else if (selectIndex==TWOSTYPE)
        {
            
                WSSetMenuTableViewCell *cell= [self.tableview dequeueReusableCellWithIdentifier:FOCUSCELL];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.noticeSwitch.hidden=YES;
            cell.jianTouImg.hidden=YES;
            cell.exitLoginLabel.hidden=YES;
            cell.titlesLabel.text=_userinfoTitleArray[indexPath.row];
            cell.subTItleLable.hidden=NO;
            
            cell.subTItleLable.text= self.userinfoDetailArray[indexPath.row];
            
                return cell;
            
        }
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (selectIndex==ONESTYPE)

    {
        if (indexPath.row==1) {
            if(ISNULL(self.shopInfomationContenteArray[indexPath.row]))
            {}else{
//            ALLOC(ShopQRcodeViewController, view);
//            if ([self.fromController isKindOfClass:[HomeMultipleStyleViewController class]]) {
//                    view.isFromPersonViewController=YES;
//                }
//                else{
//                    view.isFromPersonViewController=NO;
//
//                }
//
//            view.shopModel=self.shopModel;
//            view.userModel=self.userModel;
//            [self pushNextViewController:view];
               }
        } else if (indexPath.row == 0) {
            //点击了店铺名称 跳转到店铺
            [self personPriviewClickWithString:self.shopModel.shareUrl];
        }
        
        
    }
    
    
    if (selectIndex==THREESTYPE)
    {
        if (self.liveArray.count>0)
        {
            
            if (self.parResultblockAction) {
                self.parResultblockAction();
                
            }
            MajFollowModel *   followModel=self.liveArray[indexPath.row];
            
//            [self starLiveWithStatus:followModel.status Special:NO andLiveId:followModel.liveId  andBgPicUrl:followModel.picUrl andLiveIDArray:nil  controller:self];
//            
            [self pushLiveRoomWithLiveModel:followModel];
            

        }
    }
    else if (selectIndex==TWOSTYPE)
    {
        
    }
}
-(void)personPriviewClickWithString:(NSString *)urlString{
    ALLOC(BaseWebViewViewController, viewController);
    viewController.urlValue = urlString;
    viewController.isSpecialFrmae = YES;
    [self pushNextViewController:viewController];
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat emptyHeight=SCREEN_HEIGHT-tableHeaderViewHeight-tableSection0HeaderHeight-49-iPhoneBottomDistance;

    if(selectIndex == ONESTYPE)
    {
        if (_userinfoTitleArray.count<=0)
        {
            return emptyHeight;
        }
        else{
            if (indexPath.row==0) {
                return  49;
            }
            else{
                return 49;
  
            }
        }

    }
    
    else if(selectIndex==TWOSTYPE)
    {
        if (_userinfoTitleArray.count<=0)
        {
            return emptyHeight;
        }
        else
            return 49;
    }
    else
    {
        
        if (self.liveArray.count<=0)
        {
            
            return emptyHeight;
        }
        else
        return SCREEN_WIDTH+97-56;
        
    }
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
        _tableHeadView.frame=CGRectMake(0, 0, kScreenWidth, 52);
    
   
    
    [_tableHeadView.otherFocusBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if (isFirstReload==NO) {
        isFirstReload=YES
        ;
        [_tableHeadView.shopInfomationButton setSelected:YES];
        _tempBtn = _tableHeadView.shopInfomationButton;

    }
    _tableHeadView.shopInfomationButton.tag=252;
    [_tableHeadView.shopInfomationButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_tableHeadView.shopInfomationButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_tableHeadView.shopInfomationButton addTarget:self action:@selector(switchStype:) forControlEvents:UIControlEventTouchUpInside];

    
    [_tableHeadView.otherFocusBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_tableHeadView.otherFocusBtn addTarget:self action:@selector(switchStype:) forControlEvents:UIControlEventTouchUpInside];
    _tableHeadView.otherFocusBtn.tag=253;
    [_tableHeadView.otherFansBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_tableHeadView.otherFansBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_tableHeadView.otherFansBtn addTarget:self action:@selector(switchStype:) forControlEvents:UIControlEventTouchUpInside];
    _tableHeadView.otherFansBtn.tag=254;

      if (section==0)
    {
        return _tableHeadView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return tableSection0HeaderHeight;
        
    }
    else
        return 0;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offset=scrollView.contentOffset.y;
    if (offset<=0) {
        
       [_leftButton setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
        _userTitlelabel.text=@"";
        [_rightButton setImage:[UIImage imageNamed:@"percenteropenMenu"] forState:UIControlStateNormal];

    }
    else{
        [_leftButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@"gengduo"] forState:UIControlStateNormal];

    }

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset = self.tableview.contentOffset.y;
    myOffeset = yOffset;
    UIColor *color=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    //向上偏移量变正  向下偏移量变负
    if (yOffset < 0) {
        
        CGFloat factor = ABS(yOffset)+120;
        CGRect f = CGRectMake(-([[UIScreen mainScreen] bounds].size.width*factor/120-[[UIScreen mainScreen] bounds].size.width)/2,-ABS(yOffset), [[UIScreen mainScreen] bounds].size.width*factor/120, factor);
        
        _personTableHeadView.headerImageView.frame=f;
        _personTableHeadView.tempBackImageView.frame=f;

                self.backView.backgroundColor=[color colorWithAlphaComponent:0];
        _navBarBottomImageView.alpha=0;
        [_leftButton setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@"percenteropenMenu"] forState:UIControlStateNormal];
        
        if (yOffset<15)
        {
            
            _userTitlelabel.text=@"";
            
        }
        
        
    }else {
       
        CGRect f = _personTableHeadView.frame;
        f.origin.y = 0;
        _personTableHeadView.frame = f;
        _personTableHeadView.headerImageView.frame=CGRectMake(0, f.origin.y, [[UIScreen mainScreen] bounds].size.width, 120);
        _personTableHeadView.tempBackImageView.frame= _personTableHeadView.headerImageView.frame;
        self.tableview.scrollEnabled = YES;
        CGFloat alpha=1-((NAVBARSTATUSBARHEIGHT-yOffset)/NAVBARSTATUSBARHEIGHT);
        if (yOffset>20)
        {
            [self.backView addSubview:_userTitlelabel];
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            _userTitlelabel.text=_personTableHeadView.userName.text;
            _userTitlelabel.textColor=[UIColor blackColor];
            
            [_leftButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"gengduo"] forState:UIControlStateNormal];
            
        } else {
           
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }
     
        self.backView.backgroundColor=[color colorWithAlphaComponent:alpha];
        _navBarBottomImageView.alpha=alpha;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

/**
 *  设置特殊的界面支持的方向,这里特殊界面只支持Home在右侧的情况
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
