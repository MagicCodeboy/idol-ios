//
//  LiveShopCenterViewController.m
//  jinshanStrmear
//
//  Created by lalala on 16/9/12.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "LiveShopCenterViewController.h"
#import "LiveShopViewCell.h"
#import "UIButton+Block.h"
#import "UIView+Toast.h"
#import "UIView+MJExtension.h"
#import "UIView+BlockGesture.h"


#import "JXTAlertTools.h"
#import "ShopDetailView.h"
#import "OrderListView.h"
#import "AddressView.h"
#import "AddAdressView.h"
#import "PayWayView.h"
#import "WXApiRequestHandler.h"

#define SHOPCELL @"ShopViewCell"

@interface LiveShopCenterViewController ()<UITableViewDelegate,UITableViewDataSource,WXPayApiResultDelegate,UITextViewDelegate>


@property(nonatomic,strong) UITableView * shopTableView;

@property(nonatomic,strong)UIImageView *tapiamgeView;//添加的手势的视图

@property(nonatomic,strong)NSMutableArray * shopArray;//数据存放的数组

@property(nonatomic,strong)ShopDetailView * detailView;//商品的详情的页面

@property(nonatomic,strong)OrderListView * orderListView;//确认订单的页面

@property(nonatomic,strong)PayWayView * payView;//支付的页面

@property(nonatomic,strong)AddressView * addRessView;//修改地址的页面
@property(nonatomic,strong)WXApiRequestHandler *WXApiHander;

@property(nonatomic,strong)AddressView * showAddressView;//展示地址的页面

@end

@implementation LiveShopCenterViewController


-(NSMutableArray *)shopArray
{
    if (_shopArray == nil)
    {
        _shopArray = [NSMutableArray array];
    }
    return _shopArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    _WXApiHander=[WXApiRequestHandler sharedManager];
    _WXApiHander.delegate=self;


    [self configUI];
    
    [self addObeserver];
    
}

-(void)addObeserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(textViewDidChange:)
//                                                 name:UITextViewTextDidChangeNotification
//                                               object:nil];
}

