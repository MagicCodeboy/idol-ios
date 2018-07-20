//
//  ViewersMaskView.m
//  云信全聚星
//
//  Created by 裴雪阳 on 16/5/26.
//  Copyright © 2016年 裴雪阳. All rights reserved.
//

#import "ViewersMaskView.h"
#import "customTf.h"
#import "MessageModel.h"
#import "CellFrameModel.h"
#import "MessageCell.h"
#import "Customize.h"
#import "PXYPensonView.h"
#import "CountDownButton.h"
#import "TYWaveProgressView.h"
#import "danmuView.h"
#import "CustomView.h"
#import "UIView+FrameMethods.h"
#import "UIImageView+WebCache.h"
#import "residentViewCell.h"
#import "PXYHeadViewModel.h"
#import "KLCPopup.h"
#define HEADVIEW @"headview"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define kToolBarH 44
#define kTextFieldH 30
#define viewNumber  2

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]


@interface ViewersMaskView()<UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *messageArray;
    customTf *custom;
    
    BOOL f1;
    BOOL f2;
    NSString *oneViewId;
    NSString *twoViewId;
   
    int oneViewGiftId;
    int twoViewGiftId;
    
     int number1;
     int number2;
     int number3;
     int number4;
    
    bool sendbutton;
    bool sendbuttonrequest;
    int Money;
    
    NSArray *ButtonArray;
    NSTimer *countDownTimer;
    int secondsCountDown;
    
    UIView *LoadingblackView;
    int ButtonTag;
    
     KLCPopup* popup;
   
}
@property (nonatomic, weak) TYWaveProgressView *waveProgressView1;
@property(nonatomic,strong)NSMutableArray *GiftArray;
@property(nonatomic,strong)danmuView *danmu;
@property (weak, nonatomic) IBOutlet UITableView *chatTabview;
@property (weak, nonatomic) IBOutlet UIView *View; //tabview
@property (weak, nonatomic) IBOutlet UIButton *giftButton;//礼物总　按钮
@property (weak, nonatomic) IBOutlet UIView *GiftButtonView;

@property (strong, nonatomic)CountDownButton *button;
@property (assign, nonatomic) BOOL giftButtonViewHidden;
@property (strong,nonatomic) UICollectionView*ListCollectionView;
@property (strong, nonatomic) PXYPensonView *PensonView;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) NSString *Viewersnumber;
@property (strong, nonatomic) NSMutableArray *headarray;
@property (strong ,nonatomic) NIMSession *session;

@end

@implementation ViewersMaskView

+ (instancetype)ViewersView
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}


-(void)awakeFromNib
{
    // 键盘
    custom = [customTf inputTF];
    [custom.sendMessageBtn addTarget:self action:@selector(sendMsgBtnClick) forControlEvents:UIControlEventTouchUpInside];
    custom.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, kToolBarH);
    custom.hidden = YES;
    custom.sendMessageTf.delegate =self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.View addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector
                                     (endEdit)]];
    
    [self addSubview:custom];
    
    
    self.chatTabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    ButtonArray = @[_GiftButton1,_GiftButton2,_GiftButton3,_GiftButton4];
    UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, _chatTabview.frame.size.width, 20)];
    //    headView.layer.shadowOffset = CGSizeMake(_chatTabview.frame.size.width,20);
    //    headView.layer.shadowOpacity = 0.8;
    headView.layer.shadowColor =[UIColor blackColor].CGColor;
    _chatTabview.tableHeaderView=headView;
    
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    
    _GiftArray = [[NSMutableArray alloc]init];
    messageArray = [[NSMutableArray alloc] init];
    self.GiftButtonView.hidden = YES;
    _giftButtonViewHidden = NO;
    f1 = false;
    f2 = false;
    number1=1 ;
    number2 =1;
    number3 =1;
    number4 =1;
    sendbutton =false;
    sendbuttonrequest = true;
    Money = 0;
    
    if (SCREEN_WIDTH<375) {
        self.button1left.constant = 6;
        self.button3Left.constant = 6;
        self.button2Left.constant = 6;
        self.button4Left.constant = 6;
    }
 

    
    self.Viewersnumber = @"";
    
    [self ShowWhaterEffect];
    
    [self initProgressView];
    
    
}

-(NSMutableArray *)headarray
{
    if (_headarray==nil)
    {
        _headarray=[NSMutableArray array];
       
    }
    return _headarray;
}


