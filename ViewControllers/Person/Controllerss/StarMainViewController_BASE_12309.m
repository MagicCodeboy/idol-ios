



//
//  StarViewController.m
//  jinshanStrmear
//
//  Created by lalala on 16/6/3.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "StarMainViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Blur.h"
#import "MJExtension.h"
#import "UserModel.h"
#import "NothingView.h"
#import "UIButton+Block.h"
#import "CLNetworkingManager.h"
#import "WSOtherStarMainViewController.h"
#import "LSHMessageTabCell.h"
#define ONEFANSCELL @"ii"
#define TWOFANSCELL @"jj"
#define HOLD @"hold"
#define MESSCELL @"message"
#import "CommonDefin.h"
#import "UIView+Toast.h"
#import "PersonHeaderView.h"
#import "PersonFansCell.h"
#import "PersonLiveCell.h"
#import "ViewModel.h"


@interface StarMainViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isFocus;
}

@property(nonatomic,strong)UIView *backView;

@property(nonatomic,strong)UILabel *userTitlelabel;//用于上滑的时候显示用户的名字


@property(nonatomic,strong)PersonHeaderView *headView;

@property(nonatomic,strong)UIButton *tempButton;

@property(nonatomic,assign)BOOL liveBtnHide;

@property(nonatomic,assign)BOOL gag;//是否禁言了
@property(nonatomic,assign)BOOL follow;//是否关注了
@property(nonatomic,assign)BOOL black;//是否拉黑了


@property(nonatomic,copy)NSString *bgPicUrl;//用户的头像的底部视图

@property(nonatomic,copy)NSString *starId;//获取用户自己的星球ID

@property(nonatomic,assign)BOOL liveOne;//判断加载哪一个Cell

@property(nonatomic,strong)NSArray *liveArray;//直播的数据存放的数组

@property(nonatomic,strong)NSArray *fansArray;//粉丝的数据存放的数组

@property(nonatomic,strong)UIButton *leftButton;//添加左侧的返回按钮

@property(nonatomic,copy)NSString *myUserId;//传递进来的userId

@property(nonatomic,strong)NSMutableArray *dataSource;//用来存放数据的数组

@property(nonatomic,strong)UserBalanceModel *userBalanceModel;

@property(nonatomic,strong)NSMutableArray *balanceArray;//存放个人掌声的数组



@end

@implementation StarMainViewController


