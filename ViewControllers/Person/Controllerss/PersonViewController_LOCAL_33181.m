//
//  PersonViewController.m
//  jinshanStrmear
//
//  Created by lalala on 16/5/24.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "PersonViewController.h"
//#import "WSPersonTableViewCell.h"//添加的第一行的Cell 现在这你注释 改成headView
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
#import "MessageViewController.h"
#import "WSPersonTableHeadView.h"
#import "NIMTool.h"
#import "NTESSessionListViewController.h"
#import "NTESService.h"
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

@property(nonatomic,strong)WSPersonTableHeadView * personHeadView;

@end

@implementation PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUserInfo];
    [self MobClickEventWithID:@"shouye_gerenzhongxin"];
    [self hideBaseRequestMBProgress:YES];
    [self setViewBackgroundColor:nil];
    //self.navigationController.fd_prefersNavigationBarHidden = YES;
    /**
     *  @author 王森, 16-07-13 20:07:38
     *
     *  改动了
     */
    self.section2Array=@[@"我的星币",@"我的掌声"];
    //self.section2Array=@[@"我的订单",@"我的体力",@"我的掌声"];
    [self initWithTableViewNib:@"WSPersonTableViewCell" didSelectCellBlock:^(NSIndexPath *indexPath) {
            if (indexPath.section==0) {
                if ([StringWithFormat([AccountModel read].vip) isEqualToString:@"1"] ) {
                    if (indexPath.row==0) {
                        //掌声贡献榜
                        [self hiddenTabBar];
                        ALLOC(FansListViewController, view);
                        [self hiddenTabBar];
                        [self pushNextViewController:view];
                    } else {
                        //回放
                        ALLOC(WSMyPlaybackViewController, vc);
                        [self hiddenTabBar];
                        [self pushNextViewController:vc];
                    }
                } else {
                    [self hiddenTabBar];
                    ALLOC(FansListViewController, view);
                    [self hiddenTabBar];
                    [self pushNextViewController:view];
                }
            }//我的订单
             else if (indexPath.section==2) {
                 [self hiddenTabBar];
                ALLOC(MyOrderListViewController, view);
                [self hiddenTabBar];
                [self pushNextViewController:view];
            } else if (indexPath.section==1) {
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
                    [self hiddenTabBar];
                    ALLOC(WSApplauseViewController, vc);
                    [self hiddenTabBar];
                    [self pushNextViewController:vc];
                }
            } else if (indexPath.section==3) {
                if (indexPath.row==0) {
                    [self hiddenTabBar];
                    ALLOC(WSSetMenuViewController, vc);
                    [self hiddenTabBar];
                    [self pushNextViewController:vc];
                }
            }
    }];
    [self loadUserInfo];
    [self registerNib:@"WSPersoListTableViewCell"];
    FRAME(self.tableview, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -49);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.backgroundColor=UIColorFromRGB(0xf5f5f5);
    _personHeadView = [WSPersonTableHeadView customheadView];
    _personHeadView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 304);
    self.tableview.tableHeaderView = self.personHeadView;
    UIButton*btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 20,30, 30)];
    //  [self.view addSubview:btn1];
    BUTTON_SETIMAGE(btn, @"gerenzhongxin－daohanglan－gouwuche")
   _messageBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 20, 22, 19)];
    BUTTON_SETIMAGE(_messageBtn, @"whitexinfeng")
    __weak typeof(_messageBtn) weakSelf = _messageBtn;
    WeakSelf(Self, self);
    [_messageBtn addActionHandler:^(NSInteger tag) {
        ALLOC(NTESSessionListViewController, liveeVc);
        
        [NTESServiceManager sharedManager].isMessageCenterViewController=NO;
        
        
        AppDelegate *de = [AppDelegate shareInstance];
        [de.tabBar xmTabBarHidden:YES animated:YES];
        
        [Self.navigationController pushViewController:liveeVc animated:NO];
        //清除按钮右上方的badge
        [weakSelf clearBadge];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receveMessage:)
                                                 name:@"recvMessagesNotificationCenter"
                                               object:nil];
    

    /**
     *  @author 王森, 16-07-25 17:07:04
     *
     *  隐藏了小红点功能
     */
//     [_messageBtn showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
//    [btn showBadgeWithStyle:WBadgeStyleNumber value:99 animationType:WBadgeAnimTypeShake];
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
//    UIButton*btn1=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 20, 60, 44)];
//    BUTTON_SETIMAGE(btn1, @"gerenzhongxin－daohanglan－gouwuche")
    //  [self.view addSubview:btn1];
//       AppDelegate* app=[UIApplication sharedApplication].delegate;
//    [app.window addSubview:btn];
//    [app.window addSubview:btn1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];

}

