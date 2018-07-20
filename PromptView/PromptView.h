//
//  PromptView.h
//  jinshanStrmear
//
//  Created by lalala on 16/6/22.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptView : UIView
//加载的没有数据的时候的各种提示图，需要的时候切换图片和message上的信息
+(id)inPutAlertView;
@property (weak, nonatomic) IBOutlet UIImageView *alertImage;
@property (weak, nonatomic) IBOutlet UILabel *alertMessage;
@property (weak, nonatomic) IBOutlet UIButton *goLook;

@end