//懒加载数组 头视图的数据的数组
-(NSMutableArray *)balanceArray
{
    if (_balanceArray==nil)
    {
        _balanceArray=[NSMutableArray array];
    }
    return _balanceArray;
}
-(NSMutableArray *)dataSource
{
    if (_dataSource==nil)
    {
        _dataSource=[NSMutableArray array];
    }
    return _dataSource;
}
-(instancetype)initWithString:(NSString *)myuserId
{
    if (self==[super init])
    {
        self.myUserId=myuserId;
      
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    //[self viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=YES;
    [self hiddenTabBar];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    //[self viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden=NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.automaticallyAdjustsScrollViewInsets=YES;
    
    self.view.backgroundColor=UIColorFromRGB(0xf5f5f5);

    _liveOne=YES;
    
    [self addBackBtn];
    self.navigationController.navigationBar.alpha=1;
    
    [self configUI];
    //请求直播信息
    [self loadLives];
    
    
    [self loadData];
}
-(void)configUI
{
    [self customTableView];
    
    [self registerNib:@"LSHMessageTabCell"];
    

    
    _headView=[PersonHeaderView inPutView];
    _headView.frame=CGRectMake(0, 0, kScreenWidth, 368);
    self.tableview.tableHeaderView=_headView;
    
    //[self addHeadView];
    
    //注册Cell
    [self regisCell];
    
    _backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _backView.backgroundColor=[UIColor clearColor];
    _backView.userInteractionEnabled=NO;
    [self.view addSubview:_backView];
    
    _userTitlelabel=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-100/2, 20, 100, 40)];
    _userTitlelabel.textAlignment=NSTextAlignmentCenter;
    
    
    _leftButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 25, 30, 30)];
    [_leftButton setImage:[UIImage imageNamed:@"gerenzhongxin－daohanglan－fanhui"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(onbackView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftButton];
}
//点击左侧按钮的时候返回上一个页面
-(void)onbackView
{
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)addHeadView
{
    
    UserModel *modeled=[self.dataSource firstObject];
    UserBalanceModel *models=[self.balanceArray firstObject];
    NSLog(@"sdfadsfadsfsaf%@",modeled.sign);
   // UIImage *image=[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:modeled.bigAvatar]]]blurredImageWithRadius:8];
    [_headView.StarBigImage sd_setImageWithURL:[NSURL URLWithString:self.bgPicUrl]];
    [_headView.starUserImage sd_setImageWithURL:[NSURL URLWithString:modeled.avatar]];
    _headView.starNameLabel.text=modeled.nickName;
    
    
    [_headView.liveBtn setSelected:YES];
    _tempButton=_headView.liveBtn;
    
    if ([StringWithFormat(models.totalApplause) isEqualToString:@"0"])
    {
        _headView.tapNumber.text=@"0";
    }
    else
    {
        _headView.tapNumber.text=StringWithFormat(models.totalApplause);
    }
    
    NSLog(@"%@==========",models);
    
    
    [_headView.liveBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_headView.liveBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _headView.liveBtn.tag=250;
    [_headView.liveBtn addTarget:self action:@selector(changeStyle:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_headView.fansNumber setTitle:[NSString stringWithFormat:@"粉丝%@",StringWithFormat(modeled.fansCount)] forState:UIControlStateNormal];
    [_headView.fansNumber setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_headView.fansNumber setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _headView.fansNumber.tag=251;
    [_headView.fansNumber addTarget:self action:@selector(changeStyle:) forControlEvents:UIControlEventTouchUpInside];
    
    //点击他的星球按钮的时候挑转到他的星球主页
    [_headView.otherBtn addActionHandler:^(NSInteger tag) {
        ALLOC(WSOtherStarMainViewController, view);
        
        view.starId=self.starId;
        
        NSLog(@" ++++++++++%@",self.starId);
        view.isPresent=YES;
//        [self presentViewController:view animated:YES completion:^{
//            
//        }];
        [self.navigationController pushViewController:view animated:YES];
    }];
    
    //判断用户是否有签名 有加载签名 没有的时候加载默认的数据
    if ([StringWithFormat(modeled.sign) isEqualToString:@"(null)"])
    {
        _headView.starSignLabel.text=@"这家伙很懒，还没有签名";
    }
    else
    {
        _headView.starSignLabel.text=modeled.sign;
    }
    
    NSLog(@"++++++++++++++++++++++%d",_follow);
    if (_follow==false)
    {
        _headView.focusBtn.backgroundColor=UIColorFromRGB(0xFCC148);
        [ _headView.focusBtn setTitle:@"关注" forState:UIControlStateNormal];
        [ _headView.focusBtn setImage:[UIImage imageNamed:@"icon_jiahao"] forState:UIControlStateNormal];
        
    }
    else
    {
        _headView.focusBtn.backgroundColor=UIColorFromRGB(0xCCCCCC);
        [ _headView.focusBtn setTitle:@"已关注" forState:UIControlStateNormal];
        [ _headView.focusBtn setImage:nil forState:UIControlStateNormal];
        
    }
    
    //点击关注按钮相应的事件
    [_headView.focusBtn addActionHandler:^(NSInteger tag) {
        if (_follow==false)
        {
            [self addFocusDic:@{@"followUserId":modeled.userId,@"liveId":@"0"}];
            //NSLog(@"--------%@",_model.userId);
            NSLog(@"=====ddsf======%d",_follow);
                  }
        else
        {
            [self deleteFocus:@{@"followUserId":modeled.userId}];
            //NSLog(@"--------%@",_model.userId);
            NSLog(@"===========%d",_follow);
                     //            isFocus=YES;
            
        }
    }];
    
    
    
    
}

//请求星球的主人的信息
-(void)loadData
{
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/user/userInfo" parameters:@{@"userId":self.myUserId} isCache:NO succeed:^(id data) {
        UserModel *model=[UserModel mj_objectWithKeyValues:data[@"user"]];
        UserBalanceModel *balanmodel=[UserBalanceModel mj_objectWithKeyValues:data[@"userBalance"]];
        //添加掌声的Model
        [self.balanceArray addObject:balanmodel];
        //添加个人信息的Model
        [self.dataSource addObject:model];
        self.gag=[data[@"gag"] integerValue];
        _follow=[data[@"follow"] integerValue];
        self.black=[data[@"black"] integerValue];
        self.starId=data[@"starId"];
        
        self.bgPicUrl=data[@"bgPicUrl"];
        NSLog(@"+++++++++%@,====%d",data[@"follow"],_follow);
        NSLog(@"主人信息%@",data);
        
        [self addHeadView];
        
        self.userID=model.userId;
        

    } fail:^(NSString *error) {
        
    }];
}



//调用添加关注的接口地址 添加关注
-(void)addFocusDic:(NSDictionary *)dic
{
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/follow/add" parameters:dic isCache:NO succeed:^(id data) {
        [self.view makeToast:data[@"message"]];
        _headView.focusBtn.backgroundColor=UIColorFromRGB(0xCCCCCC);
        [_headView.focusBtn setTitle:@"已关注" forState:UIControlStateNormal];
        [_headView.focusBtn setImage:nil forState:UIControlStateNormal];
        //           isFocus=NO;
        _follow=true;

    } fail:^(NSString *error) {
        //[self.view makeToast:error];
    }];
}
//删除关注的方法
-(void)deleteFocus:(NSDictionary *)dic
{
    [CLNetworkingManager deleteRequestWithUrlString:@"/rest/follow/del" parameters:dic succeed:^(id data) {
        [self.view makeToast:data[@"message"]];
        
        _headView.focusBtn.backgroundColor=UIColorFromRGB(0xFCC148);
        [_headView.focusBtn setTitle:@"关注" forState:UIControlStateNormal];
        [_headView.focusBtn setImage:[UIImage imageNamed:@"icon_jiahao"] forState:UIControlStateNormal];
        _follow=false;

    } fail:^(NSString *error) {
        //[self.view makeToast:error];
    }];
}
//直播；列表
-(void)loadLives{
    [self.dictionary setObject:self.myUserId forKey:@"userId"];
    [self.dictionary setObject:cunrrenIndex forKey:@"pageIndex"];
    
    [[ViewModel shareViewModel]requestLivesApiurl:@"/rest/user/lives" parmters:self.dictionary succees:^(id responseProject) {
        
        self.liveArray=responseProject;
        [self.tableview reloadData];
        
        
    } fail:^(NSString *error) {
        
    }];
    
    
}
//加载粉丝列表
-(void)loadFansList:(NSString *)userID
{
    NSLog(@"粉丝：%@",userID);
    
       
    [[ViewModel shareViewModel]requestFansApiurl:@"/rest/fans/userList" parmters:@{@"pageIndex":cunrrenIndex,@"userId":userID} succees:^(id responseProject) {
        
        self.fansArray=responseProject;
        
        [self.tableview reloadData];
        
        
    } fail:^(NSString *error) {
        
    }];
    
    
}
-(void)changeStyle:(UIButton *)btn
{
    
    if (btn.selected==YES) {
        //当前的按钮是被选中的状态的时候不做任何的操作
    }
    else
    {
        [_tempButton setSelected:NO];
        [btn setSelected :YES];
        _tempButton=btn;
    }
    if (btn.tag==250)
    {
        _liveOne=YES;
        _headView.fansRedLabel.hidden=YES;
        _headView.liveRedLabel.hidden=NO;
        _liveBtnHide=YES;
        [self loadLives];

    }
    else if (btn.tag==251)
    {
        _liveOne=NO;
        _headView.liveRedLabel.hidden=YES;
        _headView.fansRedLabel.hidden=NO;
        _liveBtnHide=NO;
        [self loadFansList:self.userID];
        
    }
    
}
-(void)regisCell
{
    [ self.tableview registerNib:[UINib nibWithNibName:@"PersonLiveCell" bundle:nil] forCellReuseIdentifier:ONEFANSCELL];
    [ self.tableview registerNib:[UINib nibWithNibName:@"PersonFansCell" bundle:nil] forCellReuseIdentifier:TWOFANSCELL];
   
    
}

