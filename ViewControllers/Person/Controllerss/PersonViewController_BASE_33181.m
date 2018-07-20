//
//  PersonViewController.m
//  jinshanStrmear
//
//  Created by lalala on 16/5/24.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "PersonViewController.h"
#import "WSPersonTableViewCell.h"
#import "WSPersoListTableViewCell.h"
#import "UIImage+Blur.h"
#import "UIView+WZLBadge.h"
#import "UIView+BlockGesture.h"
#import "WSSetUserHeaderImgView.h"
#import "AppDelegate.h"
#import "WSFansViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "WSAttentionViewController.h"
#import "WSMyPlaybackViewController.h"
#import "WSMystarViewController.h"
#import "WSMyPhysicalViewController.h"
#import "UIButton+Block.h"
#import "WSApplauseViewController.h"
#import "WSSetMenuViewController.h"
#import "WSPersonalInfomationViewController.h"
#import "MileCenterController.h"
#import "CLNetworkingManager.h"
#import "CLImageModel.h"
#import "UIView+Toast.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MultiFormat.h"
#import "SDImageCache.h"
#import "UserModel.h"
#import "LiveMileViewController.h"
#import "MJExtension.h"
#import "SDWebImageManager.h"
#import "MBProgressHUD.h"
#import "AccountModel.h"
#import "WSOtherStarMainViewController.h"
#import "UIImage+Extend.h"
#import "FansListViewController.h"
#import "MyOrderListViewController.h"
@interface PersonViewController ()<UIPickerViewDelegate>

@property(nonatomic,strong) WSSetUserHeaderImgView *setUserImg;
//控制tabbar是否显示
@property(nonatomic,assign)BOOL isInthePaiZhaoView;
//判断是不是VIP用户

@property(nonatomic,assign)BOOL isVip;
@property(nonatomic,strong)NSString *starID;


@property(nonatomic,strong)UIView *navView;//滑动的时候改变透明度 显示用户名在面
@property(nonatomic,strong)UILabel *nameLabel;//显示用户的名字的
@property(nonatomic,strong)NSString *userCityName;//用户城市名字
@property(nonatomic,strong)NSArray  *section2Array;//第二分组的数组
@property(nonatomic,strong) UIButton*messageBtn;

@property(nonatomic,strong) UILabel*nikeName;
@property(nonatomic,strong) UIButton*setInfoButton;
@property(nonatomic,strong) UIButton*sexImageView;
@property(nonatomic,strong) UIView*bottomView;




@end

@implementation PersonViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self MobClickEventWithID:@"shouye_gerenzhongxin"];
    
    [self hideBaseRequestMBProgress:YES];
    
    
    [self setViewBackgroundColor:nil];
    
    
    
//    self.navigationController.fd_prefersNavigationBarHidden = YES;

    /**
     *  @author 王森, 16-07-13 20:07:38
     *
     *  改动了
     */
    self.section2Array=@[@"我的星币",@"我的掌声"];
