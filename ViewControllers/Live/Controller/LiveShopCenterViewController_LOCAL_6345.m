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
@interface LiveShopCenterViewController ()<UITableViewDelegate,UITableViewDataSource,WXPayApiResultDelegate>

@property(nonatomic,strong) UITableView * shopTableView;

@property(nonatomic,strong)UIImageView *tapiamgeView;//添加的手势的视图

@property(nonatomic,strong)NSMutableArray * shopArray;//数据存放的数组

@property(nonatomic,strong)ShopDetailView * detailView;//商品的详情的页面

@property(nonatomic,strong)OrderListView * orderListView;//确认订单的页面

@property(nonatomic,strong)PayWayView * payView;//支付的页面

@property(nonatomic,strong)AddressView * addRessView;//修改地址的页面
@property(nonatomic,strong)WXApiRequestHandler *WXApiHander;

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
    
}
//给页面添加点击的手势 点击隐藏用户的个人信息的弹框
-(void)ontapHideView:(UITapGestureRecognizer*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)configUI
{
    _tapiamgeView = [[UIImageView alloc]initWithFrame:self.view.frame];
    _tapiamgeView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ontapHideView:)];
    [self.tapiamgeView addGestureRecognizer:tapGesture];
    
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
            [self.detailView removeFromSuperview];
        }];
        //购买按钮的点击事件
        [_detailView.detailBuyBtn addActionHandler:^(NSInteger tag) {
            self.detailView.hidden = YES;
            self.shopTableView.hidden = YES;
            [self.view insertSubview:self.orderListView aboveSubview:self.detailView];
        }];
    }
    //确认订单的页面  有收货地址的页面
    if (_orderListView == nil)
    {
        _orderListView = [OrderListView orderListView];
        _orderListView.frame =  CGRectMake(0, SCREEN_HEIGHT - 285, SCREEN_WIDTH, 285);
        //点击返回按钮的事件
        [_orderListView.orderComeback addActionHandler:^(NSInteger tag) {
            [self.orderListView removeFromSuperview];
            self.detailView.hidden = NO;
            self.shopTableView.hidden = NO;
            
        }];
        //确定按钮的点击事件
        [_orderListView.orderMakesure addActionHandler:^(NSInteger tag) {
            self.orderListView.hidden = YES;
            [self.view insertSubview:self.payView aboveSubview:self.orderListView];
        }];
        //修改地址的按钮
        [_orderListView.changeAddress addActionHandler:^(NSInteger tag) {
            self.orderListView.hidden = YES;
            [self.view insertSubview:self.addRessView aboveSubview:self.orderListView];
        }];
    }
    //添加地址的页面  没有收货的地址
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
                    [self dismissViewControllerAnimated:YES completion:nil];
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
        _addRessView.frame = CGRectMake(0, SCREEN_HEIGHT -196, SCREEN_WIDTH, 196);
        //返回按钮的点击事件
        [_addRessView.addressComeBack addActionHandler:^(NSInteger tag) {
            self.orderListView.hidden = NO;
            [self.addRessView removeFromSuperview];
        }];
        //保存地址的按钮
        [_addRessView.addressSave addActionHandler:^(NSInteger tag) {
            
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
