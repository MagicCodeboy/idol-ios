//
//  SpokesmanViewController.m
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import "SpokesmanViewController.h"
#import "RewardCollectionViewCell.h"
#import "SpokesmanCollectionViewCell.h"
#import "ShareMakeMoneyCollectionViewCell.h"
#import "HomeCollectionReusableView.h"
#import "HotRecommendCollectionViewCell.h"
#import "HotCategoryCollectionViewCell.h"
#import "MajorModel.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+EmptyDataSet.h"
#import "NSString+Tool.h"
#import "BaseWebViewViewController.h"
#import "UIView+Toast.h"
#import "CommoditManageViewController.h"
#import "LSHPersonViewController.h"
#import "TopGoodCollectionViewCell.h"
#import "TopGoodCollectionReusableView.h"
#import "ViewModel.h"
static   NSString * const spokesmanCollectionViewCell=@"SpokesmanCollectionViewCell";
static   NSString * const rewardCollectionViewCell=@"RewardCollectionViewCell";
static   NSString * const shareMakeMoneyCollectionViewCell=@"ShareMakeMoneyCollectionViewCell";
static   NSString * const hotRecommendCollectionViewCell=@"HotRecommendCollectionViewCell";
static   NSString * const hotCategoryCollectionViewCell=@"HotCategoryCollectionViewCell";
static NSString *const topGoodsCollectionViewCell =@"TopGoodCollectionViewCell";

static NSString *const topGoodsCollectionReusableView =@"TopGoodCollectionReusableView";


@interface SpokesmanViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,SDCycleScrollViewDelegate,EndorsementDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
    BOOL isHaveLoad;


}
@property(nonatomic,strong)NSMutableArray *recommendArray;
@property(nonatomic,strong)NSMutableArray *adversArray;

@property (nonatomic, strong) NSString *currentCateId;
@property (nonatomic, strong) NSString *CateGoryId;

@property(nonatomic,strong)NSMutableArray *categoriesArray;



@end

@implementation SpokesmanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewBackgroundColor:[UIColor whiteColor]];
    _CateGoryId=@"0";
    [self makeUI];
    
    
    
    // Do any additional setup after loading the view.
}

-(NSMutableArray *)adversArray
{
    if (!_adversArray) {
        _adversArray=@[].mutableCopy;
    }
    return _adversArray;
    
}


-(NSMutableArray *)categoriesArray
{
    if (_categoriesArray==nil)
    {
        _categoriesArray=[NSMutableArray array];
    }
    return _categoriesArray;
}
-(NSMutableArray *)recommendArray
{
    if (_recommendArray==nil)
    {
        _recommendArray=[NSMutableArray array];
    }
    return _recommendArray;
}

