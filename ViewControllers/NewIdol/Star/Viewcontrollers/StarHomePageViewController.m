//
//  StarHomePageViewController.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "StarHomePageViewController.h"
#import "StarHomeCollectionViewCell.h"
#import "StarMenuView.h"
#import "UIButton+Block.h"
#import "UIButton+EnlargeEdge.h"

#import <libksygpulive/libksygpulive.h>

#import "KLCPopup.h"
#import "SignCalendarView.h"
#import "SignInView.h"

#import "DynamicListViewController.h"
#import "FetterViewController.h"
#import "ShopCenterViewController.h"

#import "MyMineViewController.h"
#import "MineView.h"
#import "TVViewController.h"

#import "SignShowGameView.h"
#import "CLNetworking.h"
#import "TotalMethodViewModel.h"
#import "PersonModel.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "AccountModel.h"
#import "FollowViewController.h"
#import "MSWeakTimer.h"
#import "UIColor+Category.h"
#import "UIScrollView+EmptyDataSet.h"
#import "TheAllViewController.h"

#import "NTESSessionListViewController.h"
#import "NTESSessionViewController.h"
#import "ChartExtend.h"
#import <NIMSDK/NIMSDK.h>
#import "UIView+Toast.h"
#import "CrowdfundingViewController.h"

#import "TotalMethodViewModel.h"


@interface StarHomePageViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CalenderHaveSignDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
{
    KLCPopup *popup;//添加的蒙版的视图
    int lastContentOffset;
    CGPoint startLocation;
    CGPoint endLocaltion;
}
@property (nonatomic, strong) SignInView *signView;
@property (nonatomic, strong) SignShowGameView *showGameView;
@property (nonatomic, strong) MineView *myMineView;
@property(nonatomic, strong) NSMutableArray *picArray;
@property(nonatomic, strong) MSWeakTimer *timer;
@property(nonatomic, assign) NSInteger currentCellIndex;
@property(nonatomic, strong) UIButton *starAboutButton;
@property(nonatomic, strong) UIButton *mineViewButton;
@property(nonatomic, strong) UIButton *comebackButton;
@property(nonatomic, strong) StarMenuView * starMenuView;
@property(nonatomic, assign) BOOL menuViewIsShow;
@property(nonatomic, strong) UIImageView *grayBackImageView;
@property (nonatomic, strong) SignCalendarView *signCalendarView;
@property(nonatomic,strong) KSYMoviePlayerController *player;
@property(nonatomic,assign) NSInteger picIndex;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizer;

@property (nonatomic, assign) BOOL isMoiveOrpic;
@property (nonatomic, assign) BOOL isShowMineView;
@property (nonatomic, assign) BOOL isSignCurrentStarOrNot;
@property(nonatomic, assign) BOOL dataDidLoad;
@property (nonatomic, assign) BOOL isAttentionOrNot;
@property (nonatomic, assign) BOOL isFirstEnter;

@property (nonatomic, strong) NSMutableArray *userAttenStarsArray;
@property (nonatomic, strong) NSMutableArray *thePlotTempArray;
@property (nonatomic, strong) NSMutableArray *needRefreshCellArray;
@property (nonatomic, strong) NSMutableArray *deleteCellArray;

@end

