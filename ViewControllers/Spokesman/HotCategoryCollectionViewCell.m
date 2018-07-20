//
//  HotCategoryCollectionViewCell.m
//  jinshanStrmear
//
//  Created by panhongliu on 2017/8/9.
//  Copyright © 2017年 王森. All rights reserved.
//

#import "HotCategoryCollectionViewCell.h"
#import "HotCategoryMakeMoneyCollectionViewCell.h"
#import "SpokesmanCollectionViewCell.h"

static NSString  *const sharemakeMoneyCollectionViewCell  =@"HotCategoryMakeMoneyCollectionViewCell";
static NSString  *const spokesmanCollectionViewCell  =@"SpokesmanCollectionViewCell";


@implementation HotCategoryCollectionViewCell


-(instancetype)init{
    
    if (self=[super init]) {
        NSLog(@"sddsds");
        
    }
    return self;
    
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        

    }
    
    return self;

}

-(void)initCollectionviewWithType:(MenuTypes)type{
    self.type=type;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _flowLayout= [[UICollectionViewFlowLayout alloc]init];
    
    _flowLayout.scrollDirection =UICollectionViewScrollDirectionHorizontal;
    _flowLayout.minimumLineSpacing = 5;
    self.collectionview.delegate=self;
    self.collectionview.dataSource=self;
    self.collectionview.collectionViewLayout=_flowLayout;
    self.collectionview.showsHorizontalScrollIndicator = NO;
    UINib *nib = [UINib nibWithNibName:sharemakeMoneyCollectionViewCell
                                bundle: [NSBundle mainBundle]];
    [self.collectionview registerNib:nib forCellWithReuseIdentifier:sharemakeMoneyCollectionViewCell];
    UINib *nibs = [UINib nibWithNibName:spokesmanCollectionViewCell
                                bundle: [NSBundle mainBundle]];
    [self.collectionview registerNib:nibs forCellWithReuseIdentifier:spokesmanCollectionViewCell];


    // Initialization code
}

-(void)setDataArray:(NSArray *)dataArray{
    _dataArray=dataArray;
    
    [self.collectionview reloadData];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type==SHAREMAKEMONEYS) {

    HotCategoryMakeMoneyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sharemakeMoneyCollectionViewCell forIndexPath:indexPath];
        if (_dataArray.count>0) {
            cell.model=_dataArray[indexPath.row];
         
            [cell.titleLabel addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                if (self.didselectTitle) {
                    self.didselectTitle(_dataArray[indexPath.row]);
                }
            }];
            
          
        }
        
        return cell;

    }
    else{
        SpokesmanCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:spokesmanCollectionViewCell forIndexPath:indexPath];
        if (_dataArray.count>0) {
            cell.model=_dataArray[indexPath.row];
            
        }
        
        return cell;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath

{
    if (self.type==SHAREMAKEMONEYS) {
        if (SCREEN_WIDTH<375) {
            return CGSizeMake(SCREEN_WIDTH-50,self.height);
        }
        return CGSizeMake(SCREEN_WIDTH-92*SHIJI_WIDTH,self.height);

 
    }else{
        return CGSizeMake(self.height,self.height);

    }

    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    self.dataArray[indexPath.row]
    
    if (self.selectRow) {
        self.selectRow(_dataArray[indexPath.row]);
        
    }
    
    
    
    
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(0, 10,0, 10);
    
    
}

@end