-(void)loadDataWithCateID:(NSString *)cateId isFromBack:(BOOL)isfromback
{
    if (cateId) {
        self.currentCateId=cateId;
    }
    if (isHaveLoad==NO) {
        isHaveLoad=YES;
        [self requestUrlWithID: self.currentCateId isRefresh:YES] ;
    }
    
    if (isfromback) {
        [CLNetworkingManager shareManager].hideBaseMBProgress=YES;
        [CLNetworkingManager shareManager].isHideErrorTip=YES;
        [self requestUrlWithID: self.currentCateId isRefresh:YES] ;
 
    }

    

}
-(void)requestUrlWithID:(NSString *)cateId isRefresh:(BOOL)isfresh
{
    if (isfresh) {
        self.currentIndex=1;
        [self.recommendArray removeAllObjects];
        [self.adversArray removeAllObjects];
        [self.categoriesArray removeAllObjects];
        
    }
    
    if (cateId==nil) {
        return;
    }
    [CLNetworkingManager shareManager].isHideErrorTip=YES;
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/recommend/cateConList" parameters:@{@"cataId":cateId,@"pageIndex":cunrrenIndex,@"categoryId":_CateGoryId} isCache:NO succeed:^(id data) {
         if (self.type==HOTRECOMMEND) {
             
             for (NSDictionary *dic in data[@"advertises"]) {
                 AdvertiseModel *model=[AdvertiseModel mj_objectWithKeyValues:dic];
                 [self.adversArray addObject:model];
                 
             }
             
             
             for (NSDictionary *dic in data[@"recommendCatagories"]) {
                 
                 RecommendCatagoriesModel*  allDatamodel =[RecommendCatagoriesModel mj_objectWithKeyValues:dic];
                 
                 [self.recommendArray addObject:allDatamodel];
                 
             }
             
         }else if(self.type==SHAREMAKEMONEY){
             for (NSDictionary *dic in data[@"shortVideoItems"]) {
                 
                 ShareVideoModelItem*  allDatamodel =[ShareVideoModelItem mj_objectWithKeyValues:dic];
                 
                 
                 [self.recommendArray addObject:allDatamodel];
                 
             }
             
         }
         else if(self.type==SPOKESNMANVC){
             for (NSDictionary *dic in data[@"storeModelItems"]) {
                 
                 GoodsNewItemModel*  allDatamodel =[GoodsNewItemModel mj_objectWithKeyValues:dic];
                 
                 
                 [self.recommendArray addObject:allDatamodel];
                 
             }
             
         }
         else if(self.type==TOPGOODS){
             for (NSDictionary *dic in data[@"goodsNewItemList"]) {
                 
                 GoodsNewItemModel*  allDatamodel =[GoodsNewItemModel mj_objectWithKeyValues:dic];
                 
                 
                 [self.recommendArray addObject:allDatamodel];
                 
             }
             
             for (NSDictionary *dic in data[@"goodsCategories"]) {
                 GoodsCategoriesModel *model=[GoodsCategoriesModel mj_objectWithKeyValues:dic];
                 [self.categoriesArray addObject:model];
                 
             }
             
         }
       

         [self.collectionView reloadData];
         
         [self collectionViewEndReFresh];
         
         NSLog(@"新版数据：%lu",(unsigned long)self.recommendArray.count);
     } fail:^(NSString *error) {
         [self collectionViewEndReFresh];

         if (self.currentIndex>1) {
             self.currentIndex--;
         }
        }];
    
    
    
}