//    self.section2Array=@[@"我的订单",@"我的体力",@"我的掌声"];

    
    [self initWithTableViewNib:@"WSPersonTableViewCell" didSelectCellBlock:^(NSIndexPath *indexPath) {
    
    if (indexPath.section==1) {
        
        
        if ([StringWithFormat([AccountModel read].vip) isEqualToString:@"1"] ) {
            if (indexPath.row==0) {
                //掌声贡献榜
                ALLOC(FansListViewController, view);
//                view.userID=
                [self pushNextViewController:view];
                
            }
            else{
                //回放
        ALLOC(WSMyPlaybackViewController, vc);
        [self hiddenTabBar];
        [self pushNextViewController:vc];
            }
            
        }
        else{
            ALLOC(FansListViewController, view);
            //                view.userID=
            [self pushNextViewController:view];
            
        }
        
    }
        
        //我的订单
    else if (indexPath.section==3)

    {
        ALLOC(MyOrderListViewController, view);
        [self pushNextViewController:view];
        
        
    }
    else if (indexPath.section==2)
    {
        /**
         *  @author 王森, 16-07-13 20:07:38
         *
         *  改动了 更改了判断row
         */
        if (indexPath.row==0) {
            ALLOC(WSMyPhysicalViewController, vc);
            [self hiddenTabBar];
            [self pushNextViewController:vc];

        }
        
        if (indexPath.row==1) {
            ALLOC(WSApplauseViewController, vc);
            [self pushNextViewController:vc];
        }
       
    }
    else if (indexPath.section==4)
    {
        if (indexPath.row==0) {
            
            ALLOC(WSSetMenuViewController, vc);
            
        [self pushNextViewController:vc];
        }

    }

    
    
}];
    

    [self loadUserInfo];

    
    [self registerNib:@"WSPersoListTableViewCell"];
    FRAME(self.tableview, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44);
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableview.backgroundColor=UIColorFromRGB(0xf5f5f5);
    

    UIButton*btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 20,30, 30)];
    //  [self.view addSubview:btn1];
    BUTTON_SETIMAGE(btn, @"gerenzhongxin－daohanglan－gouwuche")
    
   _messageBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 20, 22, 19)];
    BUTTON_SETIMAGE(_messageBtn, @"whitexinfeng")
    __weak typeof(_messageBtn) weakSelf = _messageBtn;
    
    WeakSelf(Self, self);
    

    [_messageBtn addActionHandler:^(NSInteger tag) {
        
       ALLOC(LiveMileViewController, liveVc)
        AppDelegate *de=[AppDelegate shareInstance];
        [de.tabBar xmTabBarHidden:YES animated:YES];
        
        [Self.navigationController pushViewController:liveVc animated:NO];
        [weakSelf clearBadge];
    }];
    /**
     *  @author 王森, 16-07-25 17:07:04
     *
     *  隐藏了小红点功能
     */
//     [_messageBtn showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
//   
//    
//    [btn showBadgeWithStyle:WBadgeStyleNumber value:99 animationType:WBadgeAnimTypeShake];
//  
    /**
     *  @author 王森, 16-07-13 19:07:11
     *
     *  隐藏了购物车按钮
     */
    btn.hidden=YES;
    
    __weak typeof(btn)WeakSelf=btn;
    
    [btn addActionHandler:^(NSInteger tag) {
       
        [WeakSelf clearBadge];
        
    }];
    
    
//    UserModel *usermodel=[UserModel shareUserInfo];
//    usermodel.avatar=@"22";
//    
//         //昵称
//           [usermodel addObserver:self forKeyPath:@"nickName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//         //头像
//    
//           [usermodel addObserver:self forKeyPath:@"avatar" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//         //签名
//           [usermodel addObserver:self forKeyPath:@"sign" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//         //签名
//           [usermodel addObserver:self forKeyPath:@"sexStr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//         //关注人数
//           [usermodel addObserver:self forKeyPath:@"followCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//        //星球人数
//    
//        [usermodel addObserver:self forKeyPath:@"starCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];


    
//           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    usermodel.avatar=@"assa";
//});
 
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //iOS7设置-16，iOS6设置-6
    spacer.width = -1;
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //iOS7设置-16，iOS6设置-6
    spacer1.width = -10;
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_messageBtn];
    self.navigationItem.leftBarButtonItems=@[spacer1,leftBarButtonItem];

    self.navigationItem.rightBarButtonItems=@[spacer,rightBarButtonItem];

//    UIButton*btn=[[UIButton alloc]initWithFrame:CGRectMake(10, 20, 60, 44)];
//    //  [self.view addSubview:btn1];
//  BUTTON_SETIMAGE(btn, @"gerenzhongxin－daohanglan－gouwuche")
//    
//    UIButton*btn1=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 20, 60, 44)];
//    BUTTON_SETIMAGE(btn1, @"gerenzhongxin－daohanglan－gouwuche")

    //  [self.view addSubview:btn1];
//       AppDelegate* app=[UIApplication sharedApplication].delegate;
    
//    [app.window addSubview:btn];
//    [app.window addSubview:btn1];

    
}
#pragma mark - 监控者
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//
//{
//    
//    
//      NSLog(@"---------------\n--------------\n----------\n监控的值修改了个人资料\n%@------------\n-----------\n",[change objectForKey:@"new"]);
//   
//    [self loadUserInfo];
//    
//    
//}