-(void)ShowonlineList
{
    UICollectionViewFlowLayout *flowOut=[[UICollectionViewFlowLayout alloc]init];
    flowOut.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    
    _ListCollectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-200, 79, 200, 41) collectionViewLayout:flowOut];
    _ListCollectionView.backgroundColor=[UIColor whiteColor];
    _ListCollectionView.showsHorizontalScrollIndicator=NO;
    _ListCollectionView.scrollEnabled=NO;
    _ListCollectionView.layer.cornerRadius=self.ListCollectionView.frame.size.height/2;
    _ListCollectionView.delegate=self;
    _ListCollectionView.dataSource=self;
    //    [self.view insertSubview:_changeCollectionView aboveSubview:_commandView];
    [_ListCollectionView registerNib:[UINib nibWithNibName:@"residentViewCell" bundle:nil] forCellWithReuseIdentifier:HEADVIEW];
    


}

#pragma mark-UICollectionViewDelegate 的代理方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.headarray.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_ListCollectionView.frame.size.height-7, _ListCollectionView.frame.size.height-7);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 2.5, 3, 0);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView==_ListCollectionView)
    {
        PXYHeadViewModel *model=nil;
        
        
        residentViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:HEADVIEW forIndexPath:indexPath];
        if (self.headarray.count) {
            model=self.headarray[indexPath.row];
            
            [cell.residentImage sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
            
        }
        return cell;
    }
    return nil;
}
//点击collectionView某一行的时候调用
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    _searchModel=self.changeArray[indexPath.row];
//    
//    self.liveIndex=1;
//    self.tempIndex=1;
//    
//    self.starID=_searchModel.starId;
//    
//    [self loadStarPageWith:@{@"starId":_searchModel.starId}];
//    //[self addHeaderView];
//    [UIView animateWithDuration:1 animations:^{
//        
//        _changeCollectionView.frame=CGRectMake(SCREEN_WIDTH, 79, 300, 41);
//        _commandView.changeView.frame=CGRectMake(SCREEN_WIDTH-89,87, _commandView.changeView.frame.size.width, _commandView.changeView.frame.size.height);
//    }];
}



//-(void)setItems:(NSArray *)items
-(void)setPxyViewersModel:(PXYViewersLiveModel *)pxyViewersModel
{
    _pxyViewersModel =pxyViewersModel;
    [self UpdataViewers];

}

-(void)UpdataViewers
{

    [self initHeadView];
    [self UpdatawaveProgressView];
    [self UpdataProgressView];
}

- (IBAction)chatView:(id)sender {
    [custom.sendMessageTf becomeFirstResponder];
    custom.hidden = NO;
}
//关注
- (IBAction)GuanzhuButtonClick:(id)sender {
    
    [self RequestGuanzhu:@{@"type":@0, @"id":@10062}];
    
}