-(void)makeUI{
    
    flowLayout= [[UICollectionViewFlowLayout alloc]init];
    
    flowLayout.scrollDirection =UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 10;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBARSTATUSBARHEIGHT-TabbarHeight-40) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor=[UIColor whiteColor];
    self.collectionView .showsVerticalScrollIndicator = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.emptyDataSetSource =self;
    
    self.collectionView.emptyDataSetDelegate =self;
    

    
    if (self.type==HOTRECOMMEND) {
        self.collectionView.backgroundColor=[UIColor whiteColor];

        [self.collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hxwHeader"];
        
        
        
        [self.collectionView registerNib:[UINib nibWithNibName:hotCategoryCollectionViewCell bundle:nil] forCellWithReuseIdentifier:hotCategoryCollectionViewCell];

        [self.collectionView registerNib:[UINib nibWithNibName:hotRecommendCollectionViewCell bundle:nil] forCellWithReuseIdentifier:hotRecommendCollectionViewCell];
        [self.collectionView registerNib:[UINib nibWithNibName:rewardCollectionViewCell bundle:nil] forCellWithReuseIdentifier:rewardCollectionViewCell];


    }
    
   else if (self.type==SHAREMAKEMONEY) {
        flowLayout.minimumLineSpacing = 10;
       [self.collectionView registerNib:[UINib nibWithNibName:shareMakeMoneyCollectionViewCell bundle:nil] forCellWithReuseIdentifier:shareMakeMoneyCollectionViewCell];
    }
    
    else if (self.type==SPOKESNMANVC) {
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing=5;
         [self.collectionView registerNib:[UINib nibWithNibName:spokesmanCollectionViewCell bundle:nil] forCellWithReuseIdentifier:spokesmanCollectionViewCell];
    }
    else if (self.type==TOPGOODS)
    {
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing=5;
        [self.collectionView registerNib:[UINib nibWithNibName:topGoodsCollectionViewCell bundle:nil] forCellWithReuseIdentifier:topGoodsCollectionViewCell];
        [self.collectionView registerClass:[TopGoodCollectionReusableView class ] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:topGoodsCollectionReusableView];
        
        
     
    }
    
    else{
        NSLog(@"哈哈哈");
        flowLayout.minimumLineSpacing = 0;
        
        [self.collectionView registerNib:[UINib nibWithNibName:rewardCollectionViewCell bundle:nil] forCellWithReuseIdentifier:rewardCollectionViewCell];

    }
   
    WeakSelf(weakSelf, self);

    [self setCollectionViewHeaderRefresh:^{
        [weakSelf endReFresh];
        
        weakSelf.currentIndex=1;
        [weakSelf requestUrlWithID:weakSelf.currentCateId isRefresh:YES];
        
    }];
    if (self.type!=HOTRECOMMEND) {
        [self setCollectionViewFooterfresh:^{
            weakSelf.currentIndex++;
            
            [weakSelf requestUrlWithID:weakSelf.currentCateId isRefresh:NO];
            
        }];
 
    }
   

    
    [self.view addSubview:self.collectionView];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView

{
    if (self.type==HOTRECOMMEND){
        return self.recommendArray.count+1;
    }else{
    return 1;
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.type==HOTRECOMMEND){
        RecommendCatagoriesModel *model=nil;
        if (section-1<self.recommendArray.count&&section>0) {
            model =self.recommendArray[section-1];
            
        }
        if (section==0) {
            return self.recommendArray.count>0?1:0;
        }
        if (section==1) {
            if (model.shareMoneyData.shortVideoItems.count>0) {
                return 1;
                
            }else{
                return 0;
                
            }
            
        }
        else if (section==2) {
            if (model.shareStoreData.storeModelItems.count>0) {
                return 1;
                
            }else{
                return 0;
                
            }
            
        }
        else if (section==3){
            return model.rewardAgentData.goodsNewItemList.count;
            
        }
        else{
            return 5;
            
        }
    }
    
    else
    {
      

        return self.recommendArray.count;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(weakself, self);

    if (self.type==HOTRECOMMEND){
        
        RecommendCatagoriesModel *model=nil;
        if (indexPath.section-1<self.recommendArray.count&&indexPath.section>0) {
                model =self.recommendArray[indexPath.section-1];
          
        }
        if (indexPath.section==0) {
            HotRecommendCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:hotRecommendCollectionViewCell forIndexPath:indexPath];
            cell.dataArray=self.adversArray;
            cell.adView.delegate=self;
            return cell;
        }
        else if (indexPath.section==1)
        {
            HotCategoryCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:hotCategoryCollectionViewCell forIndexPath:indexPath ];
            [cell initCollectionviewWithType:SHAREMAKEMONEYS];
            cell.dataArray=model.shareMoneyData.shortVideoItems;
            WeakSelf(weakself, self);
            [cell setSelectRow:^(id model){
               
                if ([model isKindOfClass:[ShareVideoModelItem class]]) {
                    ShareVideoModelItem *models=(ShareVideoModelItem*)model;
                    [weakself pushWebViewcontroller:models.url];
                }
                
                
            }];

            
            return cell;
            
        }
        else if (indexPath.section==2)
        {
            
            HotCategoryCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:hotCategoryCollectionViewCell forIndexPath:indexPath ];
            [cell initCollectionviewWithType:SPOKESNMANVCS];
            cell.dataArray=model.shareStoreData.storeModelItems;
            
            
           [cell setSelectRow:^(id model){
               if ([model isKindOfClass:[GoodsNewItemModel class]]) {
                   GoodsNewItemModel *models=(GoodsNewItemModel*)model;
                   [weakself pushWebViewcontroller:models.storeUrl];

                   
               }
               
               
           }];
            
            return cell;
        }
        
        else{
            
            RewardCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:rewardCollectionViewCell forIndexPath:indexPath ];
            cell.model=model.rewardAgentData.goodsNewItemList[indexPath.row];
            [cell addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                
                [weakself selectedIndexPath:indexPath];
                
            }];

            return cell;
        }
        
    }
    
    else if (self.type==SHAREMAKEMONEY) {
        
        ShareMakeMoneyCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:shareMakeMoneyCollectionViewCell forIndexPath:indexPath ];
        ShareVideoModelItem *model=self.recommendArray[indexPath.row];
        cell.model=model;
        [cell.titleLabel addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            LSHPersonViewController *controller=[[LSHPersonViewController alloc]initWithString:[NSString stringWithFormat:@"%ld",(long)model.shortStore.userId]];
            
            
            [self pushNextViewController:controller];
        }];
        [cell addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [weakself selectedIndexPath:indexPath];
            
        }];
        
                
        return cell;
    }
    
    else if (self.type==SPOKESNMANVC) {
        SpokesmanCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:spokesmanCollectionViewCell forIndexPath:indexPath ];
        cell.isBigView=YES;
        
        cell.model=self.recommendArray[indexPath.row];
        
        [cell addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [weakself selectedIndexPath:indexPath];
            
        }];
        return cell;
        
    }
    else if (self.type==TOPGOODS)
    {
        TopGoodCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:topGoodsCollectionViewCell forIndexPath:indexPath ];
        GoodsNewItemModel *model=self.recommendArray[indexPath.row];

        cell.model=model;
        cell.backgroundColor=[UIColor whiteColor];
        [cell addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [weakself pushWebViewcontroller:model.url];

            
        }];
        
        [cell.buyButton addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [weakself selectedIndexPath:indexPath];
            
        }];

        return cell;
    }
    else{
        
        RewardCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:rewardCollectionViewCell forIndexPath:indexPath ];
        cell.model=self.recommendArray[indexPath.row];
        cell.backgroundColor=[UIColor whiteColor];
        
        
        [cell addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            [weakself selectedIndexPath:indexPath];
            
        }];

        
        
        return cell;
        
        
    }
    
    
}

