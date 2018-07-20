//
//  CommentView.m
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/22.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "CommentView.h"

@interface CommentView()<UITextViewDelegate>
@property (strong, nonatomic)  UIButton *sendButton;

@end
@implementation CommentView

-(instancetype)init
{
    if (self== [super init]) {
        
        [self setview];
        self.backgroundColor=UIColorFromRGB(0x482873);
    }
    return self;
    
}
-(void)setview{
    
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    self.sendButton=[UIButton new];
    [self addSubview:self.sendButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(50, 34));
    }];
    [self layoutIfNeeded];
    self.sendButton.layer.masksToBounds=YES;
    self.sendButton.layer.cornerRadius=3;
    [self.sendButton setTitle:NSLocalizedString(@"SendButton",nil) forState:0];
    [self.sendButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:0];
    self.sendButton.titleLabel.font=[UIFont systemFontOfSize:13];
    self.sendButton.backgroundColor=UIColorFromRGB(0x8C5FFF) ;
    self.sendButton.hidden=YES;
    [self.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.textView =[[WSTextView alloc]init];
    self.textView.backgroundColor = [UIColor clearColor];
    WeakSelf(weakself, self);
    [self.textView setSendButtonBlock:^(NSString *text) {
        
        [weakself sendButtonAction:weakself.sendButton];
        
    }];
    
    
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(13);
        make.bottom.mas_equalTo(-13);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.sendButton.mas_left).offset(-13);
    }];
    self.textView.font=[UIFont systemFontOfSize:14];
    self.textView.delegate=self;
    
    //设置最大行数
    self.textView.maxNumberOfLines = 5;
    //设置提示内容
    self.textView.placeHolder =LocalizedStr(@"sayThing");
    self.textView.placeHolderColor = [UIColor whiteColor];
    self.textView.textColor=UIColorFromRGB(0xCCCCCC);
    //高度改变的回调
    __weak typeof(self) wself = self;
    
    [self.textView.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        wself.sendButton.hidden=!x.length;
    

    }];
    
    self.textView.ws_textHeightChangeHandle = ^(NSString *text, CGFloat height){
        NSLog(@"哈哈哈%f %@", height, text);
        if (wself.textHeightChangeHandle) {
            wself.textHeightChangeHandle(text,height);
        }
        //26是textView上下边距的和
//        wself.bottomViewH.constant = height + 26.f;
//        [wself  mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(height+26);
//            make.left.and.right.mas_equalTo(wself.superview);
//            make.bottom.mas_equalTo(wself.mas_height);
//        }];
//        [UIView animateWithDuration:0.25 animations:^{
//            [wself.superview layoutIfNeeded];
//            [wself layoutIfNeeded];
//
//        }];
//
    };
}
-(void)setHiddenButton:(BOOL )hidden
{
    self.sendButton.hidden=hidden;

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        if (self.sendButtonBlock) {
            self.sendButtonBlock(self.textView.text);
        }
        
        return NO;
    }
    
    return YES;
}
-(void)sendButtonAction:(UIButton *)button
{
    if (self.sendButtonBlock) {
        self.sendButtonBlock(self.textView.text);
    }
    
}
- (void)keyboardChange:(NSNotification *)note {
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    if (self.textBlock) {
        self.textBlock(endFrame.origin.y != screenH ? endFrame.size.height:0,duration);
    }
    //    self.bottomViewBottom.constant = endFrame.origin.y != screenH ? endFrame.size.height:0;

//    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//        NSLog(@"坐标值：%f",endFrame.origin.y != screenH ? endFrame.size.height:0);
//        make.left.and.right.mas_equalTo(self.superview);
//        make.height.mas_equalTo(100);
//        make.bottom.mas_equalTo(-endFrame.origin.y != screenH ? endFrame.size.height:0);
//    }];
//
//    [UIView animateWithDuration:duration animations:^{
//        [self.superview layoutIfNeeded];
//        [self layoutIfNeeded];
//    }];
}
@end