-(void)configUI
{
    _tapiamgeView = [[UIImageView alloc]initWithFrame:self.view.frame];
    _tapiamgeView.backgroundColor = [UIColor clearColor];
    WeakSelf(weakSelf, self);
    [self.tapiamgeView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];

    }];
    [self.view addSubview:self.tapiamgeView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.shopTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-300, SCREEN_WIDTH, 300) style:UITableViewStylePlain];
    self.shopTableView.backgroundColor = [UIColor whiteColor];
    self.shopTableView.delegate = self;
    self.shopTableView.dataSource = self;
    [self.view addSubview:self.shopTableView];
    
    [self regisCell];
    
    if (_detailView == nil)
    {
        _detailView = [ShopDetailView shopDetailView];
        _detailView.frame = CGRectMake(0, SCREEN_HEIGHT -313, SCREEN_WIDTH, 313);
        //点击返回按钮的事件
        [_detailView.detailComeBack addActionHandler:^(NSInteger tag) {
            [weakSelf.detailView removeFromSuperview];
        }];
        //购买按钮的点击事件
        [_detailView.detailBuyBtn addActionHandler:^(NSInteger tag) {
            weakSelf.detailView.hidden = YES;
            weakSelf.shopTableView.hidden = YES;
            [weakSelf.view insertSubview:weakSelf.orderListView aboveSubview:weakSelf.detailView];
        }];
    }
    //确认订单的页面  有收货地址的页面
    if (_orderListView == nil)
    {
        _orderListView = [OrderListView orderListView];
        _orderListView.frame =  CGRectMake(0, SCREEN_HEIGHT - 285, SCREEN_WIDTH, 285);
        //点击返回按钮的事件
        [_orderListView.orderComeback addActionHandler:^(NSInteger tag) {
            [weakSelf.orderListView removeFromSuperview];
            weakSelf.detailView.hidden = NO;
            weakSelf.shopTableView.hidden = NO;
            
        }];
        //确定按钮的点击事件
        [_orderListView.orderMakesure addActionHandler:^(NSInteger tag) {
            weakSelf.orderListView.hidden = YES;
            [weakSelf.view insertSubview:weakSelf.payView aboveSubview:weakSelf.orderListView];
        }];
        //修改地址的按钮
        [_orderListView.changeAddress addActionHandler:^(NSInteger tag) {
            weakSelf.orderListView.hidden = YES;
            [weakSelf.view insertSubview:weakSelf.addRessView aboveSubview:weakSelf.orderListView];
        }];
    }
    //支付的页面  没有收货的地址
    if (_payView == nil)
    {
        _payView = [PayWayView payWayView];
        _payView.frame = CGRectMake(0, SCREEN_HEIGHT - 160, SCREEN_WIDTH, 160);
        //支付页面的返回按钮
        [_payView.payComeBack addActionHandler:^(NSInteger tag) {
            //应该弹出提示框 提示用户是否取消订单 点击确定的时候才退出当前的页面
            [JXTAlertTools showAlertWith:self title:@"提示" message:@"是否取消订单" callbackBlock:^(NSInteger btnIndex) {
                if (btnIndex==0)
                {
                    //取消 
                    
                }
                else
                {
                    //确定 当前的页面消失
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
//                    [self.view makeToast:@"取消订单成功"];
                }
                
            } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
            
        }];
        //支付页面的支付按钮
        [_payView.goBuyBtn addActionHandler:^(NSInteger tag) {
            
            [_WXApiHander jumpToWXPay];

            
        }];
    }
    //修改地址的页面
    if (_addRessView == nil)
    {
        _addRessView =[AddressView addressView];
        _addRessView.detailAddress.delegate=self;
        
        
        _addRessView.frame = CGRectMake(0, SCREEN_HEIGHT -196, SCREEN_WIDTH, 196);
        //返回按钮的点击事件
        [_addRessView.addressComeBack addActionHandler:^(NSInteger tag) {
            weakSelf.orderListView.hidden = NO;
            [weakSelf.addRessView removeFromSuperview];
        }];
        //保存地址的按钮
        [_addRessView.addressSave addActionHandler:^(NSInteger tag) {
            //这里要判断相关的信息是否符合规则
            if (_addRessView.receiveName.text.length>0  )
            {
                if ( _addRessView.receivePhoneNumber.text.length>0)
                {
                    if ( _addRessView.detailAddress.text.length>0)
                    {
                        [weakSelf.view insertSubview:weakSelf.showAddressView aboveSubview:weakSelf.addRessView];
                    }
                    else
                    {
                         [weakSelf.view makeToast:@"请填写联系人收货地址"];
                    }
                }
                else
                {
                     [weakSelf.view makeToast:@"请填写联系电话"];
                }
            }
            else
            {
                [weakSelf.view makeToast:@"请填写联系人姓名"];
            }
         
        }];
    }
    //展会地址的页面
    if (_showAddressView == nil)
    {
        _showAddressView = [AddressView addressView];
        _showAddressView.frame = CGRectMake(0, SCREEN_HEIGHT - 196, SCREEN_WIDTH, 196);
       
        _showAddressView.receiveName.userInteractionEnabled = NO;
        _showAddressView.receivePhoneNumber.hidden = YES;
        //展示传递过来的数据
        _showAddressView.receiveName.text = @"花生豆腐";
        _showAddressView.phoneNumberLabel.text = @"123234333232";
        _showAddressView.phoneNumberLabel.textColor = UIColorFromRGB(0x333333);
        _showAddressView.detailAddressLable.text = @"北京朝阳区酒仙桥北路恒通国际创新园啦啦啦啦";
        _showAddressView.detailAddressLable.textColor = UIColorFromRGB(0x333333);
        
        //返回按钮的点击事件
        [_showAddressView.addressComeBack addActionHandler:^(NSInteger tag) {
            [weakSelf.showAddressView removeFromSuperview];
        }];
        //保存按钮的点击事件
        [_showAddressView.addressSave addActionHandler:^(NSInteger tag) {
            
        }];
    }
   
    
}
-(void)regisCell
{
    [self.shopTableView registerNib:[UINib nibWithNibName:@"LiveShopViewCell" bundle:nil] forCellReuseIdentifier:SHOPCELL];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.shopTableView)
    {
//        if (self.shopArray.count >0)
//        {
            LiveShopViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SHOPCELL];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell.payBtn addActionHandler:^(NSInteger tag) {
        
            [_WXApiHander jumpToWXPay];
            
        }];
        
            return cell;
