//
//  TabView.h
//
//  Created by q on 16/2/17.
//  Copyright (c) 2016年 q All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabViewDelegate <NSObject>

 //点击按钮的时候 把相应的页码传递过去
-(void)tabBtn:(NSInteger)page;

@end

@interface TabView : UIView

@property(nonatomic,assign)CGFloat btmWidth;

@property(nonatomic,assign) BOOL isResetWidth;
//存放按钮的文字
@property(nonatomic,strong)NSArray *titleArray;

//arc使用weak mrc使用assign 避免循环引用
@property(nonatomic,weak)id<TabViewDelegate>delegate;

//更新按钮的颜色  传递按钮的tag值
-(void)resetBtnStatus:(NSInteger)btnTag;


@end