- (void)dealloc
{
//    UserModel *usermodel=[UserModel shareUserInfo];
//    
//   
//    [usermodel removeObserver:self forKeyPath:@"avatar"];
//        [usermodel removeObserver:self forKeyPath:@"nickName"];
//        [usermodel removeObserver:self forKeyPath:@"sign"];
//    [usermodel removeObserver:self forKeyPath:@"sexStr"];
//    [usermodel removeObserver:self forKeyPath:@"followCount"];
//    [usermodel removeObserver:self forKeyPath:@"starCount"];
//
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([StringWithFormat([AccountModel read].vip) isEqualToString:@"0"]) {
        NSLog(@"不是VIP用户");
        self.isVip=NO;
        
    }
    else{
        NSLog(@"是VIP用户");

        self.isVip=YES;

    }
    
    if (_isInthePaiZhaoView) {
        [self hiddenTabBar];
        
        
        _isInthePaiZhaoView=NO;
        
    }
    else
    {
        [self showTabBar];
    }
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
//     [self.navigationController.navigationBar setBarTintColor:NAVBARCOLOR];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];

//    self.navigationController.navigationBarHidden=YES;
//    UIImage *image=[UIImage getImageFromColor:RGBA(225, 225, 225, 0)];
    
    
//    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    


}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadUserInfo];
//     [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//         [self.navigationController.navigationBar setBarTintColor:NAVBARCOLOR];

    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];

}

-(void)loadUserInfo{

    
    [self hideBaseRequestMBProgress:YES];
    
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/userInfo" parameters:@{@"userId":[self getUserId]} isCache:NO succeed:^(id data) {
       
        [self.dataArray removeAllObjects];


        
        NSLog(@"个人信息：%@",data);
        
        [self hideBaseRequestMBProgress:NO];

        UserModel *model=[UserModel mj_objectWithKeyValues:data[@"user"]];
        if ([StringWithFormat(data[@"status"]) isEqualToString:@"1"])
        {
            
            self.starID=data[@"starId"];
            
            if (  ![data[@"userEextend"][@"cityName" ]  isKindOfClass:[NSNull class]]) {
                _userCityName=[NSString stringWithFormat:@"%@ %@",data[@"userEextend"][@"provinceName"],data[@"userEextend"][@"cityName"]];
                
            }
            else{
                _userCityName=@"未设置";
                
            }
            
           AccountModel *account=[AccountModel mj_objectWithKeyValues:data[@"user"]];
            
            [account write];
            [self.dataArray addObject:model];

        }
        
              
        
        [self.tableview reloadData];
        
        
        //NSLog(@"---===%@",data);

//        NSLog(@"数组个数：%lu",(unsigned long)self.dataArray.count);
        
        
    } fail:^(NSString *error) {
        
        [self hideBaseRequestMBProgress:YES];
  
    }];
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    self.navigationController.navigationBar.alpha=scrollView.contentOffset.y/200;
//
//    
//    CGFloat offsetY = scrollView.contentOffset.y + self.tableview.contentInset.top;//注意
//    CGFloat panTranslationY = [scrollView.panGestureRecognizer translationInView:self.tableview].y;
//    
//    if (offsetY > 64) {
//        if (panTranslationY > 0) { //下滑趋势，显示
//            [self showTabBar];
//            
//        }
//        else {  //上滑趋势，隐藏
//            [self hiddenTabBar];
//        
//            
//            
//        }
//    }
//    else {
//        [self showTabBar];
//        
//    }
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    //隐藏了订单
    if (section==3) {
        return 10;
    }
else
    if (section==1) {
        
        if (self.isVip) {
            return 10;
        }
        else
            return 0;
        
    }
    else

    return 10;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
 
    if (section==2) {
        return self.section2Array.count;

        
    }
    else if (section==3)
    {
        //隐藏了订单
        return 1;
        
    }
    
    else if (section==4)
    {
        return 2;
        
    }
   
    else{
        if (section==1) {
           
            if (self.isVip) {
                return 2;
            }
            else
            return 1;
            
        }
   
    return 1;
    }

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 304;
    }
else
    
    return 49;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view=[UIView new];
    view.backgroundColor=UIColorFromRGB(0xf5f5f5);
    return view;
    
}
-(UILabel *)nikeName
{
    
    if (!_nikeName) {
        _nikeName=[UILabel new];
        _nikeName.textColor=[UIColor whiteColor];
        _nikeName.font=[UIFont systemFontOfSize:18];
        
    }
    return _nikeName;
    
}


-(UIButton *)setInfoButton
{  if (!_setInfoButton) {
    _setInfoButton=[UIButton new];
}
    return _setInfoButton;
    
}

