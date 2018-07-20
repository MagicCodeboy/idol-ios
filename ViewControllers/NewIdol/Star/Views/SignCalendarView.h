//
//  SignCalendarView.h
//  jinshanStrmear
//
//  Created by lalala on 2018/3/20.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"
@protocol CalenderHaveSignDelegate <NSObject>
-(void)userHaveSignCurrentStarWithStarId:(NSInteger)StarId;
@end

@interface SignCalendarView : UIView

@property(nonatomic,weak) id<CalenderHaveSignDelegate> delegate;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *signRuleLabel;
@property (nonatomic, strong) UILabel *signRuleDetailLabel;
@property (nonatomic, strong) UIView *calendarView;
@property (nonatomic, strong) PersonModel *personModel;
@end