#pragma mark-UITabViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{//粉丝
    if (_liveOne==NO) {
        if (self.fansArray.count>0) {
            return  self.fansArray.count;
 
        }
        else
            return 1;
        
        
    }
    else
    {
        if (self.liveArray.count>0) {
                return  self.fansArray.count;
                
            }
            else
                return 1;
            
            
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (tableView== self.tableview)
    {
        
        if (_liveOne==YES)
        {
            if (self.liveArray.count>0) {

            PersonLiveCell *cell=[tableView dequeueReusableCellWithIdentifier:ONEFANSCELL];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;

                [cell starMainController:self.liveArray[indexPath.row]];
                           
                           
                   return cell;
            }
                       else{
                           LSHMessageTabCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LSHMessageTabCell"];
                           cell.selectionStyle=UITableViewCellSelectionStyleNone;
                           cell.tipLabel.hidden=YES;
                           cell.backgroundColor=[UIColor whiteColor];
                           NothingView *nothing=[[NothingView alloc]initWithFrame:CGRectMake(0, 80, cell.frame.size.width, 76)];
                           nothing.nothingMessage.text=@"暂时没有直播";
                           
                           nothing.nothingImage.image=IMAGE(@"meiyouzhibo1");
                           [cell.contentView addSubview:nothing];
                           
                           return cell;
                       }
          
         
            
        }
        else
        {
            
            if (self.fansArray.count>0) {
                
                PersonFansCell *cell=[tableView dequeueReusableCellWithIdentifier:TWOFANSCELL];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                UserFollow *model=self.fansArray[indexPath.row];
                
                if ([StringWithFormat(model.user.sign) isEqualToString:@""])
                {
                    cell.fansSign.text=@"";
                }
                else
                {
                    //赋值用户的签名
                    cell.fansSign.text=model.user.sign;
                }
                
                [cell cellFuzhi:model reload:^(NSString *tipLabel) {
                    [self.view makeToast:tipLabel];
                    
                    if ([tipLabel isEqualToString:@"已取消关注"]) {
                        model.mutual=@"0";
                        
                    }
                    else
                    {               model.mutual=@"1";
                        
                        
                    }
                    //改变被监控的关注数量刷新个人页面
                    [UserModel shareUserInfo].followCount=[NSString stringWithFormat:@"关注用户的ID%@",self.myUserId];
                    
                    [self.tableview reloadData];
                    
                    
                } type:12];
                return cell;
                
            }
            
            else
            {
                LSHMessageTabCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LSHMessageTabCell"];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.tipLabel.hidden=YES;
                cell.backgroundColor=[UIColor whiteColor];
                NothingView *nothing=[[NothingView alloc]initWithFrame:CGRectMake(0, 80, cell.frame.size.width, 76)];
                nothing.nothingMessage.text=@"主人还没有粉丝";
                
                nothing.nothingImage.image=IMAGE(@"meiyoufensi");
                [cell.contentView addSubview:nothing];
                
                return cell;

            }

            
        }
        
    }
    return nil;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *grayView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    grayView.backgroundColor=[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    grayView.alpha=0.5;
    if (section==0)
    {
        return grayView;
    }
    return grayView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_liveOne==YES)
    {
        if (self.liveArray.count<=0)
        {
            return 400;
        }
        else
            return 76;
    }
    else
    {
        if (self.fansArray.count<=0)
        {
            return 400;
        }
        else
            return 76;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了tableView的第%ld行第%ld列",(long)indexPath.section,indexPath.row );
    if (_liveOne==NO)
    {
        UserFollow *model=self.fansArray[indexPath.row];
        [self goVipOrNoVipWithVipString:model.user.vip withUserId:model.userId controller:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"offset---scroll:%f", self.tableview.contentOffset.y);
    UIColor *color=[UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1];
    CGFloat offset=scrollView.contentOffset.y;
    if (offset<0) {
        //self.navigationController.navigationBar.backgroundColor = [color colorWithAlphaComponent:0];
        self.backView.backgroundColor=[color colorWithAlphaComponent:0];
        if (offset<10)
        {
            [_userTitlelabel removeFromSuperview];
            
        }
    }else {
        CGFloat alpha=1-((64-offset)/64);
        if (offset>30)
        {
            [self.backView addSubview:_userTitlelabel];
            _userTitlelabel.text=_headView.starNameLabel.text;
            _userTitlelabel.textColor=[UIColor whiteColor];
        }
        self.backView.backgroundColor=[color colorWithAlphaComponent:alpha];
        //self.navigationController.navigationBar.backgroundColor=[color colorWithAlphaComponent:alpha];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