-(UIButton *)sexImageView
{  if (!_sexImageView) {
    _sexImageView=[UIButton new];
}
    return _sexImageView;
    
}

-(UIView *)bottomView
{  if (!_bottomView) {
    _bottomView=[UIView new];
}
    return _bottomView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserModel *model=nil;
    
    if (self.dataArray.count>0) {
        model=[self.dataArray lastObject];
        
    }
    if (indexPath.section==0) {
        WSPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSPersonTableViewCell"];
        cell.tag=30090;
        
        cell.backgroundColor=UIColorFromRGB(0xf5f5f5f);
        [cell addSubview:self.bottomView];
        [self.bottomView addSubview:self.nikeName];
        [self.bottomView addSubview:self.sexImageView];
        [self.bottomView addSubview:self.setInfoButton];
        
        
        WeakSelf(weakSelf, self);

        [self.setInfoButton setImage:[UIImage imageNamed:@"bianjiziliao"] forState:UIControlStateNormal];

        if ([StringWithFormat(model.sex) isEqualToString:@"0"]) {
            [self.sexImageView setImage:IMAGE(@"fensiliebiao－yonghuxingbie－nv") forState:UIControlStateNormal];
           
            
        }
        else if ([StringWithFormat(model.sex) isEqualToString:@"1"])
        {
            
             [self.sexImageView setImage:IMAGE(@"fensiliebiao－yonghuxingbie－nan") forState:UIControlStateNormal];
        }
        else{
            
            UIImage *IMAGE=[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)];
            
            [self.sexImageView setImage:IMAGE forState:UIControlStateNormal];
            
        }

        
        [self.setInfoButton addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            ALLOC(WSPersonalInfomationViewController, vc);
            
            if (![model isKindOfClass:[NSNull class]]||![StringWithFormat(model) isEqualToString:@"(null)"]) {
                if (self.dataArray.count>0) {
                vc.chuanDiUserModel=model;
                
                vc.cityName=weakSelf.userCityName;
                
                
                [weakSelf pushNextViewController:vc];
                     }
                
            }
            
        }];
        
        
        NSString *nikeName=nil;
        
        if (model.nickName.length>10&&SCREEN_WIDTH<375) {
            nikeName = [model.nickName substringToIndex:10];//截取掉下标7之后的字符串
           self.nikeName.text=[NSString stringWithFormat:@"%@...",nikeName];

        }
        else
        {
           self.nikeName.text=UsePlaceHolderReplaceNil(model.nickName, @"昵称");
            
        }

        

        
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(cell).mas_offset(8);
            make.height.equalTo(@(20));
            
        }];
        
        [self.nikeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(weakSelf.bottomView);
        }];
        
        [self.sexImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(weakSelf.bottomView);
            make.left.equalTo(weakSelf.nikeName.mas_right).mas_offset(5);
            make.right.equalTo(weakSelf.setInfoButton.mas_left).offset(-5);
        }];
        
        
        
        
        [self.setInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(weakSelf.bottomView);
            make.right.equalTo(weakSelf.bottomView);
        }];
        
        
        
        
        
        
        

     
        cell.wangeImageView.backgroundColor=[UIColor colorWithPatternImage:IMAGE(@"gerenzhongxin－beijing")];
        