@implementation StarHomePageViewController
#pragma mark --lazy layout--
-(NSMutableArray *)deleteCellArray{
    if (_deleteCellArray == nil) {
        _deleteCellArray = [NSMutableArray array];
    }
    return _deleteCellArray;
}
-(NSMutableArray *)thePlotTempArray{
    if (_thePlotTempArray == nil) {
        _thePlotTempArray = [NSMutableArray array];
    }
    return _thePlotTempArray;
}
-(NSMutableArray *)userAttenStarsArray{
    if (_userAttenStarsArray == nil) {
        _userAttenStarsArray = [NSMutableArray array];
    }
    return _userAttenStarsArray;
}
-(SignCalendarView *)signCalendarView{
    if (_signCalendarView == nil) {
        _signCalendarView = [[SignCalendarView alloc] initWithFrame:CGRectMake(0, 0, 300, 330)];
        _signCalendarView.delegate = self;
        WeakSelf(weakSelf, self);
        [_signCalendarView.closeButton addActionHandler:^(NSInteger tag) {
            PersonModel *model = weakSelf.userAttenStarsArray[weakSelf.currentCellIndex];
            [CLNetworkingManager shareManager].hideBaseMBProgress = YES;
            [CLNetworkingManager shareManager].isHideErrorTip = YES;
            [[TotalMethodViewModel shareModel] requestPersonSignParmters:@{@"personId":@(model.personId)} succees:^(id response) {
                [weakSelf userHaveSignCurrentStarWithStarId:model.personId];
            } fail:^(id error) {
                
            }];
            [weakSelf.signCalendarView removeFromSuperview];
            [weakSelf disMissPopupView];
        }];
    }
    return _signCalendarView;
}
-(StarMenuView *)starMenuView{
    if (_starMenuView == nil) {
        _starMenuView = [[StarMenuView alloc] init];
        _starMenuView.theBottomView.transform = CGAffineTransformMakeScale(0.01f,0.01f);
    }
    return _starMenuView;
}
-(UIImageView *)grayBackImageView{
    if (_grayBackImageView == nil) {
        _grayBackImageView = [[UIImageView alloc] init];
        _grayBackImageView.backgroundColor = UIColorFromRGB(0x0B0B0B);
        _grayBackImageView.userInteractionEnabled = YES;
        WeakSelf(weakSelf, self);
        [_grayBackImageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakSelf clickStarAbout];
        }];
        _grayBackImageView.alpha = 0;
    }
    return _grayBackImageView;
}
-(UIButton *)starAboutButton{
    if (_starAboutButton == nil) {
        _starAboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _starAboutButton.hidden = NO;
        [_starAboutButton setImage:[UIImage imageNamed:@"diejia_-1"] forState:UIControlStateNormal];
    }
    return _starAboutButton;
}
-(UIButton *)mineViewButton{
    if (_mineViewButton == nil) {
        _mineViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mineViewButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [_mineViewButton setImage:[UIImage imageNamed:@"hanbao_diejia_liebiao_b"] forState:UIControlStateNormal];
    }
    return _mineViewButton;
}
-(UIButton *)comebackButton{
    if (_comebackButton == nil) {
        _comebackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _comebackButton.hidden = YES;
        [_comebackButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [_comebackButton setImage:[UIImage imageNamed:@"fanhui_b"] forState:UIControlStateNormal];
    }
    return _comebackButton;
}
-(NSMutableArray *)picArray{
    if (_picArray == nil) {
        _picArray = [NSMutableArray array];
    }
    return _picArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForentGround:)
                                                 name:@"enterForentGround"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackGround:)
                                                 name:@"enterBackGround"
                                               object:nil];
    _recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [_recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:_recognizer];
    
    self.picIndex = 0;
    [self setUpUI];
    [self setmineViewController];
    [self loadHaveAttenStarsData];
    
    
}
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        startLocation = [recognizer locationInView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded){
        endLocaltion = [recognizer locationInView:self.view];
        CGFloat dy = endLocaltion.y - startLocation.y;
        if (dy > 50) {
            if (self.userAttenStarsArray.count > 0) {
                PersonModel *model = self.userAttenStarsArray[self.currentCellIndex];
                NSLog(@"swipe up Distance: %f", dy);
                if (model.sign) {
                    //执行跳转到下一个界面的操作
                    [self pushToTheAllVCControllerWithModel:model andCurrentSelect:0];
                }
            }
        }
    }
}
-(void)pushToTheAllVCControllerWithModel:(PersonModel *)model andCurrentSelect:(NSInteger)pageIndex{
//    ALLOC(CrowdfundingViewController, theAllVc);
    
        ALLOC(TheAllViewController, theAllVc);
    theAllVc.model = model;
    theAllVc.currentSelect = pageIndex;
    theAllVc.isHaveShopOrNot = model.mallFlag;
    CATransition *transiton = [CATransition animation];
    transiton.duration = 0.25;
    transiton.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transiton.type = kCATransitionPush;
    transiton.subtype = kCATransitionFromTop;
    
    [self.navigationController.view.layer addAnimation:transiton forKey:nil];
    [self.navigationController pushViewController:theAllVc animated: NO];
}
-(void)enterForentGround:(NSNotification *)notification{
    if (self.isMoiveOrpic) {
        [self.player play];
    }
}
-(void)enterBackGround:(NSNotification *)notification{
    if (self.isMoiveOrpic) {
        [self.player pause];
    }
}
-(void)hiddenMineView{
    WeakSelf(weakSelf, self);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.myMineView.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}
