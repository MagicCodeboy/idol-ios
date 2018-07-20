//
//  PXYSmallView.m
//  例子
//
//  Created by 裴雪阳 on 16/7/18.
//  Copyright © 2016年 裴雪阳. All rights reserved.
//

#import "PXYSmallView.h"

#define UIColorMake(r, g, b, a) [UIColor colorWithRed:r / 255. green:g / 255. blue:b / 255. alpha:a]

@interface PXYSmallView ()
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *labels2;


@end
@implementation PXYSmallView

+(id)inPutView
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
}


-(void)awakeFromNib
{

    _timer2 = [[KKProgressTimer alloc] initWithFrame:CGRectMake(13*SHIJI_WIDTH, 80, 70, 70)];
    //_timer2 = [[KKProgressTimer alloc] initWithFrame:CGRectMake(0, 0, self.width, 150)];
    NSLog(@"---------pppxxxyyy---------%f------%f----%f---%f-----",self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.bounds.size.height);
    _timer2.delegate = self;
    
    self.layer.cornerRadius = 1;
    
    self.layer.masksToBounds = YES;
    
    _labels = [NSMutableArray array];
    [_labels addObject:@"鼓掌"];
    [_labels addObject:@"爱你"];
    [_labels addObject:@"欢呼"];
    [_labels addObject:@"飞吻"];

    _labels2 = [NSMutableArray array];
    [_labels2 addObject:@" 2"];
    [_labels2 addObject:@" 3"];
    [_labels2 addObject:@" 666"];
    [_labels2 addObject:@" 5200"];
    
    self.Index = @"";
    
    self.lableTime = [[UILabel alloc]init];
    self.lableTime.font = [UIFont systemFontOfSize:23];
    

    self.lableTime.frame = CGRectMake(43, 98, 30, 30);
    
    self.lableTime.textColor = [UIColor whiteColor];
    
    self.ButtonClick = [[UIButton alloc]initWithFrame:CGRectMake(13*SHIJI_WIDTH, 80, 70, 70)];
    self.ButtonClick.hidden=YES;
    self.ButtonClick.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"lianjianniu"]];
    self.timer2.ButtonClick=self.ButtonClick;
    [self insertSubview:self.ButtonClick aboveSubview:self.lableTime];
    [self.ButtonClick addTarget:self action:@selector(lianjiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    //self.lableTime.text = @"3";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PXYGiftButton:) name:@"PXYGiftButton" object:nil];

}

-(void)PXYGiftButton:(NSNotification *)text
{
    
  
    
    _timer2.ButtonIndex =text.userInfo[@"number"];
    self.Index = text.userInfo[@"number"];
    [_timer2 removeFromSuperview];
    [_lableTime removeFromSuperview];
    [_ButtonClick removeFromSuperview];
    NSLog(@"---kaokaokao-----%@------------------",self.Index);
    
//    self.Xingbi.titleLabel.text= _labels2[[self.Index intValue]];
//    self.Xingbi.titleLabel.text= @" 666";
   
    
    [self.Xingbi setTitle:_labels2[[self.Index intValue]] forState:UIControlStateNormal];
    

    NSLog(@"-----nininininimamama-------%@-----%@--",self.Xingbi.titleLabel.text,_labels2[[self.Index intValue]]);
    self.GuzhangLable.text = _labels[[self.Index intValue]];
    
    
    self.BigGiftImage.hidden = NO;
    self.ButtonClick.hidden = YES;

}


- (IBAction)PXYButtonCLick:(id)sender {
    
    self.Lianjibeijing.hidden = NO;
    self.ButtonClick.hidden = NO;
    
    [_timer2 removeFromSuperview];
    [_lableTime removeFromSuperview];
    [_ButtonClick removeFromSuperview];
    self.BigGiftImage.hidden = YES;

    if ([self.Index intValue] == 2 || [self.Index intValue] == 3) {
        self.Lianjibeijing.hidden = YES;
        self.ButtonClick.hidden= YES;
        self.BigGiftImage.hidden = NO;
    }
    
    NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:self.Index,@"number",@"1",@"startPlay", nil];
    //创建通知
    NSNotification *notification2 =[NSNotification notificationWithName:@"GiftButtonIndex" object:nil userInfo:dict2];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification2];
    
}

-(void)lianjiButtonClick
{
    self.ButtonClick.hidden = YES;
    
    NSDictionary *dict2 =[[NSDictionary alloc] initWithObjectsAndKeys:self.Index,@"number",@"0",@"startPlay", nil];
    //创建通知
    NSNotification *notification2 =[NSNotification notificationWithName:@"GiftButtonIndex" object:nil userInfo:dict2];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification2];
}

- (IBAction)LianjiButton:(id)sender {


}



- (void)didUpdateProgressTimer:(KKProgressTimer *)progressTimer percentage:(CGFloat)percentage {
    // NSLog(@"%s %f", __PRETTY_FUNCTION__, percentage);


    if ( 0 <= percentage >= 0.33f) {
        self.lableTime.text =@"3";
        if ([self.Index intValue] == 0 || [self.Index intValue] == 1) {
            self.ButtonClick.hidden = NO;
        }
    }
    
    if (0.33f <= percentage >= 0.66f) {
        self.lableTime.text =@"2";
        self.ButtonClick.hidden=YES;
    }
    
    if (0.66f <= percentage >= 0.99f) {
        self.lableTime.text =@"1";
    }
    
    if (percentage >= 1) {
        [progressTimer stop];
        [_timer2 removeFromSuperview];
        [_lableTime removeFromSuperview];
        [_ButtonClick removeFromSuperview];
        
        self.BigGiftImage.hidden = NO;
        self.Xingbi.hidden = NO;
        self.Lianjibeijing.hidden =YES;
        
    }
    
}

- (void)didStopProgressTimer:(KKProgressTimer *)progressTimer percentage:(CGFloat)percentage {
    NSLog(@"%s %f", __PRETTY_FUNCTION__, percentage);
}


- (void)drawFramePie:(CGRect)rect {
    CGFloat radius = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) * 0.5;
    CGFloat centerX = CGRectGetWidth(rect) * 0.5;
    CGFloat centerY = CGRectGetHeight(rect) * 0.5;
    
    [UIColorMake(155, 190, 225, 1) set];
    CGFloat fw = 90 + 1;
    CGRect frameRect = CGRectMake(
                                  centerX - radius + fw,
                                  centerY - radius + fw,
                                  (radius - fw) * 2,
                                  (radius - fw) * 2);
    UIBezierPath *insideFrame = [UIBezierPath bezierPathWithOvalInRect:frameRect];
    insideFrame.lineWidth = 2;
    [insideFrame stroke];
}

/*
 服务器返回判断
 */
-(void)postServiceReturn
{
    self.ButtonClick.enabled=false;
    self.timer2.ButtonClick.enabled=false;
}

-(void)postServiceBefore
{
    self.ButtonClick.enabled=true;
    self.timer2.ButtonClick.enabled=true;
}



@end