//        cell.wangeImageView.backgroundColor=[UIColor redColor];
        
        
        cell.number.text=[NSString stringWithFormat:@"全聚星ID：%@",UseSpaceReplaceNil(model.userId)];
        
        if (ISNULL(model.sign)) {
            cell.describe.text=@"这个人还没有签名";

        }else
        {
        cell.describe.text=model.sign;
    }
        
        if ([StringWithFormat(model.vip) isEqualToString:@"1"] ) {
            cell.vipImageView.hidden=NO;

            cell.vipImageView.image=[UIImage imageNamed:@"84x84mingxingrenzheng"] ;
            
    }
        else{
            cell.vipImageView.hidden=YES;

        }
    

        cell.guanZhucount.text=[NSString stringWithFormat:@"我的关注 %@",UseSpaceReplaceNil(model.followCount)];

        cell.fenSiCount.text=[NSString stringWithFormat:@"我的粉丝 %@",UseSpaceReplaceNil(model.fansCount)];
        cell.xingQiuCount.text=StringWithFormat(model.starCount);
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        //NSLog(@"数据走了几次%@",model.avatar);
        
        
        if (ISNULL(model.avatar)||[model.avatar isEqualToString:@""]) {
            cell.headerImg.image=IMAGE(@"morentouxiang120px");
        }
        else{
           
           [cell.headerImg sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:IMAGE(@"morentouxiang120px")];
        }
        
       

    
        /**
         *  @author 王森, 16-08-11 17:08:42
         *
         *  先从缓存取出来然后再去加载
         */
        SDImageCache *cache=[SDImageCache sharedImageCache];
        
        UIImage *imageUse=[cache imageFromDiskCacheForKey:@"userHeaderImgView"];
        cell.bigImageView.image=[imageUse lightImage];
        
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:model.bigAvatar]
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                
                                if (image) {
                                    
                                        cell.bigImageView.image=[image lightImage];
                                    
                                    SDImageCache *cache=[SDImageCache sharedImageCache];
                                    [cache storeImage:image forKey:@"userHeaderImgView" toDisk:YES];
                                }
                                else{
                                    
                                     cell.bigImageView.image=[UIImage  imageNamed:@"touxiang-beijingmoren"];
                                    //                                    quanjuxinglogo
                                    SDImageCache *cache=[SDImageCache sharedImageCache];
                                    [cache storeImage:IMAGE(@"touxiang-beijingmoren") forKey:@"userHeaderImgView" toDisk:YES];
                                    
                                }

                            }];
        
            

        
            [cell.myGuanZhuView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                [self hiddenTabBar];
                ALLOC(WSAttentionViewController, controller);
                [weakSelf.navigationController pushViewController:controller animated:YES];

            }];
        
        
      
        [cell.myFansView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [self hiddenTabBar];
            
            ALLOC(WSFansViewController, fansVC);
            
            
            [weakSelf.navigationController pushViewController:fansVC animated:YES];
            
//            [weakSelf pushNextViewController:fansVC];
            
        }];
        
        [cell.myxingQiuView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
           
            ALLOC(WSMystarViewController, vc);
            
            [self hiddenTabBar];

            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        }];
        
        //点击头像调用的方法
        [cell.headerImg addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            //关闭头像的点击事件，防止重复点击 1秒钟后重新打开点击事件
            cell.headerImg.userInteractionEnabled=NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.headerImg.userInteractionEnabled=YES;
            });
            [[AppDelegate shareInstance].tabBar xmTabBarHidden:YES animated:YES];
            

            _messageBtn.hidden=YES;
            
          _setUserImg=[[WSSetUserHeaderImgView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
            SDImageCache *cache=[SDImageCache sharedImageCache];
            
            UIImage *imageUse=[cache imageFromDiskCacheForKey:@"userHeaderImgView"];
            
            _setUserImg.userHeaderImg.image=imageUse;
            
            [_setUserImg.paiZHaobtn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
               
                //拍照选择图片
                [weakSelf paizhao:_setUserImg];
                
            }];
            
            //从相册选择图片
            [_setUserImg.selectbtnFromIphone addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                [weakSelf selectFromIphone];
                
                
            }];

        [_setUserImg.cancelSelect addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [UIView animateWithDuration:0.5 animations:^{
                _messageBtn.hidden=NO;

                weakSelf.setUserImg.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH , SCREEN_HEIGHT);

            }completion:^(BOOL finished) {
                [[AppDelegate shareInstance].tabBar xmTabBarHidden:NO animated:YES];
                
                [weakSelf loadUserInfo];
                
                [weakSelf.setUserImg removeFromSuperview];

            }];
            
            
        }];
            
            
            [self.view addSubview:_setUserImg];

           [UIView animateWithDuration:0.5 animations:^{
               FRAME(_setUserImg, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);


           } ];
            
            
            
            

            
        }];
        
        return cell;
    }
    else
    {
        WSPersoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSPersoListTableViewCell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        if (indexPath.section==1) {
            if ([StringWithFormat(model.vip) isEqualToString:@"1"] ) {

            cell.tile.text=@[@"掌声贡献榜",@"我的回放"][indexPath.row];
            
                if (indexPath.row==1) {
                     cell.bottomImg.hidden=YES;
                }
                else{
                    cell.bottomImg.hidden=NO;

                }
            }
            else{
                cell.tile.text=@"掌声贡献榜";
                cell.bottomImg.hidden=YES;


            }
            
            
        }
        
        else if (indexPath.section==3)

        {
            cell.tile.text=@"我的订单";
            cell.bottomImg.hidden=YES;
        }
        else if (indexPath.section==2)
        {
            
            cell.tile.text=self.section2Array[indexPath.row];
            
            if (indexPath.row==1) {
                cell.bottomImg.hidden=YES;

            }
        }
        else if (indexPath.section==4)

        {
            if (indexPath.row==0) {
                cell.tile.text=@"设置";
                cell.bottomImg.hidden=YES;
                
            }
            else{
                cell.tile.hidden=YES;
                cell.jianTouImg.hidden=YES;
                cell.bottomImg.hidden=YES;
                cell.backgroundColor=UIColorFromRGB(0xf5f5f5);
                
            }
        }
       
        return cell;
  
    }

    }
    
    
   

