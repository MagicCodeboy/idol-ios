//
//  BPPCalendar.h
//  Animation
//
//  Created by Onway on 2017/4/7.
//  Copyright © 2017年 Onway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"
typedef void(^SignWithStarDoneBlock)(BOOL isSignSuccess);
@interface BPPCalendar : UIView
@property (nonatomic,copy) SignWithStarDoneBlock signDoneBlock;
@property (nonatomic, strong) PersonModel *personModel;
@end