-(void)CloseLiveRoom:(id)sender
{
    self.Viewersnumber = sender;
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.Viewersnumber,@"textTwo", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"Viewerstongzhi" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
//退出房间
- (IBAction)closeClick:(id)sender {
    
    [self CloseLiveRoom:@"guanbi"];
    

    
//    if (_AnchorCloseBlock) {
//        self.AnchorCloseBlock();
//    }
    
    
}
- (IBAction)Gift3Click:(UIButton *)sender {
    sender.tag = 3;
    Money = 999;
    [self changeButtonState:sender buttons:ButtonArray];
    

}
- (IBAction)Gift1Click:(UIButton *)sender {
     sender.tag = 1;
    Money = 9;
    
    [self changeButtonState:sender buttons:ButtonArray];

}

- (IBAction)Gift2Click:(UIButton *)sender {
     sender.tag = 2;
    Money = 99;
    [self changeButtonState:sender buttons:ButtonArray];

}
- (IBAction)Gift4Click:(UIButton *)sender {
     sender.tag = 4;
     Money = 9999;
    [self changeButtonState:sender buttons:ButtonArray];

    
}

- (IBAction)giftClick:(id)sender {
    
    self.GiftButtonView.hidden = self.giftButton.selected ;
    self.giftButton.selected = !self.giftButton.selected;
}
- (IBAction)GiftSendClick:(id)sender {
    self.GiftButtonView.hidden = NO;
//    if (sendbuttonrequest) {
//        <#statements#>
//    }
    if (sendbutton) {
        
        if([self.pxyViewersModel.userBalance.strength intValue] >= Money)
        
        {
            [self RequestsendGift:@{
                                           @"liveId":self.pxyViewersModel.liveId,
                                           @"applauseType": [NSString stringWithFormat:@"%d",ButtonTag]}];

        }
        else
        {
            self.Viewersnumber = @"chongzhi";
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.Viewersnumber,@"textTwo", nil];
            //创建通知
            NSNotification *notification =[NSNotification notificationWithName:@"Viewerstongzhi" object:nil userInfo:dict];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
}

-(void)RequestsendGift:(NSDictionary *)dic{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/livesend/applause" parameters:dic isCache:NO succeed:^(id data) {
        
        NSLog(@"==================发送礼物=============%@",data);
        
          _pxyViewersModel.giftmessage=[PXYViewersSendGiftModel mj_objectWithKeyValues:data[@"userGift"]];
        _pxyViewersModel.AnchorBalance.totalApplause =_pxyViewersModel.giftmessage.totalApplause;
         _pxyViewersModel.userBalance.strength =_pxyViewersModel.giftmessage.strength;
         _pxyViewersModel.lastStrength =_pxyViewersModel.giftmessage.strengthNum;
        [self UpdataViewers];
        
        Customize *attachment = [[Customize alloc] init];
        attachment.custom_type = 6;
        attachment.gift_type = ButtonTag;
        attachment.gift_num = [self FindAttachmentnumber:(attachment.gift_type)];
        attachment.head_url = [AccountModel read].avatar;
        [AccountModel shareAccount].userId =[AccountModel read].userId;
        
        NSLog(@"------lalala------%@--%@----%@---%@-",attachment.head_url,[AccountModel read].avatar,[AccountModel read].userId,[AccountModel shareAccount].userId);
//   [cell.userImage sd_setImageWithURL:[NSURL URLWithString:model.user.avatar]];
     

//        attachment.nickname = @"ddfdfdfd";
//        attachment.user_id = @"dddd2"; 
//        
        attachment.applause = _pxyViewersModel.giftmessage.totalApplause;//掌声
        attachment.strength =_pxyViewersModel.giftmessage.strengthNum;//进度条
        NSLog(@"==================观众发送掌声，进度条=========%@====%@",attachment.applause,attachment.strength);
        [self onSendgiftItem:(attachment)];
        
        [self setTimer];

        // _pxySendViewers =[PXYViewersSendGiftModel mj_objectWithKeyValues:data[@"userGift"]];
        
    } fail:^(NSString *error) {
        
    }];
    
    
}


-(int)FindAttachmentnumber:(int )type
{
    if (type == 1)
    {
    
    return number1++;
    }
    if (type == 2)
    {
        
        return number2++;
    }
    if (type == 3)
    {
        
        return number3++;
    }
    if (type == 4)
    {
        
        return number4++;
    }
    return 1;
}
- (void)setTimer {
    secondsCountDown = 5;
    if (nil == countDownTimer)
    {
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    }
    
}
- (void)stopTimer {
    [countDownTimer invalidate];
    countDownTimer = nil;
}


-(void)timeFireMethod{
    self.GiftSendLabel.text =[NSString stringWithFormat:@"%d",secondsCountDown];
      secondsCountDown--;
    if(secondsCountDown<=0){
        [self  stopTimer];
        number1 =1;
        number2 =1;
        number3 =1;
        number4 =1;
        
        //self.GiftSendButton.selected =YES;
        self.GiftSendLabel.text = @"发送";
        //secondsCountDown =30;
    }
}
-(void)changeButtonState:(UIButton *)button buttons:(NSArray *)buttonArray
{
    ButtonTag = (int)button.tag;
    
    self.GiftSendLabel.hidden =NO;
    self.GiftSendButton.selected =YES;
    self.GiftSendLabel.text = @"发送";
    self.waveProgressView1.hidden = YES;
    
    self.TiliLable.hidden =NO;
    sendbutton = true;
    
    [self stopTimer];
    for (UIButton* b in buttonArray)
    {
        b.selected=NO;
    }
    button.selected=YES;
    
}
-(void)revertButtonbuttons:(NSArray *)buttonArray
{
 
    for (UIButton* b in buttonArray)
    {
        b.selected=NO;
    }
   
}