#pragma mark - 判断设备是否有摄像头 设置用户头像

- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
-(void)paizhao:(UIView *)views
{
    _isInthePaiZhaoView=YES;

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    if ([self isCameraAvailable]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        NSLog(@"没有摄像头");
        
        [ self showFailed:@"没有摄像头"];
        
        //           [PublicMethod showMBProgressHUD:@"该设备没有摄像头" andWhereView:self.view hiddenTime:kHiddenTime];
    }

}

-(void)selectFromIphone
{
    _isInthePaiZhaoView=YES;

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //scale这个参数从0.1开始逐渐等比放大图片
//    UIImage *newimage = [self makeThumbnailFromImage:image scale:0.5];

    [NSThread detachNewThreadSelector:@selector(saveImage:) toTarget:self withObject:image];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    _isInthePaiZhaoView=YES;

    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImage:(UIImage *)image
{
    _setUserImg.userHeaderImg.image=image;
    
    
    _isInthePaiZhaoView=YES;
    [self uploaduserImg:image];
    
}

-(void)uploaduserImg:(UIImage *)images{
    
    
    UIImage *image=[UIImage makeThumbnailFromImage:images scale:0.5];
    
      NSLog(@"imagddedddddddd%f    %f",images.size.height,images.size.width);
    NSData *imageData = UIImagePNGRepresentation(image); //PNG格式
    CLImageModel *imageModel=[[CLImageModel alloc]init];
    
    imageModel.image=image;
    imageModel.field=@"avatar";
    MainGCD(^{
        
        [self hideBaseRequestMBProgress:YES];
        
            [ self  showWithStatus:@"正在上传图片"];


    });
    
    
    [CLNetworkingManager uploadWithURLString:@"/rest/user/updateAvatar" parameters:@{@"avatar":imageData} model:imageModel progress:^(float writeKB, float totalKB) {
        
    } succeed:^(id responseObject) {
        [self hideBaseRequestMBProgress:NO];

        [self removeStatuslable];
        

        
        [self.view makeToast:@"图片上传成功"];
        
        NSLog(@"%@",responseObject);
        
        
    }
    fail:^(NSString *error) {
        [self removeStatuslable];
        MainGCD(^{
            [self hideBaseRequestMBProgress:NO];

            [ self.view makeToast  :@"上传图片失败"];
            
            
        });
        NSLog(@"失败%@",error);
        
    }];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    WSPersonTableViewCell *cell=[self.view viewWithTag:30090];
    CGFloat yOffset = self.tableview.contentOffset.y;
    //向上偏移量变正  向下偏移量变负
    if (yOffset < 0) {
        CGFloat factor = ABS(yOffset)+303;
        CGRect f = CGRectMake(-([[UIScreen mainScreen] bounds].size.width*factor/303-[[UIScreen mainScreen] bounds].size.width)/2,-ABS(yOffset), [[UIScreen mainScreen] bounds].size.width*factor/303, factor);
        
        
        cell.bigImageView.frame =f ;
        cell.wangeImageView.frame =f;
        cell.backMiddleImageView.frame=f;
        
        
    }else {
        CGRect f = cell.frame;
        f.origin.y = 0;
        cell.frame = f;
        CGRect frame=CGRectMake(0, f.origin.y, [[UIScreen mainScreen] bounds].size.width, 303);
        cell.bigImageView.frame = frame;
        cell.wangeImageView.frame=frame;
        cell.backMiddleImageView.frame=frame;
        [self.tableview reloadData];
        
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
