//
//  TabView.m

//
//  Created by q on 16/2/17.
//  Copyright (c) 2016年 q. All rights reserved.
//

#import "TabView.h"
#import "CommonDefin.h"
#import "UIColor+NetColor.h"
#import "UIView+WZLBadge.h"

@interface TabView ()
@property(nonatomic,strong)NSMutableArray *buttonArray;
@property(nonatomic,strong)UIImageView *bottomselectImageView;

@end
@implementation TabView

-(NSMutableArray *)buttonArray
{
    
    if (!_buttonArray) {
        _buttonArray=[[NSMutableArray alloc]init];
        
    }
    
    return _buttonArray;
    
}
//重写setter方法
-(void)setTitleArray:(NSArray *)titleArray
{
    UIImageView *bottobImage=[[UIImageView alloc]init];
    bottobImage.backgroundColor=UIColorFromRGB(0xf5f5f5);
    //    FRAME(bottobImage, 0, self.bottom-1, self.width, 1);
    bottobImage.tag=1000;
    
    [self addSubview:bottobImage];
    [bottobImage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(self.bottom).mas_offset(-1);
        make.left.right.mas_equalTo(self);
        
        make.height.mas_equalTo(1);
        
    }];
    

    
    [self layoutIfNeeded];
    
    //设置按钮的间距和宽度和高度
    CGFloat kBtnSpace=24.5;
    CGFloat kBtnWidth=34;
    CGFloat kBtnHeight=16;
    if (self.isResetWidth) {
        kBtnWidth = self.btmWidth;
    }
    
    //循环创建按钮
    for (int i=0; i<titleArray.count; i++)
    {
      
        UIButton *btn=[[UIButton alloc]init];
//        WithFrame:CGRectMake(i*(kBtnSpace+kBtnWidth)+12+15, 13,kBtnWidth , kBtnHeight)];
        
        [self.buttonArray addObject:btn];
        



        btn.backgroundColor=[UIColor clearColor];
      
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        [btn setTintColor:[UIColor blackColor]];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        
        [btn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
        //设置选中状态的文字的颜色
        [btn setTitleColor:UIColorFromRGB(0xFF554C) forState:UIControlStateSelected];
        //设置tag值
        btn.tag=100+i;
        
        
        
        //btn.titleLabel.font=[UIFont systemFontOfSize:15];
        btn.titleLabel.textAlignment=NSTextAlignmentCenter;
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            btn.selected=YES;
        }
        [self addSubview:btn];
//    WithFrame:CGRectMake(i*(kBtnSpace+kBtnWidth)+12+15, 13,kBtnWidth , kBtnHeight)];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(i*(kBtnSpace+kBtnWidth)+24.5);
            make.top.mas_equalTo(13);
            make.width.mas_equalTo(kBtnWidth);
            make.height.mas_equalTo(kBtnHeight);
            
        }];
        
        if (i==0) {
            [self layoutIfNeeded];

            _bottomselectImageView=[[UIImageView alloc]initWithFrame:CGRectMake(btn.centerX-24,bottobImage.bottom-3, 48, 2)];
            _bottomselectImageView.tag=200;
            _bottomselectImageView.backgroundColor=UIColorFromRGB(0xFF554C);
            

            
            //            bottomImageView.image=IMAGE(@"Rectangle 729 Copy");
            [self addSubview:_bottomselectImageView];
            
        }
        

        
        

    }
    
    
}
-(void)onClick:(UIButton *)btn
{
    
    UIButton *selectbtn=nil;

    for (int i=0; i<self.buttonArray.count; i++) {
        
        selectbtn=self.buttonArray[i];

        if (i==btn.tag-100) {
            selectbtn.selected=YES;
  
        }else{
            selectbtn.selected=NO;

        }
        
    }
    
    
//    [image1 mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(btn.mas_centerX);
//        
//    }];
//
    [self layoutIfNeeded];

    UIImageView *bottobImage=[self viewWithTag:1000];
    [UIView animateWithDuration:0.3 animations:^{
        _bottomselectImageView.frame=CGRectMake(btn.centerX-24,bottobImage.bottom-3, 48, 2);
    }];
    


    //把选中的按钮的状态selected设置为YES
//    btn.selected=YES;
    
    //更新lastBtn的tag值
    
        //调用协议方法
    if (_delegate &&[_delegate respondsToSelector:@selector(tabBtn:)])
    {
        [_delegate tabBtn:btn.tag-100];
    }else
    {
        NSLog(@"没有设置代理或者代理没有实现协议方法");
    }
    
}
//更新按钮的颜色  传递按钮的tag值
-(void)resetBtnStatus:(NSInteger)btnTag
{
 
    UIButton *selectbtn=nil;
    
    for (int i=0; i<self.buttonArray.count; i++) {
        
        selectbtn=self.buttonArray[i];
        
        if (i==btnTag-100) {
            selectbtn.selected=YES;
            UIImageView *bottobImage=[self viewWithTag:1000];
            
            _bottomselectImageView.frame=CGRectMake(selectbtn.centerX-24,bottobImage.bottom-3, 48, 2);
//        _bottomselectImageView.frame=CGRectMake(selectbtn.centerX-24,selectbtn.bottom+5, 48, 2);;

            
        }else{
            selectbtn.selected=NO;
            
        }
    }
    

  
    

    //更新lastBtnTag的值
}



@end
