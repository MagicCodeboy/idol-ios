//
//  StarHomeCollectionViewCell.h
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonModel;
@interface StarHomeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UILabel *theStarNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *theStarSignLabel;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageVIew;
@property (nonatomic, strong) NSTimer *timer;

//图片的展示效果
-(void)setbottomImage:(NSMutableArray *)array andIndex:(NSInteger)index;
-(void)settheCellModel:(PersonModel *)cellmodel;
-(void)removeLayerAndAnimation;
////视频的播放与关闭
//-(void)setPlayWithUrl:(NSString *)urlString;
//-(void)removeMyPlayer;
@end