//        }
//        else
//        {
//            
//        }
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
//点击跳转到下一个商品的详情的页面
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view insertSubview:self.detailView aboveSubview:self.shopTableView];
}
/**
 *  @author 王森, 16-09-14 14:09:12
 *
 *  支付结果回调
 *
 *  @param resultString 支付结果
 */

//WXSuccess           = 0,    /**< 成功    */
//WXErrCodeCommon     = -1,   /**< 普通错误类型    */
//WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
//WXErrCodeSentFail   = -3,   /**< 发送失败    */
//WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
//WXErrCodeUnsupport  = -5,   /**
-(void)WXPayApiResult:(NSString *)resultString withErrorCode:(int)errorCode;
{
    
    if (errorCode==0) {
        [self.view makeToast:@"支付成功"];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    else
    {
        
       
    [JXTAlertTools showAlertWith:self title:resultString message:@"是否重新支付" callbackBlock:^(NSInteger btnIndex) {
        if (btnIndex==0)
        {
            //取消
            [self dismissViewControllerAnimated:YES completion:nil];

        }
        else
        {
            [_WXApiHander jumpToWXPay];
        
        }
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
    }

    
}

#pragma mark - 键盘的代理方法
- (void)keyboardWillChange:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    CGFloat moveY = keyFrame.origin.y - self.addRessView.frame.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.addRessView.frame = CGRectMake(0, moveY, SCREEN_WIDTH, self.addRessView.frame.size.height);
        NSLog(@"====keyFrame.origin.y====%f=",keyFrame.origin.y); //44
       
    }];
}
-(void)keyboardDidShow:(NSNotification *)note
{
   
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    //键盘高度
    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
   
    
}
-(void)keyboardDidHide:(NSNotification *)note
{
    
}

#pragma mark - textView的代理的方法
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        [self.addRessView.detailAddressLable setHidden:NO];
    }
    else
    {
        [self.addRessView.detailAddressLable setHidden:YES];
        
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    CGRect frame = textView.frame;
    float height;
    if ([text isEqual:@""]) {
        
        if (![textView.text isEqualToString:@""]) {
            
            height = [ self heightForTextView:textView WithText:[textView.text substringToIndex:[textView.text length] - 1]];
            
        }else{
            
            height = [ self heightForTextView:textView WithText:textView.text];
        }
    }else{
        
        height = [self heightForTextView:textView WithText:[NSString stringWithFormat:@"%@%@",textView.text,text]];
    }
    
    frame.size.height = height;
    [UIView animateWithDuration:0.5 animations:^{
//        [self.addRessView.detailAddressLable mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(height);
//        }];
//          make.height
        self.addRessView.detailAddressLable .height=height;
        textView.frame = frame;
        
        if (height>15) {
            _addRessView.height=height-15;
            _addRessView.top= _addRessView.top-height;

        }
        
        
        
        
        

    } completion:nil];
    
    return YES;
}



//计算评论框文字的高度
- (float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText{
    //    float padding = 10.0;
    CGSize constraint = CGSizeMake(textView.contentSize.width, CGFLOAT_MAX);
    CGRect size = [strText boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}
                                        context:nil];
    float textHeight = size.size.height + 40.0;
    return textHeight;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