-(void)showCountDownButton
{
    CountDownButton *button = [[CountDownButton alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    [button StartTiming];
}


-(void)onSendgiftItem:(Customize *)xiaoxi
{
   
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = xiaoxi;
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = object;
    if(self.session==NULL)
    {
        self.session = [NIMSession session:self.pxyViewersModel.userLiveBase.roomId type:NIMSessionTypeChatroom];
    }
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:self.session error:nil];
    
   
    [self initGiftMessage:(xiaoxi)];
    
    
    [self addCustomizeDataToFrame:xiaoxi];
    
    [_chatTabview reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messageArray.count- 1 inSection:0];
    [_chatTabview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
//    [self addCustomizeDataToFrame:attachment];
//    [_chatTabview reloadData];
}


-(void)ShowWhaterEffect{
    TYWaveProgressView *waveProgressView = [[TYWaveProgressView alloc]initWithFrame:CGRectMake(0, 0, self.GrayImageView.frame.size.width, self.GrayImageView.frame.size.height)];// 180 180
//    waveProgressView.center = self.GrayImageView.center;
//    waveProgressView.waveViewMargin = UIEdgeInsetsMake(0, 0, 20, 20);
    waveProgressView.backgroundImageView.image = [UIImage imageNamed:@""];
    //waveProgressView.numberLabel.text = @"80";
    if (!self.pxyViewersModel.userBalance.strength) {
        waveProgressView.numberLabel.text = @"0";
    }else
    {
        waveProgressView.numberLabel.text = self.pxyViewersModel.userBalance.strength;
    }
    
    waveProgressView.percent = 0.80;
    
    waveProgressView.numberLabel.font = [UIFont boldSystemFontOfSize:15];
    waveProgressView.numberLabel.textColor = [UIColor whiteColor];
    waveProgressView.unitLabel.text = @"";
    waveProgressView.unitLabel.font = [UIFont boldSystemFontOfSize:20];
    waveProgressView.unitLabel.textColor = [UIColor whiteColor];
    waveProgressView.explainLabel.text = @"体力";
    waveProgressView.explainLabel.font = [UIFont systemFontOfSize:15];
    waveProgressView.explainLabel.textColor = [UIColor whiteColor];
    waveProgressView.percent = 0.80;
    //waveProgressView.backgroundColor = [UIColor grayColor];
    [self.GrayImageView addSubview:waveProgressView];
    //[self.GiftButtonView addSubview:waveProgressView];
    //[waveProgressView insertSubview:self.View belowSubview:self.giftButton];
     // [waveProgressView insertSubview:self.View atIndex:0];
    _waveProgressView1 = waveProgressView;
    [_waveProgressView1 startWave];
    
    self.TiliLable.text =[NSString stringWithFormat:@"体力：%@",self.pxyViewersModel.userBalance.strength];
    
}

-(void)UpdatawaveProgressView
{
    
    if (!self.pxyViewersModel.userBalance.strength) {
        _waveProgressView1.numberLabel.text = @"0";
    }else
    {
        _waveProgressView1.numberLabel.text = self.pxyViewersModel.userBalance.strength;
    }
    self.TiliLable.text =[NSString stringWithFormat:@"体力：%@",self.pxyViewersModel.userBalance.strength];
    
    _waveProgressView1.percent = 0.80;
    
    
}
-(void)initGiftMessage:(Customize *)message
{
//    if (_GiftArray.count <= 0) {
    //message.user_id==twoViewId
    [_GiftArray addObject:message];
    // 一直发a 或者一直发b
    if ((message.user_id== oneViewId && message.gift_type==oneViewGiftId)|| (message.user_id==twoViewId && message.gift_type==twoViewGiftId) ){
    return;
    }
    [self checkShowView];

}

-(void)checkShowView{
    
    if (f1 == true && f2==false) {
        [self initGiftView:2];
    }else if (f1 == false &&f2==true)
    {
        [self initGiftView:1];
        
    }else if (f1 ==false &&f2 ==false)
    {
         [self initGiftView:1];
    }
}

/**
 * @brief 初始化界面
 * @param  number 第几行
 * @return 返回空.
 */
-(void)initGiftView:(int)number
{
   // Customize *gift = [self.GiftArray firstObject];
    NSString *viewid;
    int viewGiftID ;
    if (number ==1) {
        viewid = twoViewId;
        viewGiftID = twoViewGiftId;
    }else if(number ==2)
    {
        viewid = oneViewId;
        viewGiftID = oneViewGiftId;

    }
    Customize *gift = [self NewNextComment:(viewid):(viewGiftID)];
    //giftitem *gift = self.messageArray[i];//获取第一个对象
    if (gift) {
        if (number ==1) {
            f1 = true;
            oneViewId = gift.user_id;
            oneViewGiftId = gift.gift_type;
            
        }else if(number ==2)
        {
            f2 = true;
            twoViewId = gift.user_id;
            twoViewGiftId = gift.gift_type;

        }
        
        [self createBulletComment:gift andint:number];
        
        [self.GiftArray removeObject:gift];
        //[self.GiftArray removeObjectAtIndex:0];
        
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){

    }
    return self;
}


-(void)initHeadView{

    self.HeadView.layer.cornerRadius = 15;
    self.HeadView.backgroundColor = UIColorFromRGB(0x000000);
    self.HeadView.alpha = 0.59;
    
    [self.HeadImage sd_setImageWithURL:[NSURL URLWithString:self.pxyViewersModel.user.avatar]];
    self.HeadName.text =self.pxyViewersModel.user.nickName;
    if (![StringWithFormat(self.pxyViewersModel.liveHitsStr) isEqualToString:@"(null)"])
    {
         self.HeadOnlineNumber.text = [NSString stringWithFormat:@"在线 %@",self.pxyViewersModel.liveHitsStr];
    }
    else
    {
        self.HeadOnlineNumber.text=@"0";
    }
    
    self.zhangsheng.text = [NSString stringWithFormat:@"收到掌声：%@",self.pxyViewersModel.AnchorBalance.totalApplause];
    NSLog(@"----------------裴雪阳 收到掌声%@",self.pxyViewersModel.AnchorBalance.totalApplause);
    
    //self.HeadImage.image = [UIImage imageNamed:@"1111"];
    _HeadImage.layer.cornerRadius = 30/2; //宽度／2
    _HeadImage.layer.masksToBounds = YES;

    [self.HeadGuanzhu.layer setCornerRadius:10.0];
    [self.HeadGuanzhu.layer setBorderWidth:2.0];
    self.HeadGuanzhu.layer.borderColor= UIColorFromRGB(0xFCC148).CGColor;
    
    if (self.pxyViewersModel.follow) {
        self.HeadGuanzhu.hidden =YES;
        self.HeadView.width = 100.f;
    }
  
    

}

-(void)initProgressView{
    //[self.slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
    self.pxyProgressView = [[ProgressView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20, 120, 7, 347.1)];
    //self.pxyProgressView.progress = 1;
    NSLog(@"--------进度条-1-----%@-------%@---",self.pxyViewersModel.lastStrength,self.pxyViewersModel.interactValue);
    //self.pxyProgressView.progress =[self.pxyViewersModel.lastStrength doubleValue]/[self.pxyViewersModel.interactValue doubleValue];
    self.pxyProgressView.hidden = YES;
    [self.View addSubview:self.pxyProgressView];
    
   
}

-(void)UpdataProgressView
{

    
    if ([StringWithFormat(_pxyViewersModel.prize) isEqualToString:@"1"]) {
        self.pxyProgressView.hidden = NO;
        
        if ( [self.pxyViewersModel.interactValue isEqualToString:@"0"]) {
            self.pxyProgressView.hidden =YES;
        }else
        {
            CGFloat mini= [self.pxyViewersModel.lastStrength  doubleValue]/[ self.pxyViewersModel.interactValue doubleValue];
            NSLog(@"-------%f-----mini----",mini);
            self.pxyProgressView.progress = mini;
        }

    }else
    {
        self.pxyProgressView.hidden =YES;
        
        
    }

    
    
    
    //self.pxyProgressView.progress =0.5;
}
- (void)slider:(int )number
{
    self.pxyProgressView.progress = number;
   
}

-(void)GrayImageViewClicked:(UITapGestureRecognizer *)sender
{
    if (_giftButtonViewHidden) {
        _giftButtonViewHidden = NO;
        self.GiftButtonView.hidden = YES;
    }else {
        _giftButtonViewHidden = YES;
        self.GiftButtonView.hidden = NO;
    }

}
-(void)Effctbuttonclick:(UIButton *)sender {
    self.GiftButtonView.hidden = self.giftButton.selected ;
    self.giftButton.selected = !self.giftButton.selected;
    //[self ShowWhaterEffect];
    
    
}
-(void)createBulletComment:(Customize *)gift andint:(int)number{
    _danmu = [[danmuView alloc]initWithContent:gift];
   // _danmu.frame =CGRectMake(-50, 150*number, 200, 50);
    if (number == 1) {
        _danmu.frame =CGRectMake(-50, SCREEN_HEIGHT/2-70, 200, 50);
    }if (number == 2) {
        _danmu.frame =CGRectMake(-50, SCREEN_HEIGHT/2+20, 200, 50);
    }
    
    [_danmu comeAnimation:(gift.gift_num)];
    [self addSubview:_danmu];
    
    __weak typeof(self) wself =self;
    __weak typeof(danmuView *) wdanmu = _danmu;
    _danmu.doubleLableAnimationFanishBlock =^{
        NSString * otherViewId;
        int viewGiftid;
        if (number==1) {
            otherViewId = twoViewId;
            viewGiftid =twoViewGiftId;
            
        }
        else if (number==2)
        {
            otherViewId = oneViewId;
            viewGiftid =oneViewGiftId;

        }
        if (otherViewId ==nil) {
//            [wdanmu outAnimation];
        }
        Customize *comment = [wself NewNextComment:(otherViewId):(viewGiftid)];
        if (comment) {
            if ((comment.gift_type == gift.gift_type) && (comment.user_id == gift.user_id) && (comment.gift_num !=1)) {
                [_GiftArray removeObject:comment];
                [wdanmu doubleLableAnimation:comment.gift_num];
                //[self createBulletComment:comment andint:number];
            }
            else{
                [wdanmu outAnimation];
            }
        }
        else
        {
            [wdanmu outAnimation];
        
        }};
    
    _danmu.FanishBlock =^{
//        Customize *comment = [wself nextComment];
//        if (comment) {
//            [wself createBulletComment:comment andint:number];
//            
//        }
        if (number == 1) {
            f1 =false;
            oneViewId=nil;
        }
        if (number==2) {
            f2 =false;
            twoViewId=nil;
        }
        [wself checkShowView];
    };
    
}

- (Customize *)nextComment {
    Customize *comment = [_GiftArray firstObject];
    if (comment) {
        [_GiftArray removeObjectAtIndex:0];
    }
    return comment;
}

- (Customize *)NewNextComment :(NSString *)useid:(int)Giftid{
    if (_GiftArray.count == 0) {
        return nil;
    }
    for (int i = 0; i<self.GiftArray.count; i++) {
        Customize *cust = _GiftArray[i];
        
        if ((cust.user_id != useid)||(cust.gift_type!=Giftid )) {
            return cust;
        }
    }
    return nil;
}

- (void)selectMenuAtIndex:(NSInteger)index {
    NSLog(@"选中:%zd",index);
}

-(void)addDataToFrame:(NIMMessage *)message
{
    MessageModel *messagemodel = [MessageModel messageModelWithRCMessage:message];
    messagemodel.text = message.text;
    messagemodel.type = Chat;
    messagemodel.userId=message.from;
    CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
    cellFrame.message = messagemodel;
    [messageArray addObject:cellFrame];
}




-(void)addCustomizeDataToFrame:(Customize *)customize
{
    MessageModel *messagemodel = [MessageModel messageModelWithCustomize:customize];
    //messagemodel.text = customize.nickname;
    if (!messagemodel.name) {
        messagemodel.name =[AccountModel read].nickName;
    }else
    {
        messagemodel.name =customize.nickname;
        
    }
    
    switch (customize.gift_type) {
        case 1:
            messagemodel.text  = @"送了一个吻";
            //            messagemodel.name = message.text;
            //            messagemodel.type = Gift
            break;
        case 2:
            messagemodel.text  = @"送了一个花";
            break;
        case 3:
            messagemodel.text  = @"送了一个欢呼";
            break;
        case 4:
            messagemodel.text  = @"送了一个掌声";
            break;
        default:
            break;
    }
    
    messagemodel.type = Gift;
    CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
    cellFrame.message = messagemodel;
    [messageArray addObject:cellFrame];
}


// 更新UI
//- (void)updata:(NIMMessage *)message
//- (void)updata:(NSString *)message
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // 更UI
//        [messageArray addObject:message];
//        //[self addDataToFrame:message];
//        [_chatTabview reloadData];
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messageArray.count- 1 inSection:0];
//        
//        [_chatTabview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    });
//    
//}
- (void)updata:(NIMMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更UI
        //[messageArray addObject:message];
        [self addDataToFrame:message];
        [_chatTabview reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messageArray.count- 1 inSection:0];
        [_chatTabview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
}

- (void)keyboardWillChange:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.frame.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.View.transform = CGAffineTransformMakeTranslation(0, moveY);
        self.chatTabview.transform =CGAffineTransformMakeTranslation(0, moveY);
            NSLog(@"====keyFrame.origin.y====%f=",keyFrame.origin.y); //44
            custom.frame = CGRectMake(0, keyFrame.origin.y-kToolBarH, self.bounds.size.width, kToolBarH);
    }
        ];
}

