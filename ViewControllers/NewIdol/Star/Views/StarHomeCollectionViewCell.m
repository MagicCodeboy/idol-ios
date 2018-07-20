//
//  StarHomeCollectionViewCell.m
//  jinshanStrmear
//
//  Created by lalala on 2018/3/19.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "StarHomeCollectionViewCell.h"
#import "UIimageView+WebCache.h"
#import "PersonModel.h"
@interface StarHomeCollectionViewCell ()

@end

@implementation StarHomeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}
-(void)settheCellModel:(PersonModel *)cellmodel{
    if (!cellmodel.sign) {
        if (cellmodel.personSignVideo.playUrl.length > 0) {
            self.theStarSignLabel.hidden = NO;
            self.theStarNameLabel.hidden = NO;
            self.videoImageVIew.hidden = NO;
//            NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
//            self.theStarNameLabel.text = [NSString stringWithFormat:@"@%@",[currentLanguage containsString:@"zh-Hans"] ? cellmodel.personNameCn : cellmodel.personNameEn];
            self.theStarNameLabel.text = [NSString stringWithFormat:@"@%@",cellmodel.name];
            self.theStarSignLabel.text = [NSString stringWithFormat:@"%@",cellmodel.personSignVideo.summary];
            [self.videoImageVIew sd_setImageWithURL:[NSURL URLWithString:cellmodel.personSignVideo.picUrl] placeholderImage:IMAGE(@"")];
        } else {
            self.theStarSignLabel.hidden = YES;
            self.theStarNameLabel.hidden = YES;
            self.videoImageVIew.hidden = YES;
            if (cellmodel.personSignPic.count > 0) {
                PersonSignPic *model=[cellmodel.personSignPic firstObject];
                [self.bottomImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:IMAGE(@"")];
            }
        }
    } else {
        if (cellmodel.personSignVideoHomePage.playUrl.length > 0) {
            self.theStarSignLabel.hidden = NO;
            self.theStarNameLabel.hidden = NO;
            self.videoImageVIew.hidden = NO;
            self.theStarNameLabel.text = [NSString stringWithFormat:@"@%@",cellmodel.name];
            self.theStarSignLabel.text = [NSString stringWithFormat:@"%@",cellmodel.personSignVideoHomePage.summary];
            [self.videoImageVIew sd_setImageWithURL:[NSURL URLWithString:cellmodel.personSignVideoHomePage.picUrl] placeholderImage:IMAGE(@"")];
        } else {
            self.theStarSignLabel.hidden = YES;
            self.theStarNameLabel.hidden = YES;
            self.videoImageVIew.hidden = YES;
            if (cellmodel.personSignPicHomePage.count > 0) {
                PersonSignPic *model=[cellmodel.personSignPicHomePage firstObject];
                [self.bottomImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:IMAGE(@"")];
            }
        }
    }
}

-(void)setbottomImage:(NSMutableArray *)array andIndex:(NSInteger)index {
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.bottomImageView.layer addAnimation:transition forKey:@"animationEaseOut"];
    if (array.count>0) {
        long randNum = index % array.count;
        NSLog(@"当前的下标值是%ld",randNum);
        PersonSignPic *model = array[randNum];
        [self.bottomImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:[UIImage imageNamed:@""]];
    }
  
}
-(void)removeLayerAndAnimation{
//    [self.bottomImageView.layer removeAnimationForKey:@"animationEaseOut"];
    [self.bottomImageView.layer removeAllAnimations];
}

@end
