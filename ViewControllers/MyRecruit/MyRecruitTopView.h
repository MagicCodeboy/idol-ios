//
//  MyRecruitTopView.h
//  jinshanStrmear
//
//  Created by panhongliu on 2016/11/29.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMAttributedLabel.h"

@interface MyRecruitTopView : UIView

+(id)AllocInitView;

@property (weak, nonatomic) IBOutlet NIMAttributedLabel *fansAttributeLabel;
//受益
@property (weak, nonatomic) IBOutlet NIMAttributedLabel *favourAttributeLabel;

@end