#pragma mark - 表的协议方法
-(void)backViewClicked
{
    [_backView removeFromSuperview];
    [_PensonView removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    //cell.textLabel.text = messageArray[indexPath.row];
    //[self fuwenbenLabel:cell.textLabel FontNumber:[UIFont systemFontOfSize:15] AndRange:NSMakeRange(0, 2) AndColor:[UIColor redColor]];
    cell.cellFrame = messageArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    _backView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //    _backView.backgroundColor =[UIColor blackColor];
    //    _backView.alpha = 0.5f;
    //    [self addSubview:_backView];
    
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewClicked)];
    //    [_backView addGestureRecognizer:tap];
    //

    
    //    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellFrameModel *cellFrame = messageArray[indexPath.row];
    return cellFrame.cellHeght;
}

//设置不同字体颜色
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    labell.attributedText = str;
}

- (void)sendMsgBtnClick
{
    [custom.sendMessageTf resignFirstResponder];
    //[self textFieldShouldReturn:field];
    custom.hidden = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //当点触textField内部，开始编辑都会调用这个方法。textField将成为first responder
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{//当用户按下ruturn，把焦点从textField移开那么键盘就会消失了
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    NIMMessage *message = [[NIMMessage alloc] init];
    //NSString *messagetext = [NSString stringWithFormat:@"%@说：%@",message.senderName,textField.text];
    //NSString *messagetext = [NSString stringWithFormat:@"我说:%@",textField.text];
    message.text    = textField.text;
    //构造会话
    NIMSession *session = [NIMSession session:@"188974" type:NIMSessionTypeChatroom];
    //发送消息
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
    //[self updata:message.text];
    [self updata:message];
    textField.text = @"";
    return YES;
}

- (void)endEdit
{
    self.GiftButtonView.hidden = YES;
    self.GiftSendButton.selected = NO;
    sendbutton =false;
    self.GiftSendLabel.hidden =YES;
    self.waveProgressView1.hidden = NO;
    [self stopTimer];
    [self revertButtonbuttons:ButtonArray];
    self.TiliLable.hidden =YES;

    [self endEditing:YES];
    custom.hidden = YES;
}

-(void)sendMessage:(NIMMessage * )message didCompleteWithError:(NSError *)error
{
    if(!error)
    {
        NSLog(@"--------发送消息成功－－－－－");
    }else
    {
        NSLog(@"--------发送消息失败－－－－－");
    }
}

-(void)onRecvMessages:(NSArray *)messages{
    for (NIMMessage *message in messages){
        if (message.messageType ==NIMMessageTypeText ) {
            
//            NIMMessageChatroomExtension * EXmessage =message.messageExt;
//            EXmessage.roomAvatar =@"ncxfj.png";
            NSLog(@"RCTextMessage消息内容：%@", message.text);
            //[self addDataToFrame:message];
           // [self updata:message.text];
            [self updata:message];
            [_chatTabview reloadData];
            NSIndexPath *lastPath = [NSIndexPath indexPathForRow:messageArray.count - 1 inSection:0];
            NSLog(@"---lastPath--%@",lastPath);
            //[_chatTabview scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else if (message.messageType == NIMMessageTypeNotification){
            NSLog(@"-----------%@-------------",message);
            
            
        }
        else if (message.messageType == NIMMessageTypeCustom){
            
//            
//            attachment.applause = _pxyViewersModel.userBalance.applause;
//            attachment.strength =_pxyViewersModel.userBalance.strength;
//            

            NSLog(@"---------%@",message);
            NIMCustomObject *object = (NIMCustomObject *)message.messageObject;
            Customize *attachment  = (Customize *)object.attachment;
            if(attachment!=NULL)
            {
                switch (attachment.custom_type) {
                    case 8:
                    {
                        NSLog(@"--------------收到消息8-－－－－－－－");
                        // 抽奖loading
                        CGRect blurRect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                        LoadingblackView = [[UIView alloc] initWithFrame:blurRect];
                        LoadingblackView.backgroundColor = [UIColor clearColor];
                        UIImageView *image =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xingyunfensi_1"]];
                        image.frame = CGRectMake(SCREEN_WIDTH/2-530/4, 300,530/2, 200/2);
                        [LoadingblackView addSubview:image];
                        
                        [self addSubview:LoadingblackView];
                        break;
                    }
                    case 9:
                    {
                        NSLog(@"--------------收到消息9-－－－－－－－");
                        NSString *str =[AccountModel read].userId;
                        
                        NSLog(@"------------当前id 获奖id---live id----%@ %@-%@-",str,self.pxyViewersModel.user.userId,self.pxyViewersModel.liveId);
                                                                      

                        //抽奖loading消失
                        [LoadingblackView removeFromSuperview];
                        
                        if (attachment.lottery) {
                            self.pxyProgressView.hidden = YES;
                        }
                        
                        if([[AccountModel read].userId isEqualToString:self.pxyViewersModel.user.userId])
                        {
                            
                            LuckFansOwn *fanown = [LuckFansOwn  LuckFansOwnView];
                            
                            fanown.frame = CGRectMake((SCREEN_WIDTH - 267)/2, (SCREEN_HEIGHT-345)/2, 267, 345);

                            [self addSubview:fanown];
                            
                        }
                        else
                        {
                            [self GetPensonData:@{@"liveId":self.pxyViewersModel.liveId,@"userId":attachment.user_id }];

                            
                        }
                        break;
                    }
                    case 2:
                    {
                        //直播已经结束，通知所有客户端判断推出。
                        
                        [self CloseLiveRoom:@"guanbiwait"];
                        
                        break;
                        
                    }
                    case 0:
                    {
                    //踢人
                        
                        break;
                    }
                    case 1:
                    {
                        //禁言
                        
                        break;
                    }
                    case 3:
                    {
                    //解除禁言
                        break;
                    }
                    case 4:
                    {
                    //暂停直播
                        [self CloseLiveRoom:@"pause"];
                        break;
                    }
                    case 5:
                    {
                    //继续直播
                        [self CloseLiveRoom:@"keepLiving"];
                        break;
                    }
                    case 6:
                    {//连续礼物
                        
                        [self initGiftMessage:(attachment)];
                        [self addCustomizeDataToFrame:attachment];
                        [_chatTabview reloadData];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messageArray.count- 1 inSection:0];
                        [_chatTabview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    
                        break;
                    }
                    case 7:
                    {
                    //大型礼物
                        break;
                    }
                    case 10:
                    {
                    //没开始直接直播
                        [self CloseLiveRoom:@"tiqianzhibo"];
                        break;
                    }
                }

            }
        }
    }
}

-(void)GetPensonData:(NSDictionary *)dic
{
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/liveprize/user" parameters: dic isCache:NO succeed:^(id data) {
        
        NSLog(@"==================获取个人信息=============%@",data);
        
        
          self.pxyViewersModel.prizeRecord =[PXYAwardsModel mj_objectWithKeyValues:data[@"prizeRecord"]];//进度条
        
        LuckFansOthers *otherfans = [LuckFansOthers LuckFansOtherView];
        [otherfans.Headimage sd_setImageWithURL:[NSURL URLWithString:self.pxyViewersModel.prizeRecord.user.avatar]];
        //[otherfans.Headimage sd_setImageWithURL:[NSURL URLWithString:@"http://joustar.img-cn-beijing.aliyuncs.com/image/user/2016/07/01/160701143852649113.jpg@!face"]];
      
        [otherfans.GiftImage  sd_setImageWithURL:[NSURL URLWithString:self.pxyViewersModel.prizeRecord.prize.picUrl]];
        otherfans.NameLable.text =self.pxyViewersModel.prizeRecord.user.nickName;
        otherfans.frame = CGRectMake((SCREEN_WIDTH - 267)/2, (SCREEN_HEIGHT-345)/2, 267, 345);
        [self addSubview:otherfans];
        
        
//        KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)KLCPopupHorizontalLayoutCenter,
//                                                   (KLCPopupVerticalLayout)KLCPopupVerticalLayoutAboveCenter);
//        popup = [KLCPopup popupWithContentView:otherfans
//                                      showType:KLCPopupShowTypeBounceInFromBottom
//                                   dismissType:KLCPopupDismissTypeSlideOutToBottom
//                                      maskType:KLCPopupMaskTypeClear
//                      dismissOnBackgroundTouch:YES
//                         dismissOnContentTouch:YES];
//        
//        [popup showWithLayout:layout];
//        
//        [popup show];
//        
//
        
        

        
    } fail:^(NSString *error) {
         NSLog(@"==================获取个人信息失败=============%@");
        
    }];
    




}
//关注
-(void)RequestGuanzhu:(NSDictionary *)dic
{
    
    [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/follow/add" parameters:dic isCache:NO succeed:^(id data) {
        
        NSLog(@"==================关注成功=============%@",data);
        
        self.HeadGuanzhu.hidden =YES;
        self.HeadView.width = 100.f;

       // _pxySendViewers =[PXYViewersSendGiftModel mj_objectWithKeyValues:data[@"userGift"]];
        
    } fail:^(NSString *error) {
        
    }];
    
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
}

@end