-(void)setmineViewController{
    WeakSelf(weakSelf, self);
    if (_myMineView == nil) {
        _myMineView = [MineView createMyMineViewFromNib];
        _myMineView.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_myMineView.bottomButton addActionHandler:^(NSInteger tag) {
            [weakSelf hiddenMineView];
        }];
        [_myMineView.topButton addActionHandler:^(NSInteger tag) {
            [weakSelf hiddenMineView];
        }];
        [self.myMineView.userImageView sd_setImageWithURL:[NSURL URLWithString:[AccountModel read].avatar] placeholderImage:[UIImage imageNamed:@"morentouxiang"]];
        self.myMineView.userName.text = [AccountModel read].nickName;
        self.myMineView.userFansNumberLabel.text = [NSString stringWithFormat:@"%@",[AccountModel read].userId];
        [self.view addSubview:_myMineView];
    }
}
-(void)setUpUI{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
   
    [self.collectionView registerNib:[UINib nibWithNibName:@"StarHomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"StarHomeCollectionViewCell"];
    self.collectionView.backgroundView = [[UIImageView alloc]initWithImage:[UIColor getGradientImageFromColors:@[UIColorFromRGB(0x3E206A),UIColorFromRGB(0x191919)] gradientType:GradientTypeTopToBottom imgSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)]];
    
    WeakSelf(weakSelf, self);
    
    [self.view addSubview:self.collectionView];
    
    [self.starAboutButton addTarget:self action:@selector(clickStarAbout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mineViewButton];
    [self.view addSubview:self.comebackButton];
    [self.view addSubview:self.grayBackImageView];
    [self.view addSubview:self.starAboutButton];
    [self.view addSubview:self.starMenuView];
    self.starMenuView.buttonClick = ^(NSInteger tag) {
        PersonModel *model = weakSelf.userAttenStarsArray[weakSelf.currentCellIndex];
        
        switch (tag) {
            case 2000:
                 //视频
            {
//                ALLOC(TVViewController, viewC);
//                viewC.personId=model.personId;
//                [weakSelf pushNextViewController: viewC];
                [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:0];
            }
                break;
            case 2001:
                //动态
            {
//                ALLOC(DynamicListViewController, viewC);
//                viewC.personId=model.personId;
//                [weakSelf pushNextViewController: viewC];
                [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:1];
            }
                break;
            case 2002:
                //消息
                //动态
            {
                BOOL isInteam= [[NIMSDK sharedSDK].teamManager isMyTeam:model.teamId];
                
                if (isInteam) {
                    [weakSelf pushTeamSSessionViewController:model.teamId];
                }else
                {
                    [weakSelf joinTeamWithID:model.teamId block:^(BOOL success) {
                        if (success) {
                            [weakSelf pushTeamSSessionViewController:model.teamId];
                        }else{
                            [weakSelf.view makeToast:LocalizedStr(@"FailedjoinChart")];
                        }
                    }];
                    
                }
              
            }
                break;
            case 2003:
                //活动
            {
                [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:2];
            }
                
                break;
            case 2004:
                //点赞
            {
            
            }
                
                break;
            case 2005:
                //商城
            {
         
                [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:3];
            }
                break;
            case 2006:
                //图集
            {
//                 ALLOC(FetterViewController, fetterVc);
//                fetterVc.model = model;
//                 [weakSelf pushNextViewController: fetterVc];
                if (model.mallFlag) {
                    [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:2];
                } else {
                    [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:2];
                }
                
            }
                break;
            case 2007:
                //明星代币
            {
                if (model.mallFlag) {
                    [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:5];
                } else {
                    [weakSelf pushToTheAllVCControllerWithModel:model andCurrentSelect:4];
                }
            }
                break;
            case 2008:
                //关注按钮
            {
                PersonModel *model = weakSelf.userAttenStarsArray[weakSelf.currentCellIndex];
                if (model.follow) {
                    [weakSelf cancelattenPersonMethodWithPersonId:model.personId];
                } else {
                    [weakSelf attenPersonMethodWithPersonId:model.personId];
                }
            }
                break;
            default:
                break;
        }
    };
    [self.comebackButton addActionHandler:^(NSInteger tag) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [self.comebackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(TheTopMargin);
        make.height.equalTo(@17);
        make.width.equalTo(@20);
    }];
    [self.mineViewButton addActionHandler:^(NSInteger tag) {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//            weakSelf.myMineView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//            [weakSelf.view layoutIfNeeded];
//        } completion:^(BOOL finished) {
//
//        }];
        ALLOC(MyMineViewController, myMineVc);
        [weakSelf pushNextViewController: myMineVc];
    }];
    [self.mineViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.centerY.mas_equalTo(self.comebackButton);
        make.height.equalTo(@17);
        make.width.equalTo(@20);
    }];
    [self.grayBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_offset(0);
    }];
    [self.starAboutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.bottom.mas_offset(-40);
        make.height.width.equalTo(@45);
    }];
    [self.starMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.starAboutButton.mas_top);
        make.centerX.width.mas_equalTo(self.starAboutButton);
        make.height.equalTo(@250);
    }];
}
-(void)loadHaveAttenStarsData{
    WeakSelf(weakSelf, self);
    [CLNetworkingManager  getNetworkRequestWithUrlString:@"/follow/userfollowpersons" parameters:nil isCache:NO succeed:^(id data) {
        if (weakSelf.currentIndex == 1) {
            [weakSelf.userAttenStarsArray removeAllObjects];
        }
        for (NSDictionary *dic in data[@"personList"]) {
            PersonModel *model = [PersonModel mj_objectWithKeyValues:dic];
            [weakSelf.userAttenStarsArray addObject:model];
        }
        if (weakSelf.userAttenStarsArray.count <= 0) {
            [[AppDelegate shareInstance] goFollowView];
            AccountModel *model=[AccountModel read];
            model.followerNum=0;
            [AccountModel update:model];
            return ;
        }
        [self.collectionView reloadData];
        self.collectionView.emptyDataSetSource = self;
        self.collectionView.emptyDataSetDelegate = self;
        [self.collectionView reloadEmptyDataSet];
        
        self.dataDidLoad=YES;
        [self collectionViewEndReFresh];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf signRulesMethoned];
        });
    } fail:^(NSString *error) {
        [self collectionViewEndReFresh];
    }];
}
-(void)clickStarAbout{
    
    
    if (_menuViewIsShow) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.starMenuView.theBottomView.transform = CGAffineTransformMakeScale(0.01f,0.01f);
            [self.starMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            self.grayBackImageView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.grayBackImageView.hidden = YES;
        }];
    } else {
        PersonModel *personModel = self.userAttenStarsArray[self.currentCellIndex];
        [self.starMenuView setViewWithButtonArrays:@[] andHaveShopOrNot:personModel.mallFlag];
        self.starMenuView.theBottomView.transform = CGAffineTransformMakeScale(0.01f,0.01f);
        [self.starMenuView.starImageView sd_setImageWithURL:[NSURL URLWithString:personModel.avatar] placeholderImage:[UIImage imageNamed:@"morentouxiang"]];
        self.starMenuView.attentionButton.selected = personModel.follow;
        self.starMenuView.fansNumberLabel.text = personModel.followNum;
        self.grayBackImageView.hidden = NO;
        CGFloat theMenuViewHeight = 250;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.starMenuView.theBottomView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            [self.starMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(theMenuViewHeight));
            }];
            self.grayBackImageView.alpha = 0.6;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
    self.menuViewIsShow = !self.menuViewIsShow;
}

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    StarHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StarHomeCollectionViewCell" forIndexPath:indexPath];
    PersonModel *model = self.userAttenStarsArray[indexPath.row];
    [cell removeLayerAndAnimation];
    if (self.isMoiveOrpic == YES) {
        //视频
        [self removeMyPlayer];
    } else {
        //图片
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    [cell settheCellModel:model];
    cell.tag = model.personId;
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userAttenStarsArray.count;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        // 将collectionView在控制器view的中心点转化成collectionView上的坐标
        CGPoint pInView = [self.view convertPoint:self.collectionView.center toView:self.collectionView];
        // 获取这一点的indexPath
        NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];
        
        self.currentCellIndex = indexPathNow.row;
        [self.userAttenStarsArray enumerateObjectsUsingBlock:^(PersonModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!model.follow) {
                *stop = YES;
                if (*stop == YES) {
                    [self.userAttenStarsArray removeObject:model];
                    [self.collectionView reloadData];
                    if (self.collectionView.contentOffset.x > lastContentOffset) {
                        //向右
                        if (self.currentCellIndex - 1 >= 0) {
                            self.collectionView.contentOffset = CGPointMake(SCREEN_WIDTH *(self.currentCellIndex - 1), SCREEN_HEIGHT);
                            self.currentCellIndex = self.currentCellIndex - 1;
//                            NSLog(@"当前的下标%ld",self.currentCellIndex);
//                            [self signRulesMethoned];
                            //                            });
                        }
                    } else {
                       
                    }
                }
            }
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //向左
            NSLog(@"当前的下标%ld",self.currentCellIndex);
            [self signRulesMethoned];
        });
        
        
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        lastContentOffset = scrollView.contentOffset.x;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self didScrolDellocObjc];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [[NIMSDK sharedSDK].teamManager quitTeam:@"436381041" completion:^(NSError * _Nullable error) {
//
//        }];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[NIMSDK sharedSDK].teamManager applyToTeam:@"436381041" message:@"" completion:^(NSError * _Nullable error, NIMTeamApplyStatus applyStatus) {
//
//            }];
//        });

//    });
    self.picIndex = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.dataDidLoad) {
        [self signRulesMethoned];
    }
}
-(void)signRulesMethoned{
    if (self.userAttenStarsArray.count <= 0) {
        return;
    }
    PersonModel *model = self.userAttenStarsArray[self.currentCellIndex];
    NSLog(@"当前的页面的index是%ld  当前的明星是否已经签到了%d",self.currentCellIndex,model.sign);
    if (!model.sign) {
        self.starAboutButton.hidden = NO;
        //没有签到走的流程
        if (model.personPlotSignBefore.count <= 0) {
            [self showSignCalendarView];
        } else {
            [self.thePlotTempArray removeAllObjects];
            for (PersonPlotModel *plotModel in model.personPlotSignBefore) {
                [self.thePlotTempArray addObject:plotModel.content];
            }
            [self showStarGameViewModel:model];
            [self.showGameView setlabelTextWithString:[self.thePlotTempArray firstObject]];
            [self.thePlotTempArray removeObjectAtIndex:0];
        }
    } else {
        self.starAboutButton.hidden = NO;
        if (self.isFirstEnter == NO) {
            [self showTheStarAboutView];
            self.isFirstEnter = YES;
        }
    }
    [self showCollectionCellAnimation:model];
}
-(void)showCollectionCellAnimation:(PersonModel *)model{
    [self didScrolDellocObjc];
    
//    NSArray *array = [self.collectionView visibleCells];
//    StarHomeCollectionViewCell *starCell = [array firstObject];
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:self.currentCellIndex inSection:0];
    StarHomeCollectionViewCell *starCell = (StarHomeCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
    if (model.sign) {
        if (model.personSignVideoHomePage.playUrl.length > 0) {
            //视频
            [self playCurrentCellVideoWithCell:starCell andCellModel:model.personSignVideoHomePage];
        } else {
            //图片
            [self animationPicWithCell:starCell andCellModel:model.personSignPicHomePage];
        }
    } else {
        if (model.personSignVideo.playUrl.length > 0) {
            //视频
            [self playCurrentCellVideoWithCell:starCell andCellModel:model.personSignVideo];
        } else {
            //图片
            [self animationPicWithCell:starCell andCellModel:model.personSignPic];
        }
    }
}
-(void)playCurrentCellVideoWithCell:(StarHomeCollectionViewCell *)starCell andCellModel:(PersonSignVideoModel *)model{
    [self setVideoPlayerWithString:model.playUrl];
    [self.player prepareToPlay];
    self.player.view.frame = starCell.playerView.bounds;
    self.player.view.contentMode = UIViewContentModeScaleAspectFill;
    [starCell.playerView addSubview:self.player.view];
    self.isMoiveOrpic = YES;
}
-(void)animationPicWithCell:(StarHomeCollectionViewCell *)starCell andCellModel:(NSMutableArray *)picArray{
    self.picArray = picArray;
    if (self.timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:4
                                                      target:self
                                                    selector:@selector(mainThreadTimerDidFire:)
                                                    userInfo:nil
                                                     repeats:YES
                                               dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
    self.isMoiveOrpic = NO;
}
-(void)mainThreadTimerDidFire:(MSWeakTimer *)timer{
    NSArray *cellArray = [self.collectionView visibleCells];
    StarHomeCollectionViewCell *cell = [cellArray firstObject];
    PersonModel *model = self.userAttenStarsArray[self.currentCellIndex];
    if (cell.tag == model.personId) {
        [cell setbottomImage:self.picArray andIndex:self.picIndex++];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self didScrolDellocObjc];
}
-(void)didScrolDellocObjc{
    NSArray *cellArray = [self.collectionView visibleCells];
    for (int i = 0; i < cellArray.count; i++) {
        StarHomeCollectionViewCell *cell = cellArray[i];
        [cell removeLayerAndAnimation];
    }
    if (self.isMoiveOrpic == YES) {
        //视频
        [self removeMyPlayer];
    } else {
        //图片
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}
-(void)showSignViewWithModel:(PersonPlotModel *)plotModel{
    if (_signView == nil) {
        _signView = [[SignInView alloc] init];
        self.signView.frame = self.view.bounds;
        [self.view addSubview:self.signView];
    }
    PersonModel *model = self.userAttenStarsArray[self.currentCellIndex];
    self.signView.starNameLabel.text = model.name;
    self.signView.messageLabel.text = plotModel.content;
    [self.signView updateNameLabelContainsWithNameString:model.name];
    WeakSelf(weakSelf, self);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.signView.alpha = 1;
    } completion:^(BOOL finished) {
        [weakSelf.signView showGoldCoindsViewWithPicName:nil];
        [UIView animateWithDuration:0.5 delay:2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.signView.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf.signView removeFromSuperview];
            weakSelf.signView = nil;
            [self signRulesMethoned];
        }];
    }];
}
-(void)showStarGameViewModel:(PersonModel *)model{
    if (_showGameView == nil) {
        _showGameView = [[SignShowGameView alloc] init];
        _showGameView.frame = self.view.bounds;
        [self.view addSubview:_showGameView];
        _showGameView.starNameLabel.text = model.name;
        [_showGameView updateNameLabelContainsWithString:model.name];
        WeakSelf(weakSelf, self);
        _showGameView.changeTextBlock = ^{
            if (weakSelf.thePlotTempArray.count > 0) { //剧情
                [weakSelf.showGameView setlabelTextWithString:[weakSelf.thePlotTempArray firstObject]];
                [weakSelf.thePlotTempArray removeObjectAtIndex:0];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.showGameView removeFromSuperview];
                    weakSelf.showGameView = nil;
                    [weakSelf showSignCalendarView];
                    NSLog(@"剧情走完了 执行后续的操作");
                });
                [NSThread exit];
            }
        };
        [_showGameView.skipButton addActionHandler:^(NSInteger tag) {
            PersonModel *model = weakSelf.userAttenStarsArray[weakSelf.currentCellIndex];
            weakSelf.isShowMineView = NO;
            [weakSelf.showGameView cancelTheMainMethond];
            [weakSelf.showGameView removeFromSuperview];
            weakSelf.showGameView = nil;
            if (model.sign) {
                weakSelf.starAboutButton.hidden = NO;
            } else {
                [weakSelf showSignCalendarView];
            }
        }];
    }
    WeakSelf(weakSelf, self);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.showGameView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)showTheStarAboutView{
    PersonModel *personModel = self.userAttenStarsArray[self.currentCellIndex];
    [self.starMenuView setViewWithButtonArrays:@[] andHaveShopOrNot:personModel.mallFlag];
    [self.starMenuView.starImageView sd_setImageWithURL:[NSURL URLWithString:personModel.avatar] placeholderImage:[UIImage imageNamed:@"morentouxiang"]];
    self.starMenuView.attentionButton.selected = personModel.follow;
    self.starMenuView.fansNumberLabel.text = personModel.followNum;
    self.grayBackImageView.hidden = NO;
    CGFloat theMenuViewHeight = 250;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.starMenuView.theBottomView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [self.starMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(theMenuViewHeight));
        }];
        self.grayBackImageView.alpha = 0.6;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    self.menuViewIsShow = true;
}
- (void)showSignCalendarView{
    if (self.userAttenStarsArray.count > 0) {
        PersonModel *model = self.userAttenStarsArray[self.currentCellIndex];
        self.signCalendarView.personModel = model;
    }
    KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)KLCPopupHorizontalLayoutCenter,
                                               (KLCPopupVerticalLayout)KLCPopupVerticalLayoutCenter);
    popup = [KLCPopup popupWithContentView:self.signCalendarView
                                  showType:KLCPopupShowTypeFadeIn
                               dismissType:KLCPopupDismissTypeFadeOut
                                  maskType:KLCPopupMaskTypeClear
                  dismissOnBackgroundTouch:NO
                     dismissOnContentTouch:NO];
    [popup showWithLayout:layout duration:0.0];
    [popup show];
}
- (void)disMissPopupView{
    [self.signCalendarView removeFromSuperview];
    self.signCalendarView = nil;
    [popup dismiss:YES];
}
#pragma mark --CalenderHaveSignDelegate--
- (void)userHaveSignCurrentStarWithStarId:(NSInteger)StarId{
    PersonModel *model = self.userAttenStarsArray[self.currentCellIndex];
    model.sign = YES;//签到成功 改变数组中的数据
    self.starAboutButton.hidden = NO;
    NSArray *cellArray = [self.collectionView visibleCells];
    StarHomeCollectionViewCell *cell = [cellArray firstObject];
    [cell settheCellModel:model];
    
    [self.needRefreshCellArray removeAllObjects];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.currentCellIndex inSection:0];
    [self.needRefreshCellArray addObject:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:self.needRefreshCellArray];
    
    [self disMissPopupView];
    if (model.personPlotSignAfter.count > 0) {
        [self showSignViewWithModel:[model.personPlotSignAfter firstObject]];
    }
    [self showTheStarAboutView];
}