//定义并返回每个headerView或footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.type==HOTRECOMMEND){
        if (indexPath.section==0) {
            return nil;
            
        }else{
            HomeCollectionReusableView *header = [collectionView  dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hxwHeader"  forIndexPath:indexPath];
            if (indexPath.section-1<self.recommendArray.count) {
                RecommendCatagoriesModel *model=self.recommendArray[indexPath.section-1];
                header.model=model;
                WeakSelf(weakself, self);
                
                header.backgroundColor=[UIColor whiteColor];
                [header.moreButton addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                    if (weakself.selectCateMenu) {
                        
                        if (indexPath.section==1) {
                            weakself.selectCateMenu(model.shareMoneyData.more);
                        }
                       else  if (indexPath.section==2) {
                            weakself.selectCateMenu(model.shareStoreData.more);
                        }
                       else  if (indexPath.section==3) {
                           weakself.selectCateMenu(model.rewardAgentData.more);
                       }

                       
                    }
                }];
 
            }
            
                return header;
        }
    }
    else if (self.type==TOPGOODS)
    {
      TopGoodCollectionReusableView *header = [collectionView  dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:topGoodsCollectionReusableView  forIndexPath:indexPath];
        if (self.categoriesArray.count>0) {
            WeakSelf(weakself, self);
            
            header.dataArray = [NSMutableArray arrayWithArray:self.categoriesArray];
            [header setSelectedCateIdBlock:^(NSString *Id) {
                weakself.CateGoryId=Id;
                
                [weakself requestUrlWithID:self.currentCateId isRefresh:YES];
                
            }];
            
        }
        
        return header;
        
        
    }
    else{
        return nil;
    }

    
}


-(void)selectedIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%ld",(long)indexPath.row);

    NSString *url=nil;
    
    if (self.type==HOTRECOMMEND)
        
    {
        RecommendCatagoriesModel *model=nil;
        if (indexPath.section-1<self.recommendArray.count&&indexPath.section>0) {
            model =self.recommendArray[indexPath.section-1];
            
        }
        
       if (indexPath.section==3)
        {
             GoodsNewItemModel *models=model.rewardAgentData.goodsNewItemList[indexPath.row];

            url=models.url;

        }
        [self pushWebViewcontroller:url];
        return;

        
    }
    else if (self.type==SHAREMAKEMONEY) {
        ShareVideoModelItem *model=self.recommendArray[indexPath.row];
        url=model.url;
        
    }
    else if (self.type==SPOKESNMANVC) {
        GoodsNewItemModel *model=self.recommendArray[indexPath.row];
        url=model.storeUrl;
        
    }
    else if (self.type==TOPGOODS) {
        GoodsNewItemModel *model=self.recommendArray[indexPath.row];
        if (model.isOpenDetails) {
            url=model.url;
        }else
        {
            [self requestAddBuycar:model];
            
            return;
        }
        
        
    }
    [self pushWebViewcontroller:url];
    
    
}

-(void)requestAddBuycar:(GoodsNewItemModel*)model
{
    WeakSelf(weakslef, self);
    
    
    [[ViewModel shareViewModel]postRequestWithUrlType:AddBuyCar parmters:@{@"goodsId":[NSString stringWithFormat:@"%ld",model.goodsId]} succees:^(id responseProject) {
        
        [weakslef pushWebViewcontroller:responseProject[@"orderUrl"]];

    } fail:^(NSString *error) {
        
    }];
    
}


