//
//  MyRecruitViewController.m
//  jinshanStrmear
//
//  Created by panhongliu on 2016/11/29.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "MyRecruitViewController.h"
#import "MyRecruitTopView.h"
#import "OtherUserToolBarView.h"
#import "UIButton+Block.h"
#import "MyRecruitTableViewCell.h"
#import "ViewModel.h"
@interface MyRecruitViewController ()
@property(nonatomic,strong)  MyRecruitTopView *topView;
@property(nonatomic,strong)OtherUserToolBarView *toolBarView;

@property(nonatomic,strong)NSArray *currentDataArray;
@property(nonatomic,strong)LiveShare *liveShareModel;
@property(nonatomic,strong)RecruitUserExtend *userExtendModel;



@end

@implementation MyRecruitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"我的招募";
    [self setViewBackgroundColor:nil];
    [self addBackBtn];
    [self customTableView];
    
    
    [self registerNib:@"MyRecruitTableViewCell"];
    [self loadData:YES];
    
    
    self.tableview.frame=CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-49);
    _toolBarView=[OtherUserToolBarView inPutToolBarView];
    _toolBarView.frame=CGRectMake(0, SCREEN_HEIGHT-49, SCREEN_WIDTH, 49);
    _toolBarView.backgroundColor=REDCOLOR;
    [self.view addSubview:_toolBarView];
   
    @weakify(self);

    [self setTableHeaderRefresh:^{
        @strongify(self);

        self.currentIndex=1;
        
        [self loadData:YES];
        
    }];
    
    [self setFooterfresh:^{
       
        @strongify(self);
        self.currentIndex++;
        
        [self loadData:NO];

    }];
    
    
    [_toolBarView.followButton setTitle:@"微信好友招募" forState:UIControlStateNormal];
    [_toolBarView.connectButton setTitle:@"朋友圈招募" forState:UIControlStateNormal];
    BUTTON_SETIMAGE(_toolBarView.followButton, @"fenxiang_weixin");
    BUTTON_SETIMAGE(_toolBarView.connectButton, @"fenxiang_pengyouquan");
    BUTTON_TITLECOLOR(_toolBarView.followButton, [UIColor whiteColor]);
     BUTTON_TITLECOLOR(_toolBarView.connectButton, [UIColor whiteColor]);
    
    [_toolBarView.followButton addActionHandler:^(NSInteger tag) {
        NSLog(@"ss");
        @strongify(self);

        [self setShareDataWithTag:601];
        
    }];
    [_toolBarView.connectButton addActionHandler:^(NSInteger tag) {
        NSLog(@"ssww");
        @strongify(self);

        [self setShareDataWithTag:600];
        
        
    }];
    

    
    
    // Do any additional setup after loading the view.
}


-(void)setShareDataWithTag:(NSInteger)tag{
     [self Allshare:tag controller:self shareUrl: self.liveShareModel.url title: self.liveShareModel.title contentValue: self.liveShareModel.content picUrl: self.liveShareModel.picUrl isFirstShare:YES];
}

-(void)loadData:(BOOL )isFresh
{
    @weakify(self);
    
    [[ViewModel shareViewModel]restFollowUserShareApiurl:nil parmters:@{@"pageIndex":cunrrenIndex} isRefresh:isFresh succees:^(NSArray *responseProject,LiveShare *liveShaModel,RecruitUserExtend *extendModel) {
        @strongify(self);

        self.currentDataArray=responseProject;
        if(self.currentIndex==1)
        {
            self.liveShareModel=liveShaModel;
            self.userExtendModel=extendModel;
            [self setUserExtendWithMdoel:self.userExtendModel];


        }
        [self endReFresh];
        
        [self.tableview reloadData];
        
        
    } fail:^(NSString *error) {
        [self endReFresh];

    }];
    
}