#pragma mark --videoPlayer--
- (void)setVideoPlayerWithString:(NSString *)playerString{
    if (_player == nil) {
        _player = [[KSYMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:playerString]];
        _player.scalingMode = MPMovieScalingModeAspectFill;
        _player.shouldLoop = YES;
        _player.shouldAutoplay = YES;
    }
}
- (void)removeMyPlayer {
    [self stopPlayer];
    if (self.player) {
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
}

- (void)stopPlayer {
    @try {
        [self.player stop];
    } @catch (NSException *exception) {
        NSLog(@"崩溃了%@",exception);
    }
}
- (void)attenPersonMethodWithPersonId:(NSInteger)personId{
    WeakSelf(weakSelf, self);
    PersonModel *personModel = self.userAttenStarsArray[self.currentCellIndex];

    [[TotalMethodViewModel shareModel] requestPersonAttentionParmters:@{@"personId":@(personId)} succees:^(id response) {
        PersonModel *model = weakSelf.userAttenStarsArray[weakSelf.currentCellIndex];
        model.follow = YES;
        weakSelf.starMenuView.attentionButton.selected = model.follow;
        [self joinTeamWithID:personModel.teamId block:^(BOOL success) {
           
        }] ;

    } fail:^(id error) {
        
    }];
}
- (void)cancelattenPersonMethodWithPersonId:(NSInteger)personId{
    WeakSelf(weakSelf, self);
    PersonModel *personModel = self.userAttenStarsArray[self.currentCellIndex];
   
    [[NIMSDK sharedSDK].teamManager  quitTeam:personModel.teamId completion:^(NSError * _Nullable error) {
        if (error==nil) {
            NSLog(@"退出群成功");
            
            [[TotalMethodViewModel shareModel] requestPersonCancelAttentionParmters:@{@"personId":@(personId)} succees:^(id response) {
                PersonModel *model = weakSelf.userAttenStarsArray[weakSelf.currentCellIndex];
                model.follow = NO;
                weakSelf.starMenuView.attentionButton.selected = model.follow;
                if (self.userAttenStarsArray.count == 1) {
                    [self didScrolDellocObjc];
                    [[AppDelegate shareInstance] goFollowView];
                    AccountModel *model=[AccountModel read];
                    model.followerNum=0;
                    [AccountModel update:model];
                }
            } fail:^(id error) {
                
            }];
        }else{

        }

    }];

}

- (void)joinTeamWithID:(NSString *)teamId block:(void(^)(BOOL success))reqult{
    
    [[NIMSDK sharedSDK].teamManager applyToTeam:teamId message:@"" completion:^(NSError * _Nullable error, NIMTeamApplyStatus applyStatus) {
        if (error==nil) {
            reqult(YES);
        }else{
            reqult(NO);

        }
        NSLog(@"已经申请加群状态%ld",(long)applyStatus);
    }];
    
}

- (void)pushTeamSSessionViewController:(NSString *)teamId{
    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
    
    NTESSessionViewController *VC=[[NTESSessionViewController alloc]initWithSession:session];
    
    [self pushNextViewController: VC];
}
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if ([CLNetworkingManager theNetworkStatus]==0) {
        
        return [UIImage imageNamed:@"nonetwork"];
    }else{
        
        return [UIImage imageNamed:@"nodata"];
    }
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView{
    return YES;
}
- (void)emptyDataSetDidTapView:(UIScrollView *)scrollVie{
    [self loadHaveAttenStarsData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterForentGround" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterBackGround" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