-(void)receveMessage:(NSNotification*)notification
{
    _messageBtn.badgeCenterOffset = CGPointMake(-5, 4);
    
    [_messageBtn showBadge];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([StringWithFormat([AccountModel read].vip) isEqualToString:@"0"]) {
        NSLog(@"不是VIP用户");
        self.isVip=NO;
    } else {
        NSLog(@"是VIP用户");
        self.isVip=YES;
    }
    if (_isInthePaiZhaoView) {
        [self hiddenTabBar];
        _isInthePaiZhaoView=NO;
    } else {
        [self showTabBar];
    }
    if ([NIMSDK sharedSDK].conversationManager.allUnreadCount>0) {
        _messageBtn.badgeCenterOffset = CGPointMake(-5, 4);
        
        [_messageBtn showBadge];
    }
    else{
        [_messageBtn clearBadge];
        
    }
    
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadUserInfo];
    //[[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    //[self.navigationController.navigationBar setBarTintColor:NAVBARCOLOR];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}
-(void)loadUserInfo{
    [self hideBaseRequestMBProgress:YES];
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/userInfo" parameters:@{@"userId":[self getUserId]} isCache:NO succeed:^(id data) {
        [self.dataArray removeAllObjects];
        NSLog(@"个人信息：%@",data);
        [self hideBaseRequestMBProgress:NO];
        UserModel *model=[UserModel mj_objectWithKeyValues:data[@"user"]];
        if ([StringWithFormat(data[@"status"]) isEqualToString:@"1"]){
             self.starID=data[@"starId"];
             if (![data[@"userEextend"][@"cityName" ]  isKindOfClass:[NSNull class]]) {
                _userCityName=[NSString stringWithFormat:@"%@ %@",data[@"userEextend"][@"provinceName"],data[@"userEextend"][@"cityName"]];
            } else {
                _userCityName=@"未设置";
            }
           AccountModel *account=[AccountModel mj_objectWithKeyValues:data[@"user"]];
            [account write];
            [self.dataArray addObject:model];
            [self addHeadViewData];
        }
        
        [self.tableview reloadData];
        //        [self.tableview reloadData];
                //NSLog(@"---===%@",data);
        //        NSLog(@"数组个数：%lu",(unsigned long)self.dataArray.count);
    } fail:^(NSString *error) {
        [self hideBaseRequestMBProgress:YES];
    }];
}
-(void)addHeadViewData{
    UserModel *model=nil;
    WeakSelf(weakSelf, self)
    if (self.dataArray.count>0) {
        model=[self.dataArray lastObject];
    }
    [self.personHeadView addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.nikeName];
    [self.bottomView addSubview:self.sexImageView];
    [self.bottomView addSubview:self.setInfoButton];
    
    
    
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
            vc.chuanDiUserModel=model;
            
            vc.cityName=weakSelf.userCityName;
            
            
            [weakSelf pushNextViewController:vc];
            
        }
        
    }];
    
    
    NSString *nikeName=nil;
    
    if (model.nickName.length>10&&SCREEN_WIDTH<375) {
        nikeName = [model.nickName substringToIndex:10];//截取掉下标7之后的字符串
        self.nikeName.text=[NSString stringWithFormat:@"%@...",nikeName];
        
    }
    else
    {
        self.nikeName.text=model.nickName;
        
    }
    
    
    
    
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo( self.personHeadView).mas_offset(8);
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
    
    
    
    
    
    
    
    self.personHeadView.userId.text=[NSString stringWithFormat:@"全聚星ID：%@",UseSpaceReplaceNil(model.userId)];
    if (ISNULL(model.sign)) {
            self.personHeadView.userSign.text=@"这个人还没有签名";
    } else {
            self.personHeadView.userSign.text=model.sign;
    }
    if ([StringWithFormat(model.vip) isEqualToString:@"1"] ) {
        self.personHeadView.userVipImage.hidden=NO;
        self.personHeadView.userVipImage.image=[UIImage imageNamed:@"84x84mingxingrenzheng"] ;
    } else {
        self.personHeadView.userVipImage.hidden = YES;
    }
    [self.personHeadView.myAttentionLable setTitle:[NSString stringWithFormat:@"我的关注 %@",UseSpaceReplaceNil(model.followCount)] forState:UIControlStateNormal];
    [self.personHeadView.myFansLabel setTitle:[NSString stringWithFormat:@"我的粉丝 %@",UseSpaceReplaceNil(model.fansCount)] forState:UIControlStateNormal];
    if (ISNULL(model.avatar)||[model.avatar isEqualToString:@""]) {
        self.personHeadView.userImage.image=IMAGE(@"morentouxiang120px");
    } else  {
        [ self.personHeadView.userImage sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:IMAGE(@"morentouxiang120px")];
    }
    /**
     *  @author 王森, 16-08-11 17:08:42
     *
     *  先从缓存取出来然后再去加载
     */
    SDImageCache *cache=[SDImageCache sharedImageCache];
    UIImage *imageUse=[cache imageFromDiskCacheForKey:@"userHeaderImgView"];
    self.personHeadView.userInfoPicture.image=[imageUse lightImage];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:model.bigAvatar]
                                  options:0
                                 progress:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {

                                    if (image) {
                                        self.personHeadView.userInfoPicture.image=[image lightImage];
                                        SDImageCache *cache=[SDImageCache sharedImageCache];
                                        [cache storeImage:image forKey:@"userHeaderImgView" toDisk:YES];
                                    } else {
                                         self.personHeadView.userInfoPicture.image=[UIImage  imageNamed:@"touxiang-beijingmoren"];
                                        //                                    quanjuxinglogo
                                        SDImageCache *cache=[SDImageCache sharedImageCache];
                                        [cache storeImage:IMAGE(@"touxiang-beijingmoren") forKey:@"userHeaderImgView" toDisk:YES];
                                    }
                                }];
        [self.personHeadView.myAttentionLable addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self hiddenTabBar];
            ALLOC(WSAttentionViewController, controller);
            [weakSelf.navigationController pushViewController:controller animated:YES];
        }];
        [self.personHeadView.myFansLabel addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self hiddenTabBar];
            ALLOC(WSFansViewController, fansVC);
            [weakSelf.navigationController pushViewController:fansVC animated:YES];
        }];
            //点击头像调用的方法
        [self.personHeadView.userImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                //关闭头像的点击事件，防止重复点击 1秒钟后重新打开点击事件
                self.personHeadView.userImage.userInteractionEnabled = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.personHeadView.userImage.userInteractionEnabled = YES;
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
            }];
        }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    //隐藏了订单
    if (section==3) {
        return 10;
    }else if (section==1) {
        if (self.isVip) {
            return 10;
        } else
            return 10;
    }
    else
    return 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
               return 1;
    }

    if (section==1) {
        return 2;
    }else if (section==2){
        //隐藏了订单
        return 1;
    } else
    {
        return 2;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section==0) {
//        return 304;
//    }
//else
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
{
    if (!_sexImageView) {
        _sexImageView=[UIButton new];
    }
    return _sexImageView;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
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
    WSPersoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSPersoListTableViewCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.section==0) {
//        if ([StringWithFormat(model.vip) isEqualToString:@"1"] || [[AccountModel read].vip isEqualToString:@"1"] ) {
//            cell.tile.text=@[@"掌声贡献榜",@"我的回放"][indexPath.row];
//                if (indexPath.row==1) {
//                     cell.bottomImg.hidden=YES;
//                } else {
//                    cell.bottomImg.hidden=NO;
//                }
//            } else {
                cell.tile.text=@"掌声贡献榜";
                cell.bottomImg.hidden=YES;
//            }
    } else if (indexPath.section==2){
            cell.tile.text=@"我的订单";
            cell.bottomImg.hidden=YES;
    } else if (indexPath.section==1){
            cell.tile.text=self.section2Array[indexPath.row];
            if (indexPath.row==1) {
                cell.bottomImg.hidden=YES;
            }
    } else if (indexPath.section==3){
        if (indexPath.row==0) {
            cell.tile.text=@"设置";
            cell.bottomImg.hidden=YES;
            cell.tile.hidden=NO;
            cell.jianTouImg.hidden=NO;
            cell.backgroundColor=UIColorFromRGB(0xffffff);


        } else {
            cell.tile.hidden=YES;
            cell.jianTouImg.hidden=YES;
            cell.bottomImg.hidden=YES;
            cell.backgroundColor=UIColorFromRGB(0xf5f5f5);
        }
    }
    return cell;
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
    } else {
        NSLog(@"没有摄像头");
        [self showFailed:@"没有摄像头"];
        //[PublicMethod showMBProgressHUD:@"该设备没有摄像头" andWhereView:self.view hiddenTime:kHiddenTime];
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

    
    
    [NIMTool  setuserImage:nil andImage:image];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset = self.tableview.contentOffset.y;
    //向上偏移量变正  向下偏移量变负
    if (yOffset < 0) {
        CGFloat factor = ABS(yOffset)+304;
        CGRect f = CGRectMake(-([[UIScreen mainScreen] bounds].size.width*factor/304-[[UIScreen mainScreen] bounds].size.width)/2,-ABS(yOffset), [[UIScreen mainScreen] bounds].size.width*factor/304, factor);
        _personHeadView.userInfoPicture.frame = f;
        _personHeadView.gaosimohuBeijing.frame=f;
        _personHeadView.clearImage.frame=f;
    }   else {
        CGRect f = _personHeadView.frame;
        f.origin.y = 0;
        _personHeadView.frame = f;
        _personHeadView.userInfoPicture.frame = CGRectMake(0, f.origin.y, [[UIScreen mainScreen] bounds].size.width, 304);
        _personHeadView.gaosimohuBeijing.frame = CGRectMake(0, f.origin.y, [[UIScreen mainScreen] bounds].size.width, 304);
        _personHeadView.clearImage.frame= CGRectMake(0, f.origin.y, [[UIScreen mainScreen] bounds].size.width, 304);;
        self.tableview.scrollEnabled = YES;
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
