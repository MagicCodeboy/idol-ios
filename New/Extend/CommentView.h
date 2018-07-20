//
//  CommentView.h
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/22.
//  Copyright © 2018年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTextView.h"

typedef void (^TextViewChangeBlock)(CGFloat height,CGFloat duration);

@interface CommentView : UIView
@property(copy,nonatomic)TextViewChangeBlock textBlock;
@property (nonatomic, copy) void(^textHeightChangeHandle)(NSString *text, CGFloat height);
@property (strong, nonatomic)  WSTextView *textView;
@property (nonatomic, copy) void(^sendButtonBlock)(NSString *text);
-(void)setHiddenButton:(BOOL )hidden;

@end