-(void)setUserExtendWithMdoel:(RecruitUserExtend*)model
{
    
    self.topView=[MyRecruitTopView AllocInitView];
    self.topView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 220);
    self.topView.fansAttributeLabel.numberOfLines = 0;
    
    self.tableview.tableHeaderView=self.topView;
    

    UIImage *image = [UIImage imageNamed:@"fensituanrenshu"];
    UIImage *renimage = [UIImage imageNamed:@"ren"];
    
    [self.topView.fansAttributeLabel appendImage:image maxSize:image.size margin:UIEdgeInsetsMake(0, 0, 0, 5) alignment:NIMImageAlignmentCenter];
    
    NSString *fansString=[NSString stringWithFormat:@"%d",model.shareFansCount];
    
    
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:fansString];
    [aAttributedString addAttribute:NSForegroundColorAttributeName  //文字颜色
                              value:[UIColor redColor]
                              range:NSMakeRange(0, fansString.length)];
    [aAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28] range:NSMakeRange(0,fansString.length)];
    
    [self.topView.fansAttributeLabel appendAttributedText:aAttributedString];
    [self.topView.fansAttributeLabel appendImage:renimage maxSize:renimage.size margin:UIEdgeInsetsMake(0, 5, 0, 0) alignment:NIMImageAlignmentCenter];
    
    self.topView.fansAttributeLabel.textAlignment=kCTTextAlignmentCenter;
    
    
    
    
    UIImage *favourimage1 = [UIImage imageNamed:@"fensituanshouyi"];
    
    UIImage *favourimage2 = [UIImage imageNamed:@"zhangshenglabel"];
    
    [self.topView.favourAttributeLabel appendImage:favourimage1 maxSize:image.size margin:UIEdgeInsetsMake(0, 0, 0, 5) alignment:NIMImageAlignmentCenter];
    
    
    
    NSString *favourString=[NSString stringWithFormat:@"%d",model.shareFansApplause];;
    
    
    NSMutableAttributedString * favourAttributedString = [[NSMutableAttributedString alloc] initWithString:favourString];
    [favourAttributedString addAttribute:NSForegroundColorAttributeName  //文字颜色
                                   value:[UIColor redColor]
                                   range:NSMakeRange(0, favourString.length)];
    [favourAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28] range:NSMakeRange(0,favourString.length)];
    
    [self.topView.favourAttributeLabel appendAttributedText:favourAttributedString];
    [self.topView.favourAttributeLabel appendImage:favourimage2 maxSize:favourimage2.size margin:UIEdgeInsetsMake(0, 5, 0, 0) alignment:NIMImageAlignmentCenter];
    
    self.topView.favourAttributeLabel.textAlignment=kCTTextAlignmentCenter;
    

    
    
}
-(void)dealloc
{
    
    NSLog(@"测试...........");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyRecruitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyRecruitTableViewCell"];
           cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row<3) {
        cell.backImageView.hidden=NO;
        cell.nameLeftContant.constant=58;
        cell.xuHaoImageView.hidden=NO;
            NSArray *array=@[@"diyiming-touxiangbeijing",@"dierming-touxiangbeijing",@"disanming-touxiangbeijing"];
            cell.backImageView.image=[UIImage imageNamed:array[indexPath.row]];
    NSArray*xuhaoarray=@[@"myRecruit1",@"myRecruit2",@"myRecruit3"];
        cell.xuHaoImageView.image=[UIImage imageNamed:xuhaoarray[indexPath.row]];;

        
    }
    else
    {
        cell.backImageView.hidden=YES;
        cell.nameLeftContant.constant=13;
        cell.xuHaoImageView.hidden=YES;

        
    }
    
    if (self.currentDataArray.count>0) {
        
        [cell cellFuzhiWithModel:self.currentDataArray[indexPath.row]];
        
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentDataArray.count>0) {
        
        UserSendStatsModel *model=self.currentDataArray[indexPath.row];
        //判断用户的类型 点击的时候进入不同的个人主页的页面
        [self goVipOrNoVipWithVipString:model.user.vip withUserId:model.user.userId controller:self];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<3) {
        return 76;
    }
    else
    {
        return 64;
   
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    return view;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.isDealWithSpecialFrame=YES;
    [self hiddenTabBar];
    
    
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