#pragma mark WebViewDelegate

-(void)jumpToSalingList
{
    [self requestUrlWithID:self.currentCateId isRefresh:YES];
    
    ALLOC(CommoditManageViewController, view);
    [self pushNextViewController:view];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.type==HOTRECOMMEND){
        if (section==0) {
            return CGSizeMake(0, 0);
  
        }else{
            return CGSizeMake(SCREEN_WIDTH, 60);

        }
    }
    else if (self.type == TOPGOODS)
    {
        return CGSizeMake(SCREEN_WIDTH, 49);
    }
    else{
        return CGSizeMake(0, 0);
    }
    
    
}


//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.type==HOTRECOMMEND)
    {
        if (indexPath.section==0) {
            return CGSizeMake(SCREEN_WIDTH,102*SHIJI_HEIGHT);
          }
        else if (indexPath.section==1)
        {
            return CGSizeMake(SCREEN_WIDTH,150);
 
        }else if (indexPath.section==2)
        {
            return CGSizeMake(SCREEN_WIDTH,147);

        }
        else if (indexPath.section==3) {
            return CGSizeMake(SCREEN_WIDTH,123);
            
        }
        
        else{
            return CGSizeMake(0,0);
            
        }

   
    }
    else if (self.type==SHAREMAKEMONEY) {
//        heightWithFont
        
        return CGSizeMake(SCREEN_WIDTH,100);
    }
    else if (self.type==SPOKESNMANVC) {
        return CGSizeMake((SCREEN_WIDTH-15)/2,(SCREEN_WIDTH-15)/2);
    }
    else if (self.type==TOPGOODS) {
        
        return CGSizeMake((SCREEN_WIDTH-15)/2,(SCREEN_WIDTH-15)/2+92);

    }

    else{
        return CGSizeMake(0,0);
 
    }

}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
    
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    if (self.type==HOTRECOMMEND) {
        return UIEdgeInsetsMake(0, 0,20, 0);

    
    }
   else  if (self.type==SHAREMAKEMONEY) {
        return UIEdgeInsetsMake(7, 0,0, 0);

    }
    else if (self.type==TOPGOODS) {
        return UIEdgeInsetsMake(0, 5,0, 5);
        
    }
    else{
        return UIEdgeInsetsMake(7, 5,0, 5);
    }
    
 
    
}

/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    
    
    if (self.type == 1) {
        
        
    }
    else{
        
        if (self.adversArray.count>0) {
            
            
            NSLog(@"---点击了第%ld张图片", (long)index);
           AdvertiseModel *  _advertiseModel = self.adversArray[index];
            
            NSInteger adId=[_advertiseModel.advertiseType integerValue];
            NSString * valueId=_advertiseModel.advertiseValue;
            
            NSLog(@"活动页的值：%@",valueId);
            //type  1-预告 2-直播 3-回放 4-活动 ,
            
            // 直播类型 0  回看1  预告2  *
            
            
            
            switch (adId) {
                case 1:
                   
                    
                    break;
                case 2:
                   
                    break;
                case 3:
                  
                    break;
                case 4:
                    if (ISNULL(valueId)) {
                        
                    }
                    else{
                        [self pushWebViewcontroller:valueId];
                        
                    }
                    
                    break;
                    
                case 5:
                    
                    [self pushPersonViewCOntroller:valueId];
                    
                    break;
                    
                    
                default:
                    
                    break;
            }
        }
    }
    
}

-(void)pushPersonViewCOntroller:(NSString *)userID
{
    
    [self goVipOrNoVipWithVipString:nil withUserId:userID controller:self];
    
}
-(void)pushWebViewcontroller:(NSString *)value
{
    if (value==nil) {
        [self.view makeToast:@"链接错误"];
        
        return;
    }
    ALLOC(BaseWebViewViewController, viewController);
    viewController.urlValue=value;
    
    viewController.chageFrame=YES;
    viewController.delegate=self;
    [self hiddenTabBar];
    
    [self pushNextViewController:viewController];
    
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


#pragma mark 空白页显示控制

//空白页图片

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    
    return [UIImage imageNamed:@"meiyouzhibo2"];
    
}


//空白页标题文本

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0f], NSForegroundColorAttributeName: UIColorFromRGB(0x999999)};
    return [[NSAttributedString alloc] initWithString:@"暂无内容" attributes:attributes];
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
