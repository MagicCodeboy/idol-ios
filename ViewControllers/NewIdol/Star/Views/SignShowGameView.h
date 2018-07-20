//
//  SignShowGameView.h
//  jinshanStrmear
//
//  Created by lalala on 2018/3/22.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TextShouldChangeBlock)();

@interface SignShowGameView : UIView

@property (nonatomic,copy) TextShouldChangeBlock changeTextBlock;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *starNameImageView;
@property (nonatomic, strong) UILabel *starNameLabel;
@property (nonatomic, strong) UIImageView *messageImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, assign) BOOL isNotFirstShow;

@property (nonatomic,copy) NSString *textString;
-(void)setlabelTextWithString:(NSString *)string;
-(void)cancelTheMainMethond;
-(void)updateNameLabelContainsWithString:(NSString *)nameString;
@end
