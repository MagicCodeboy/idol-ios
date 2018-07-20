//
//  PXYAnchorController.m
//  jinshanStrmear
//
//  Created by 裴雪阳 on 16/6/16.
//  Copyright © 2016年 王森. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "PXYAnchorController.h"
#import "ViewersMaskView.h"
#import "StarAnchorView.h"
#import "MBProgressHUD.h"
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
#import "StartViewController.h"
#import "StarCountdownView.h"
#import "CLNetworkingManager.h"
#import "UIView+Toast.h"
#import "UIImage+Capture.h"
#import "NormalCategory.h"
#import "JXTAlertTools.h"
#import "ZantingView.h"
#import "MJExtension.h"
#import "UIImage+Blur.h"
#import "AccountModel.h"
#import "KLCPopup.h"

#import "PXYPensonView.h"//个人信息的弹框视图


#import "MajorModel.h"

#import "LshLiveStop.h"//明星直播结束的页面

#import "AnchorModel.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
@interface PXYAnchorController ()<CLLocationManagerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
//    ViewersMaskView * ViewersView;
//    StarAnchorView *staranchorView;
//
    
    KLCPopup *popup;//添加的蒙版的视图
    
    NSTimer *_timer;//定时器
    UIImageView *_foucsCursor;
    UIView   *_controlView;
    UIButton *_btnCamera;//摄像头按钮
    UIButton *_button;//开始直播按钮（推流按钮）
    UIButton *_btnFlash;//闪光灯按钮
    UIButton *_btnExit;//退出直播的按钮
    UILabel *_label;//直播时间显示的标签
    UIButton *_btnFilters1;//美颜的原始效果
    UIButton *_btnFilters2;//美颜
    UIButton *_btnFilters3;//美白++
    
    double    _lastSecond;
    int       _lastByte;
    int       _lastFrames;
    int       _lastDroppedF;
    int       _netEventCnt;
    NSString *_netEventRaiseDrop;
    int       _netTimeOut;
    int       _raiseCnt;
    int       _dropCnt;
    double    _startTime;
    
    int backtime;
    
    int pauseTimeNum;
    
    BOOL isPauseStrme;//是否正在推流的状态
    
    
    
    //判断用户是否要显示城市
    BOOL isLocation;
    
    
    
    CLLocationManager *_locationManager;//位置管理的类
    CLLocation *_cllocation;//获取用户当前的位置
    
     UIImage *tempImg;
    
    
    
    UserLiveQuitResult *model;//直播结束的时候的ID
    
    
    
}

@property(nonatomic,strong)UIView *image;//添加的蒙版

@property(nonatomic,strong)PXYPensonView *personView;//个人信息的弹框视图

@property(nonatomic,assign)BOOL isPlaying;

@property(nonatomic,assign)BOOL isJinyin;//判断是否打开静音按钮

@property(nonatomic,assign)BOOL isFileter;//判断是否打开美颜效果

@property(nonatomic,assign)BOOL isStarFlash;//判断明星页面的闪光灯是否可以打开

@property(nonatomic,assign)BOOL isFlash;//判断是否可以打开闪关灯

@property(nonatomic,assign)int backtime;

@property(nonatomic,strong)NSTimer *pauseTimer;


@property(nonatomic,strong)ViewersMaskView *c;
@property(nonatomic,strong)StarAnchorView *staranchorView;

@property(nonatomic,strong)ZantingView *myZantingView;//点击暂停按钮的添加视图

@property(nonatomic,strong)StartViewController *StrAnchorStartView;
@property(nonatomic,strong)StarCountdownView *CountdownView;
@property(nonatomic,strong)AtOnceCountDownView *OnceCountdownView;

@property(nonatomic,strong)OrdinaryView *NormalAnchor;
@property(nonatomic,strong)NormalCategory *NormalCategoryView;

//@property(nonatomic,strong)AnchorModel *pxyAnchorModel;

@property(nonatomic,strong)CreatLiveModel *CreatLiveModel;

//@property(nonatomic,strong)PostModel *pxyPushModel;

@property(nonatomic,strong)UIView *smallview;
@property(nonatomic,strong)GPUImageFilter *filter;//美颜相关的类

@property(nonatomic,strong)KSYGPUStreamerKit *kit;//推流相关的类

@property(nonatomic,strong)GPUImageView *preview;

@property(nonatomic, nonnull,strong)MBProgressHUD *hud;

@property(nonatomic,strong)LshLiveStop *lshLiveStopView;//明星直播结束加载的页面


@end

@implementation PXYAnchorController

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self initViewersMaskView];
    
    
    _smallview = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)];
    _smallview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_smallview];
    
    //[self PXYJoinChatroom];
    
    //定位相关的方法
    [self PXYLocation];
    
    //暂停展示的页面
    _myZantingView=[ZantingView inputPauseView];
    _myZantingView.frame=self.view.bounds;
    [_myZantingView.onExitLive addTarget:self action:@selector(onExits) forControlEvents:UIControlEventTouchUpInside];
    [_myZantingView.keepLiving addTarget:self action:@selector(onKeepliving) forControlEvents:UIControlEventTouchUpInside];
    
    //明星直播页面的创建  当直播结束的时候加载这个页面
    _lshLiveStopView=[LshLiveStop inputEndLiveView];
    _lshLiveStopView.frame=self.view.bounds;
    //直播结束页面的分享按钮的点击事件
    [_lshLiveStopView.shareButton addTarget:self action:@selector(onshareLive) forControlEvents:UIControlEventTouchUpInside];
    //直播结束页面的返回按钮的点击事件
    [_lshLiveStopView.comeBackBUtton addTarget:self action:@selector(comeBack) forControlEvents:UIControlEventTouchUpInside];
    
    pauseTimeNum=0;
    _pauseTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeadd) userInfo:nil repeats:YES];
    [_pauseTimer setFireDate:[NSDate distantFuture]];
 
    
    
    
    
    
    _CreatLiveModel = [[CreatLiveModel alloc]init];
    self.CreatLiveModel.PostModel=[[PostModel alloc]init];
    //普通主播初始化
    self.CreatLiveModel.PostModel.liveType = 0;
    self.CreatLiveModel.PostModel.delaymin = 0;
    self.CreatLiveModel.PostModel.longitude = 0;
    self.CreatLiveModel.PostModel.latitude = 0;
    self.CreatLiveModel.PostModel.category = 0;
    self.CreatLiveModel.PostModel.vipUserId = 0;
    self.CreatLiveModel.PostModel.relationStar =@"";
    self.isJump=false;
    
    self.CreatLiveModel.PostModel.isHavePic=NO;
    
    
    //创建
    if (self.pander == true) {
        [self setAnchorPlay];
    }
    //继续上次
    else
    {
        self.isJump=true;
        [self setAnchorPlay];
        [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/userlive/rein" parameters:nil isCache:NO succeed:^(id data) {
            [self addData:data isliving:YES];
        } fail:^(NSString *error) {
           
            [self dismissViewControllerAnimated:YES completion:^{
                 [self toast:@"服务器忙,请稍后再试"];
            }];
        }];
        
    }
//    [self setAnchorPlay];
    
    
    
    
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopStringNotification:) name:@"stopstrmingNotification" object:nil];
    
   
    
}
//明星直播结束页面的分享按钮的点击事件
-(void)onshareLive
{
    
    _CreatLiveModel.PostModel.btnTag=0;
    for (UIButton *btn in _lshLiveStopView.ButtonArray)
    {
        if (btn.selected==YES)
        {
            _CreatLiveModel.PostModel.btnTag=btn.tag;
            break;
        }
    }
   
    [self Allshare:_CreatLiveModel.PostModel.btnTag controller:self shareUrl:model.liveShare.url title:model.liveShare.title contentValue:model.liveShare.content picUrl:model.liveShare.picUrl];
    
    //回到主页面
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:^{
        [self toast:@"分享失败"];
        
    }];

    
}
//明星直播页面的返回按钮的点击事件
-(void)comeBack
{
    //回到主页面
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];

}

//收到通知的时候的事件
-(void)stopStringNotification:(NSNotification*)notification{
    
    //@{@"content":content,@"exitLogin":@"NO"}
    NSDictionary *nameDictionary = [notification userInfo];
    [JXTAlertTools showAlertWith:self title:@"收到一条通知" message:[nameDictionary objectForKey:@"content"] callbackBlock:^(NSInteger btnIndex) {
       
        
        if ([[nameDictionary objectForKey:@"content"]isEqualToString:@"YES"])
        {
            //停止推流  退出到登录页面
            [_kit.streamerBase stopStream];
            
            Class class = NSClassFromString(@"Login_RegisController");
            UIViewController *controler=class.new;
            UINavigationController *na=[[UINavigationController alloc]initWithRootViewController:controler];
            [self.navigationController pushViewController:na animated:YES];
            
        }
        else
        {
            //停止推流 退出当前页面
            [self onExits];
            
        }
        
    } cancelButtonTitle:nil destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    //self.textLabel.text = [nameDictionary objectForKey:@"content"];
    
}
//定时器的方法
-(void)timeadd
{
    pauseTimeNum++;
    _myZantingView.liveStopTime.text=[self timeFormatted:pauseTimeNum];
    if(pauseTimeNum>=1800)
    {
        [self onExits];
    }
}

-(void)PXYLocation
{
    //定位相关的代码
    _locationManager=[[CLLocationManager alloc]init];
    if (![CLLocationManager locationServicesEnabled])
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"定位服务可能尚未打开，请设置打开" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
    {
        [_locationManager requestWhenInUseAuthorization];
    }else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //设置代理
        _locationManager.delegate=self;
        //设置定位的精确度
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //设置定位的频率 每隔多少的距离定位一次
        CLLocationDistance distance=100.0;
        _locationManager.distanceFilter=distance;
        //启动跟踪定位
        [_locationManager startUpdatingLocation];
    }
    
    //地理编码的相关的类
   // _geocoder=[[CLGeocoder alloc]init];

}

//最后一次定位成功或者超出范围的时候获取的用户的位置
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _cllocation=[locations lastObject];
    self.CreatLiveModel.PostModel.latitude =_cllocation.coordinate.latitude;
    self.CreatLiveModel.PostModel.longitude =_cllocation.coordinate.longitude;
    
    NSDictionary *dic=nil;
    dic=@{@"longitude":@(_cllocation.coordinate.longitude),@"latitude":@(_cllocation.coordinate.latitude)};
    
    [CLNetworkingManager getNetworkRequestWithUrlString:@"/rest/userlive/location" parameters:dic isCache:NO succeed:^(id data) {
        
        self.CreatLiveModel.PostModel.cityName=_StrAnchorStartView.cityNameLabel.text=data[@"city"];
        _StrAnchorStartView.cityClose.hidden=NO;
        
       
        
        
    } fail:^(NSString *error) {
        _StrAnchorStartView.cityNameLabel.text=@"定位失败";
    }];
    
}

- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

-(void)makePhoto
{
    [JXTAlertTools showActionSheetWith:self title:nil message:nil callbackBlock:^(NSInteger btnIndex) {
        if (btnIndex==1) {
            [self paizhao];
            
        }
        if (btnIndex==2) {
            [self selectFromIphone];
            
        }
        
    } destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"本地选择", nil];
}

-(void)paizhao{
    
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    if ([self isCameraAvailable]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        NSLog(@"没有摄像头");
    }
    
}

-(void)selectFromIphone
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //scale这个参数从0.1开始逐渐等比放大图片
    //    UIImage *newimage = [self makeThumbnailFromImage:image scale:0.5];
    
    
    
    [NSThread detachNewThreadSelector:@selector(saveImage:) toTarget:self withObject:image];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImage:(UIImage *)image
{
    //    _setUserImg.userHeaderImg.image=image;
    
    tempImg=image;
    
    //上传图像
    //[self uploaduserImg:image];
    
    UIImage *image2=[UIImage makeThumbnailFromImage:image scale:0.5];
    
    NSData *imageData = UIImagePNGRepresentation(image2); //PNG格式
    
    _NormalAnchor.LiveImageView.image=image2;
    
    self.CreatLiveModel.PostModel.cover =imageData;
    self.CreatLiveModel.PostModel.image =image2;
    self.CreatLiveModel.PostModel.isHavePic=YES;

}

-(void)addData:(id)data isliving:(BOOL)isliving
{
    // [self.view makeToast:data[@"message"]];
    NSLog(@"---pxy-开始直播1---%@",data);
    NSLog(@"---开始直播-2---%@",data[@"liveShare"]);
    
    
    _CreatLiveModel.userLive=[AnchorModel mj_objectWithKeyValues:data[@"userLive"]] ;
    _CreatLiveModel.userLive.prize =data[@"prize"];
    _CreatLiveModel.date =data[@"date"];
    
    _CreatLiveModel.liveShare=[ShareModel mj_objectWithKeyValues:data[@"liveShare"]] ;
    
  

    _CreatLiveModel.liveParameter=[LiveParameter mj_objectWithKeyValues:data[@"liveParameter"]] ;
    
//    if ([self.StarID.text isEqualToString:@""]) {
//        self.StarID.hidden = YES;
//    }
//    else
//    {
//        self.StarID.text = [NSString stringWithFormat:@"星ID：%@",self.CreatLiveModel.userLive.userId];
//    }
    
     _CreatLiveModel.anchorBalance=[PXYAnchorUserBalance mj_objectWithKeyValues:data[@"anchorBalance"]] ;
    
    [self.staranchorView UpdataAllinterface:(_CreatLiveModel)];
    
    [_StrAnchorStartView removeFromSuperview];
    if (isliving==YES)
    {
        [_NormalAnchor removeFromSuperview];
        [self initAtOnceCountdownView];
    }else{
        [self initStarCountdownView:_CreatLiveModel.PostModel.delaymin];
    }
    
    [self Allshare:_CreatLiveModel.PostModel.btnTag controller:self shareUrl:_CreatLiveModel.liveShare.url title:_CreatLiveModel.liveShare.title contentValue:_CreatLiveModel.liveShare.content picUrl:_CreatLiveModel.liveShare.picUrl];
    
  
}

//post上传
-(void)PostAnchorDic:(NSDictionary *)dic isStartLive:(BOOL)isliving
{
    NSLog(@"==========%@",dic);

    if (self.CreatLiveModel.PostModel.isHavePic)
    {
        CLImageModel *imageModel=[[CLImageModel alloc]init];
        //NSLog(@"图片大小%lu",(unsigned long)imageData.length);
        
        imageModel.image=_CreatLiveModel.PostModel.image;
        imageModel.field=@"cover";
        
        
        [CLNetworkingManager uploadWithURLString:@"/rest/userlive/create" parameters:dic model:imageModel progress:^(float writeKB, float totalKB) {
            
        } succeed:^(id data) {
            
            [self addData:data isliving:isliving];
            
            
        }
                                            fail:^(NSString *error) {
                                                
                                                
                                            }];
        

    }
  else
  {
      [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userlive/createNotPic" parameters:dic isCache:NO succeed:^(id data) {
          NSLog(@"=====%@",data);
          [self addData:data isliving:isliving];
      } fail:^(NSString *error) {
          [self.view makeToast:error];
          NSLog(@"--------------裴雪阳------没上传成功------%@",error);
          
      }];

  }
}







-(void)SetcoverView
{
        CGRect blurRect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        UIView *blackView = [[UIView alloc] initWithFrame:blurRect];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.7;
        [self.view addSubview:blackView];

}
-(void)setAnchorPlay
{
    //添加观察者
    [self addObservers];
    _kit=[[KSYGPUStreamerKit alloc]initWithDefaultCfg];
    //添加蒙版
    [self addControlView];
    
    //开始推流
    //[self onStream];
    //开启预览
    [self onPreview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Anchortongzhi:) name:@"Anchortongzhi" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ViewsTongzhi:) name:@"ViewsTongzhi" object:nil];
    
    //dianjigeren
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dianjigeren:) name:@"dianjigeren" object:nil];


}


// 5 10 15 倒计时选项
-(void)initStarAnchor
{
    _StrAnchorStartView =[StartViewController starAnchorStartViewView];
    _StrAnchorStartView.hidden = NO;
    _StrAnchorStartView.frame=self.view.bounds;
    [self.view addSubview:_StrAnchorStartView];
    _CreatLiveModel.PostModel.delaymin=0;
    
    //添加明星直播页面的按钮的点击事件
    [self addClickStarButton];
    //[StarAnchorView removeFromSuperview];
    
}
//添加明星直播页面的按钮的点击事件
-(void)addClickStarButton
{
    
    //_StrAnchorStartView.cityNameLabel
    
    [_StrAnchorStartView.MakeSureClick addTarget:self  action:@selector(onStartLive) forControlEvents:UIControlEventTouchUpInside];
    [_StrAnchorStartView.changePhoto addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_StrAnchorStartView.cityClose addTarget:self action:@selector(deleteDingweiStar) forControlEvents:UIControlEventTouchUpInside];
    [_StrAnchorStartView.closeLive addTarget:self action:@selector(onExits) forControlEvents:UIControlEventTouchUpInside];
     
}

//删除明星直播页面定位的按钮的调用的方法
-(void)deleteDingweiStar
{
    if (isLocation)
    {
        //点击的时候 调取定位的方法 定位主播当前所在的城市
        _StrAnchorStartView.cityNameLabel.text=self.CreatLiveModel.PostModel.cityName;
        isLocation=NO;
    }
    else
    {
        _StrAnchorStartView.cityNameLabel.text=@"火星";
        isLocation=YES;
    }
    
}
//明星直播页面开始直播按钮的点击事件
-(void)onStartLive
{
   
     _CreatLiveModel.PostModel.btnTag=0;
    for (UIButton *btn in _StrAnchorStartView.ButtonArray)
    {
        if (btn.selected==YES)
        {
            _CreatLiveModel.PostModel.btnTag=btn.tag;
            break;
        }
    }
    
    if (!isLocation)
    {
        self.CreatLiveModel.PostModel.latitude=0;
        self.CreatLiveModel.PostModel.longitude=0;
    }
    NSDictionary *dict=nil;
    dict=@{
           @"liveType":@1,
           @"delaymin":@(self.CreatLiveModel.PostModel.delaymin),
           @"longitude":@(self.CreatLiveModel.PostModel.longitude),
           @"latitude":@(self.CreatLiveModel.PostModel.latitude),
           @"category":@0,
           @"vipUserId":@0, //[NSNumber numberWithInt:self.pxyPushModel.vipUserId]
           @"relationStar":@""};
    
       [self PostAnchorDic:dict isStartLive:self.CreatLiveModel.PostModel.delaymin==0?YES:NO];
    

}

// 5 10 15 倒计时
-(void)initStarCountdownView:(int )number
{
    _CountdownView = [StarCountdownView starAnchorCountDownView];
    _CountdownView.hidden = NO;
    _CountdownView.frame=self.view.bounds;
    //[self.view addSubview:_CountdownView];
    [self.view addSubview:_CountdownView];
    
    [_CountdownView.changePhotoBtn addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = CGRectMake(0, 200, 200, 200);
    self.smallview.frame =frame;
   
    self.delegate =_CountdownView;
    [self.delegate passValue:number];
}

//立刻直播  3  2  1
-(void)initAtOnceCountdownView
{
    _OnceCountdownView = [AtOnceCountDownView CountDownView];
    _OnceCountdownView.hidden = NO;
    _OnceCountdownView.frame=self.view.bounds;
    _CreatLiveModel.PostModel=nil;
    [self.view addSubview:_OnceCountdownView];
    
    
}


////进入页面 开始预览 点击开始直播按钮之后开始直播
//-(void)onPreView
//{
//    if ( _kit.captureState != KSYCaptureStateCapturing ) {
//        [self setStreamerCfg];
//        [_kit startPreview: self.view];
//        [UIApplication sharedApplication].idleTimerDisabled=YES;
//    }
//    else {
//        [_kit stopPreview];
//        [UIApplication sharedApplication].idleTimerDisabled=NO;
//    }
//
//}




-(void)Anchortongzhi:(NSNotification *)text
{
    if ([text.userInfo[@"textTwo"] isEqualToString:@"meiyan"]) {
        
        NSLog(@"-----------------------美颜－－－－－－－－－－－－－");
        [self onChoseFilter];

    }
    
    if ([text.userInfo[@"textTwo"] isEqualToString:@"fanzhuan"]) {
//        backCam = backCam && (_kit.captureState == KSYCaptureStateCapturing);
//        [_btnFlash  setEnabled:backCam ];
        if ( [_kit switchCamera ] == NO) {
            NSLog(@"切换失败 当前采集参数 目标设备无法支持");
            
            [self toast:@"请您开始直播后再切换摄像头"];
            
        }
        BOOL backCam = (_kit.cameraPosition == AVCaptureDevicePositionBack);
        if ( backCam ) {
             //后摄像头
            [_NormalAnchor.flashBtn setEnabled:YES];
            self.isFlash=NO;
        }
        else {
           
            //前摄像头
            [_NormalAnchor.flashBtn setEnabled:NO];
            self.isFlash=YES;
            [_NormalAnchor.flashBtn setImage:[UIImage imageNamed:@"shanguangdeng2"] forState:UIControlStateNormal];
        }
        backCam = backCam && (_kit.captureState == KSYCaptureStateCapturing);
        [_btnFlash  setEnabled:backCam ];
        
    }
    
    if ([text.userInfo[@"textTwo"] isEqualToString:@"fanzhuanshexiang"]) {
        //        backCam = backCam && (_kit.captureState == KSYCaptureStateCapturing);
        //        [_btnFlash  setEnabled:backCam ];
        if ( [_kit switchCamera ] == NO) {
            NSLog(@"切换失败 当前采集参数 目标设备无法支持");
            
            [self toast:@"请您开始直播后再切换摄像头"];
            
        }
        BOOL backCam = (_kit.cameraPosition == AVCaptureDevicePositionBack);
        if ( backCam ) {
             //后摄像头
            [_staranchorView.flashStar setEnabled:YES];
            self.isStarFlash=NO;
        }
        else {
             //前摄像头
            [_staranchorView.flashStar setEnabled:NO];
            self.isStarFlash=YES;
            [_staranchorView.flashStar setImage:[UIImage imageNamed:@"shanguangdeng2"] forState:UIControlStateNormal];
        }
        backCam = backCam && (_kit.captureState == KSYCaptureStateCapturing);
        [_btnFlash  setEnabled:backCam ];
        
    }


    //调用闪关灯的方法
    if ([text.userInfo[@"textTwo"] isEqualToString:@"shanguangdeng"]) {

        [self onFlash];
      
    }
    if ([text.userInfo[@"textTwo"] isEqualToString:@"shanguangdengClick"]) {
        
        [self onFlashStar];
        
    }
    if ([text.userInfo[@"textTwo"] isEqualToString:@"guanbicategory"]) {

         [self onExits];
    }
    
    if ([text.userInfo[@"textTwo"] isEqualToString:@"guanbi"]) {
        
        [self onExits];
    }
    
    
    if ([text.userInfo[@"textTwo"] isEqualToString:@"jietu"]) {
        
        
        //[_kit.streamerBase takePhotoWithQuality:1 fileName:@"3/4/c.jpg"]; //3/4/c.jpg
         //UIImage *image = [UIImage imageNamed:@"3/4/c.jpg"];
        UIImage *iage = [UIImage  captureWithView:(self.view)];
        UIImageWriteToSavedPhotosAlbum(iage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

    }

    // 主播观众界面的分享
    if ([text.userInfo[@"textTwo"] isEqualToString:@"liveshare"]) {
        
        
        [self Allshare:5000 controller:self shareUrl:self.CreatLiveModel.liveShare.url title:self.CreatLiveModel.liveShare.title contentValue:self.CreatLiveModel.liveShare.content picUrl:self.CreatLiveModel.liveShare.picUrl];
        
    
    }
    
    // 静音
    if ([text.userInfo[@"textTwo"] isEqualToString:@"jingyin"]) {
        
        [self jinyinClick];
    }
    
    
    
    // 暂停
    if ([text.userInfo[@"textTwo"] isEqualToString:@"zanting"]) {
        
                //改变推流状态
        [self changeStrmeState];
        
    }
    
    //点击这个删除定位的按钮的时候 定位的label上面显示为火星
    if ([text.userInfo[@"textTwo"] isEqualToString:@"shanchuLocation"])
    {
        [self deleteDingwei];
    }

    
    

}
//是否静音推流
-(void)jinyinClick
{
    if (self.isJinyin==NO)
    {
        [_kit.streamerBase muteStreame:YES];
        self.isJinyin=YES;
        [_staranchorView.SoundButton setImage:[UIImage imageNamed:@"shengyinguanbi"] forState:UIControlStateNormal];
    }
    else
    {
       [_kit.streamerBase muteStreame:NO];
        self.isJinyin=NO;
        [_staranchorView.SoundButton setImage:[UIImage imageNamed:@"shengyin"] forState:UIControlStateNormal];
    }
}
//
-(void)changeStrmeState
{
//    //判断当前按钮的值 是否为假 改变按钮的图片和推流的状态
//    if (isPauseStrme)
//    {
    
        //调用暂停直播的接口
        [CLNetworkingManager putRequestWithUrlString:@"/rest/userlive/pause" parameters:@{@"liveId":_CreatLiveModel.userLive.liveId} succeed:^(id data) {
            
            //停止推流
            [_kit.streamerBase stopStream];
             isPauseStrme=YES;
//            isPauseStrme=NO;
//            [_staranchorView.StopButton setSelected:YES];
            [self.pauseTimer setFireDate:[NSDate distantPast]];
            pauseTimeNum=0;
            [_staranchorView addSubview:_myZantingView];
            ///停止推流 发出即时通讯自定义消息
        } fail:^(NSString *error) {
            
        }];
       
        

}

-(void)onKeepliving
{
    //调用继续直播的接口
    [CLNetworkingManager putRequestWithUrlString:@"/rest/userlive/play" parameters:@{@"liveId":_CreatLiveModel.userLive.liveId} succeed:^(id data) {
        
        //开启推流
        [self onStream];
//        isPauseStrme=YES;
//        [_staranchorView.StopButton setSelected:NO];
//
        [self.pauseTimer setFireDate:[NSDate distantFuture]];
       
        [_myZantingView removeFromSuperview];
        
      //重新开始推流 发出即时通信自定义消息
    } fail:^(NSString *error) {
        
    }];

}

//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
//{
//    
//    [_NormalAnchor removeFromSuperview];
//    [self initStarAnchorView];
//    
//    
//    
//    NSLog(@"分享返回：%@",response);
//    
//    
//}



-(void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{

    NSString *msg = nil ;

    if(error != NULL){
        
        msg = @"保存图片失败" ;
        
    }else{
        
        msg = @"保存图片成功" ;
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                          
                                                    message:msg
                          
                                                   delegate:self
                          
                                          cancelButtonTitle:@"确定"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
}
-(void)ViewsTongzhi:(NSNotification *)text
{

    if ([text.userInfo[@"number"] isEqualToString:@"0"]) {
        NSLog(@"-----------------------立刻直播－－－－－－－－－－－－－");
        
        //调用接口
        [CLNetworkingManager putRequestWithUrlString:@"/rest/userlive/readyok" parameters:@{@"liveId":_CreatLiveModel.userLive.liveId} succeed:^(id data) {
            
            
            [_CountdownView removeFromSuperview];
            [self initAtOnceCountdownView];
            
            
        } fail:^(NSString *error) {
            
        }];
        
    } if ([text.userInfo[@"number"] isEqualToString:@"choose0"]) {
        NSLog(@"-----------------------立刻直播－－－－－－－－－－－－－");
        
//        [_StrAnchorStartView removeFromSuperview];
//        [self initAtOnceCountdownView];
        self.CreatLiveModel.PostModel.delaymin=0;
        self.backtime=0;
        
    } if ([text.userInfo[@"number"] isEqualToString:@"5"]) {
        NSLog(@"-----------------------时间间隔直播－－－－－－－－－－－－－");
           //[_StrAnchorStartView removeFromSuperview];// 选择框
        //        [_OnceCountdownView removeFromSuperview]; // 3 2 1
        //        [_staranchorView removeFromSuperview];//fasong
        //[self initStarCountdownView:(5)];
        
        NSLog(@"点击了5分钟按钮");
        self.CreatLiveModel.PostModel.delaymin=5;
        self.backtime=5;
        
    } if ([text.userInfo[@"number"] isEqualToString:@"10"]) {
        NSLog(@"-----------------------时间间隔直播－－－－－－－－－－－－－");
        //[_StrAnchorStartView removeFromSuperview];// 选择框
        //        [_OnceCountdownView removeFromSuperview]; // 3 2 1
        //        [_staranchorView removeFromSuperview];//fasong
        //[self initStarCountdownView:(10)];
        self.CreatLiveModel.PostModel.delaymin=10;
        self.backtime=10;
        NSLog(@"点击了10分钟按钮");
        
    } if ([text.userInfo[@"number"] isEqualToString:@"15"]) {
        //[_StrAnchorStartView removeFromSuperview];// 选择框
        //        [_OnceCountdownView removeFromSuperview]; // 3 2 1
        //        [_staranchorView removeFromSuperview];//fasong
        //   [self initStarCountdownView:(15)];
         self.CreatLiveModel.PostModel.delaymin=15;
        self.backtime=15;
        NSLog(@"点击了15分钟按钮");
        
    } if ([text.userInfo[@"number"] isEqualToString:@"likezhibojieshu"]) {
        [_OnceCountdownView removeFromSuperview];
        [self initStarAnchorView];
        //倒计时3 2 1 的时候 开始推流
        _isPlaying=YES;
        [self onStream];
    } if ([text.userInfo[@"number"] isEqualToString:@"fanhui"]) {
        [_CountdownView removeFromSuperview];
        [self initStarAnchor];
        //返回按钮
        
        NSDictionary *dic=nil;
        dic=@{@"liveId":_CreatLiveModel.userLive.liveId};
        [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userlive/out" parameters:dic isCache:NO succeed:^(id data) {
            
            //[self hideBaseRequestMBProgress:NO];
            
        } fail:^(NSString *error) {
           // [self hideBaseRequestMBProgress:NO];
            
        }];

        
        
    }  if ([text.userInfo[@"number"] isEqualToString:@"My"]) {
        [_NormalCategoryView removeFromSuperview];
        [self initMyNormalAnchor];
        self.CreatLiveModel.PostModel.liveType = 0;
        
    } if ([text.userInfo[@"number"] isEqualToString:@"Star"]) {
        [_NormalCategoryView removeFromSuperview];
        self.CreatLiveModel.PostModel.liveType = 1;
        [self initStarNormalAnchor];
        
    }
    if ([text.userInfo[@"number"] isEqualToString:@"Stardd"]) {
        
        self.CreatLiveModel.PostModel.liveType = 1;
        
        
    }
    if ([text.userInfo[@"number"] isEqualToString:@"Mydd"]) {
       
        self.CreatLiveModel.PostModel.liveType = 0;
      
        
    }
    //普通主播点击确定
    if ([text.userInfo[@"number"] isEqualToString:@"normalstart"]) {
//        
//    [self PostWithNoPhotoAnchorDic:@{
//                                       @"liveType":[NSNumber numberWithInt:self.pxyPushModel.liveType],
//                                       @"delaymin":[NSNumber numberWithInt:self.pxyPushModel.delaymin],
//                                       @"longitude":[NSNumber numberWithInt:self.pxyPushModel.longitude],
//                                       @"latitude":[NSNumber numberWithInt:self.pxyPushModel.latitude],
//                                       @"category":[NSNumber numberWithInt:self.pxyPushModel.category],
//                                       @"vipUserId":[NSNumber numberWithInt:self.pxyPushModel.vipUserId], //[NSNumber numberWithInt:self.pxyPushModel.vipUserId]
//                                       @"relationStar":self.pxyPushModel.relationStar}];
//
//        
//    }
        
        _CreatLiveModel.PostModel.btnTag=0;
        for (UIButton *btn in _NormalAnchor.ButtonArray)
        {
            if (btn.selected==YES)
            {
                _CreatLiveModel.PostModel.btnTag=btn.tag;
                break;
            }
        }
        
        if (!isLocation)
        {
            self.CreatLiveModel.PostModel.latitude=0;
            self.CreatLiveModel.PostModel.longitude=0;
        }

        
        
        if (_CreatLiveModel.PostModel.liveType==0)
        {
            
            if (self.CreatLiveModel.PostModel.isHavePic)
            {
                [self PostAnchorDic:@{
                                      @"liveType":@0,
                                      @"delaymin":@0,
                                      @"longitude":@(self.CreatLiveModel.PostModel.longitude),
                                      @"latitude":@(self.CreatLiveModel.PostModel.latitude),
                                      @"category":@(_NormalAnchor.selectIndex-300>0?_NormalAnchor.selectIndex-300:0),
                                      @"vipUserId":@0, //[NSNumber numberWithInt:self.pxyPushModel.vipUserId]
                                      @"relationStar":@"",
                                      @"cover":_CreatLiveModel.PostModel.cover} isStartLive:YES];
            }
            else
            {
                [self PostAnchorDic:@{
                                      @"liveType":@0,
                                      @"delaymin":@0,
                                      @"longitude":@(self.CreatLiveModel.PostModel.longitude),
                                      @"latitude":@(self.CreatLiveModel.PostModel.latitude),
                                      @"category":@(_NormalAnchor.selectIndex-300>0?_NormalAnchor.selectIndex-300:0),
                                      @"vipUserId":@0, //[NSNumber numberWithInt:self.pxyPushModel.vipUserId]
                                      @"relationStar":@""} isStartLive:YES];
            }
            

        }
        else if(_CreatLiveModel.PostModel.liveType==1)
        {
        
          
            if (self.CreatLiveModel.PostModel.isHavePic)
            {
                [self PostAnchorDic:@{
                                      @"liveType":@1,
                                      @"delaymin":@0,
                                      @"longitude":@(self.CreatLiveModel.PostModel.longitude),
                                      @"latitude":@(self.CreatLiveModel.PostModel.latitude),
                                      @"category":@(_NormalAnchor.selectIndex-290>0?_NormalAnchor.selectIndex-290:0),
                                      @"vipUserId":@([_NormalAnchor.searchStarId  integerValue]), //[NSNumber numberWithInt:self.pxyPushModel.vipUserId]
                                      @"relationStar":_NormalAnchor.searchText,
                                      @"cover":_CreatLiveModel.PostModel.cover} isStartLive:YES];
            }
            else
            {
                [self PostAnchorDic:@{
                                      @"liveType":@1,
                                      @"delaymin":@0,
                                      @"longitude":@(self.CreatLiveModel.PostModel.longitude),
                                      @"latitude":@(self.CreatLiveModel.PostModel.latitude),
                                      @"category":@(_NormalAnchor.selectIndex-290>0?_NormalAnchor.selectIndex-290:0),
                                      @"vipUserId":@([_NormalAnchor.searchStarId  integerValue]), //[NSNumber numberWithInt:self.pxyPushModel.vipUserId]
                                      @"relationStar":_NormalAnchor.searchText} isStartLive:YES];
                
            }

        }
            
     }
    //点击按钮的时候选择上传照片的方式
    else if ([text.userInfo[@"number"] isEqualToString:@"chagephoto"]) {
        
        [self makePhoto];
    }
    

}

-(void)dianjigeren:(NSNotification *)text
{
    //添加个人信息的弹框视图
    
    //_personView=[self customPersonViewWithUserId:text.userInfo[@"text"] isTrue:YES];
//    _image=[[UIView alloc]initWithFrame:self.view.bounds];
//    _image.backgroundColor=[UIColor blackColor];
//    _image.alpha=0.6;
    //给页面添加单击的手势
//    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
//    [_image addGestureRecognizer:tapGesture];

    //[self.view addSubview:_personView];
//    [_personView addSubview:_image];
    
    //添加个人信息的弹框视图
    _personView=[self customPersonViewWithUserId:text.userInfo[@"text"] isTrue:YES isSuccess:^{
        
        KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)KLCPopupHorizontalLayoutCenter,
                                                   (KLCPopupVerticalLayout)KLCPopupVerticalLayoutCenter);
        popup = [KLCPopup popupWithContentView:_personView
                                      showType:KLCPopupShowTypeFadeIn
                                   dismissType:KLCPopupDismissTypeFadeOut
                                      maskType:KLCPopupMaskTypeDimmed
                      dismissOnBackgroundTouch:YES
                         dismissOnContentTouch:NO];
        
        
        [popup showWithLayout:layout duration:20.0];
        
        [popup show];
    }];
    
   
    
}

//点击删除个人信息的弹框视图
-(void)tapgesture:(UITapGestureRecognizer *)state
{
    //[_image removeFromSuperview];
    [_personView removeFromSuperview];
    
}


//删除定位的按钮的调用的方法
-(void)deleteDingwei
{
    if (isLocation)
    {
        //点击的时候 调取定位的方法 定位主播当前所在的城市
        _NormalAnchor.cityLable.text=@"北京市";
        isLocation=NO;
    }
    else
    {
        _NormalAnchor.cityLable.text=@"火星";
        isLocation=YES;
    }
    
}


//删除通知
-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(StarAnchorView *)staranchorView

{
    if (!_staranchorView) {
        _staranchorView=[StarAnchorView ViewersView];
        
    }
    return _staranchorView;
    
    
}
-(void)initStarAnchorView
{
    //_controlView.backgroundColor =[UIColor clearColor];
    [_controlView removeFromSuperview];
    
//    _staranchorView = [StarAnchorView ViewersView];
    _staranchorView.hidden = NO;
    _staranchorView.frame=self.view.bounds;
    [self.view addSubview:_staranchorView];
    
    _CloseButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - 12 , 24, 30, 30)];
    
    [_CloseButton addTarget:self action:@selector(clickGuanbi) forControlEvents:UIControlEventTouchUpInside];
    
    [_CloseButton setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    
    [self.view addSubview:_CloseButton];
    //[self.baseView insertSubview:_CloseButton atIndex:500];
    
    
    _StarID = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-130,_CloseButton.bottom+12 , 120, 17)];
   // _StarID = [[UILabel alloc]initWithFrame:CGRectMake(280, 68, 78, 17)];
    _StarID.shadowColor = [UIColor blackColor];
    _StarID.textColor = [UIColor whiteColor];
    _StarID.font = [UIFont systemFontOfSize:(12)];
    _StarID.shadowOffset = CGSizeMake(1, 0);
    _StarID.textAlignment = NSTextAlignmentRight;
    _StarID.layer.shadowOpacity = 0.5;
    [self.view addSubview:_StarID];
    
    
    [self addSwipeGesture];
}


-(void)clickGuanbi
{

    self.Anchornumber = @"guanbi";
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.Anchornumber,@"textTwo", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"Anchortongzhi" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];


}
//----------------------------------------------推流
-(MBProgressHUD *)hud
{
    if (_hud==nil)
    {
        _hud=[[MBProgressHUD alloc]initWithView:self.view];
        
    }
    return _hud;
}
-(void)addHub:(NSString *)message
{
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    self.hud.labelText=message;
    
    [self.hud hide:YES afterDelay:2];
}
-(KSYGPUStreamerKit *)getStreamer
{
    return _kit;
}


//添加覆盖在页面上的View  view上可以添加各种按钮控件
-(void)addControlView
{
    _controlView=[[UIView alloc]initWithFrame:self.view.bounds];
   // _controlView.backgroundColor=[UIColor clearColor];
    
    _controlView.backgroundColor = [UIColor blackColor];
    _controlView.alpha = 0.7;

    [self.view addSubview:_controlView];
    [self addSwipeGesture];
    [self configUI];
}



//添加上面的覆盖视图View  添加一个滑动手势 使其消失和出现
- (void)addSwipeGesture{
    UISwipeGestureRecognizer *swiptGestureToRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeController:)];
    [self.view addGestureRecognizer:swiptGestureToRight];
    
    UISwipeGestureRecognizer *swiptGestureToLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeController:)];
    [self.view addGestureRecognizer:swiptGestureToLeft];
    swiptGestureToLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    
}

- (void)swipeController:(UISwipeGestureRecognizer *)state{
    if (state.direction == UISwipeGestureRecognizerDirectionRight) {
        [UIView animateWithDuration:0.5 animations:^{
            _staranchorView.layer.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }else if (state.direction == UISwipeGestureRecognizerDirectionLeft){
        [UIView animateWithDuration:0.5 animations:^{
            _staranchorView.layer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{

    //[self configUI];


}



//布局页面
-(void)configUI
{
    _preview    = [[GPUImageView alloc] init];
    [_preview setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [self.view addSubview:_preview];
    NSLog(@"ddddddddd%@",[AccountModel read].vip);
    
    if(self.isJump)
    {
        
    }else{
    if ([[NSString stringWithFormat:@"%@",[AccountModel read].vip]  isEqualToString: @"1"]) {
        
        [self initStarAnchor];
        
    }else
    {
        [self initNormalCategor];
    
    }
    }
     //[self initStarAnchor];
    //以前的按钮
    //[self beforeButtons];
    
    
}
-(void)initNormalCategor
{
    
    _NormalCategoryView =[NormalCategory NormalCategoryView];
    _NormalCategoryView.hidden = NO;
    _NormalCategoryView.frame=self.view.bounds;
    [self.view addSubview:_NormalCategoryView];
    [_NormalCategoryView.Guanbi addTarget:self action:@selector(onExits) forControlEvents:UIControlEventTouchUpInside];
    //[StrAnchorStartView removeFromSuperview];
    
}


-(void)initStarNormalAnchor
{

    _NormalAnchor =[OrdinaryView OrdinaryViewStart];
    _NormalAnchor.hidden = NO;
    _NormalAnchor.LableButton.hidden=NO;
   [_NormalAnchor  StarLive];
    _NormalAnchor.frame=self.view.bounds;
    [self.view addSubview:_NormalAnchor];
    _NormalAnchor.searchText=@"";
    _NormalAnchor.searchStarId=0;
    _NormalAnchor.selectIndex=0;
    
    //点击取消定位按钮的时候 应该清除城市的定位 显示在火星
    //[_NormalAnchor.deleteLocationBtn addTarget:self action:@selector(deleteDingwei) forControlEvents:UIControlEventTouchUpInside];

    //[StrAnchorStartView removeFromSuperview];

}

-(void)initMyNormalAnchor
{
    
    _NormalAnchor =[OrdinaryView OrdinaryViewStart];
    _NormalAnchor.hidden = NO;
    _NormalAnchor.LableButton.hidden=YES;
    [_NormalAnchor  MyLive];
    _NormalAnchor.frame=self.view.bounds;
    [self.view addSubview:_NormalAnchor];
    //[StrAnchorStartView removeFromSuperview];
    
}


-(void)beforeButtons
{
//        NSArray *stringArr=@[@"原始效果",@"美颜",@"美白++"];
//        _btnFilters1=[[UIButton alloc]initWithFrame:CGRectMake(0, 400, 40, 40)];
//        _btnFilters2=[[UIButton alloc]initWithFrame:CGRectMake(50, 400, 40, 40)];
//        _btnFilters3=[[UIButton alloc]initWithFrame:CGRectMake(100, 400, 40, 40)];
//        [_btnFilters1 setTitle:stringArr[0] forState:UIControlStateNormal];
//        [_btnFilters2 setTitle:stringArr[1] forState:UIControlStateNormal];
//        [_btnFilters3 setTitle:stringArr[2] forState:UIControlStateNormal];
//    
//        _btnFilters1.backgroundColor=[UIColor purpleColor];
//        _btnFilters2.backgroundColor=[UIColor purpleColor];
//        _btnFilters3.backgroundColor=[UIColor purpleColor];
//    
//        _btnFilters1.tag=100;
//        _btnFilters2.tag=101;
//        _btnFilters3.tag=102;
//        [_btnFilters1 addTarget:self action:@selector(OnChoseFilter:) forControlEvents:UIControlEventTouchUpInside];
//        [_btnFilters2 addTarget:self action:@selector(OnChoseFilter:) forControlEvents:UIControlEventTouchUpInside];
//        [_btnFilters3 addTarget:self action:@selector(OnChoseFilter:) forControlEvents:UIControlEventTouchUpInside];
//        [_controlView addSubview:_btnFilters1];
//        [_controlView addSubview:_btnFilters2];
//        [_controlView addSubview:_btnFilters3];
    
    
    
            //设置采集和推流参数 主要是对分辨率 帧率等参数进行设置
            //_streamer.videoDimension=KSYVideoDimension_16_9__640x360;
        _btnExit=[[UIButton alloc]initWithFrame:CGRectMake(150, 0, 100, 50)];
        _btnExit.backgroundColor=[UIColor purpleColor];
        [_btnExit setTitle:@"退出直播" forState:UIControlStateNormal];
        [_btnExit addTarget:self action:@selector(onExits) forControlEvents:UIControlEventTouchUpInside];
        [_controlView addSubview:_btnExit];
    
    
        _label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        _label.backgroundColor=[UIColor whiteColor];
        //_label.text=[self timeFormatted:0];
        _label.font=[UIFont systemFontOfSize:12];
        _label.textColor=[UIColor redColor];
        [_controlView addSubview:_label];
    
        _button=[[UIButton alloc]initWithFrame:CGRectMake(200, 400, 100, 50)];
        _button.backgroundColor=[UIColor lightGrayColor];
        [_button setTitle:@"开始直播" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(onStream) forControlEvents:UIControlEventTouchUpInside];
        [_controlView addSubview:_button];
    
    
        _btnCamera=[[UIButton alloc]initWithFrame:CGRectMake(50, 460, 70, 50)];
        _btnCamera.backgroundColor=[UIColor purpleColor];
        _btnCamera.hidden=YES;
    
        [_btnCamera addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
        //_btnCamera  = [self addButton:@"前后摄像头" action:@selector(onCamera:)];
        [_btnCamera setTitle:@"摄像头" forState:UIControlStateNormal];
        [_controlView addSubview:_btnCamera];
        _btnFlash=[[UIButton alloc]initWithFrame:CGRectMake(150, 460, 70, 50)];
        [_btnFlash setTitle:@"闪光灯" forState:UIControlStateNormal];
        _btnFlash.backgroundColor=[UIColor purpleColor];
        _btnFlash.hidden=YES;
        [_btnFlash addTarget:self action:@selector(onFlash:) forControlEvents:UIControlEventTouchUpInside];
        //_btnFlash   = [self addButton:@"闪光灯"    action:@selector(onFlash:)];
        [_controlView addSubview:_btnFlash];
    


}
-(void)onChoseFilter
{
    if (_isFileter)
    {
        _filter = [[KSYGPUBeautifyFilter alloc] init]; //原始效果
        [_kit setupFilter:_filter];
        _isFileter=NO;
        
        [_staranchorView.filterBtn setImage:[UIImage imageNamed:@"meifuguanbi"] forState:UIControlStateNormal];
    }
    else
    {
        _filter = [[KSYGPUBeautifyPlusFilter alloc] init];//美颜＋＋
        [_kit setupFilter:_filter];
        _isFileter=YES;
        [_staranchorView.filterBtn setImage:[UIImage imageNamed:@"meifu-1"] forState:UIControlStateNormal];
    }

}
//-(void)OnChoseFilter:(UIButton *)btn
//{
//    if (btn.tag==100)
//    {
//        _btnFilters1=btn;
//        //KSYGPUBeautifyExtFilter
//        _filter = [[KSYGPUBeautifyFilter alloc] init]; //原始效果
//        [_kit setupFilter:_filter];
//    }
//    else if (btn.tag==101)
//    {
//        _btnFilters2=btn;
//        _filter = [[KSYGPUBeautifyExtFilter alloc] init]; //美颜
//        
//        [_kit setupFilter:_filter];
//        
//    }
//    else if (btn.tag==102)
//    {
//        _btnFilters3=btn;
//        _filter = [[KSYGPUBeautifyPlusFilter alloc] init];//美颜＋＋
//        [_kit setupFilter:_filter];
//    }
//    
//    
//}
//点击按钮退出直播
-(void)onExits
{
    
    NSLog(@"liveId%@",StringWithFormat(_CreatLiveModel.userLive.liveId));
    //暂停页面从父视图上清除
//    for (UIView *view in self.view.subviews)
//    {
//        if ([view isKindOfClass:[ZantingView class]])
//        {
//            [view removeFromSuperview];
//        }
//    }
    
    
    [self removeNotifiction];
    
    
    
    [_myZantingView removeFromSuperview];
    
    if (![StringWithFormat(_CreatLiveModel.userLive.liveId) isEqualToString:@"(null)"] && _isPlaying)
    {
        NSDictionary *dic=nil;
        dic=@{@"liveId":_CreatLiveModel.userLive.liveId};
        [self hideBaseRequestMBProgress:YES];
        [CLNetworkingManager postNetworkRequestWithUrlString:@"/rest/userlive/out" parameters:dic isCache:NO succeed:^(id data) {
            
            if(_CreatLiveModel.userLive.userLiveBase.roomId!=NULL)
            {
                [[[NIMSDK sharedSDK] chatroomManager] exitChatroom: _CreatLiveModel.userLive.userLiveBase.roomId completion:nil];
            }
            model=[UserLiveQuitResult  mj_objectWithKeyValues:data];
            //停止直播之后 添加直播结束的页面 给页面的属性赋值
            
            _lshLiveStopView.lookerNumber.text=model.liveHits;
            _lshLiveStopView.tapMumber.text=model.applauseNum;
            _lshLiveStopView.fansNumbser.text=model.followNum;
            _lshLiveStopView.liveTimer.text=model.playTimeStr;
            
            [self.view addSubview:_lshLiveStopView];
            [self lshTuichuZhiBo];
            
            [self hideBaseRequestMBProgress:NO];
            
        } fail:^(NSString *error) {
            [self hideBaseRequestMBProgress:NO];
            
            [self toast:@"服务器忙,请稍后再试"];
        }];
        
        
        
        
        //
        
    }
    else
    {
        [self lshTuichuZhiBo];
        //回到主页面
        //[self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];

    }

    
}

//移除通知
-(void)removeNotifiction
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Anchortongzhi" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ViewsTongzhi" object:nil];
    
    //dianjigeren
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dianjigeren" object:nil];

}
-(void)lshTuichuZhiBo
{
    [AccountModel shareAccount].isStrming=NO;
    
    [_kit setTorchMode:AVCaptureTorchModeOff];
    //停止推流
    [_kit.streamerBase stopStream];
    //删除观测者
    [self rmObservers];
  
}

//个人直播页面的闪光灯按钮的点击事件
-(void)onFlash
{
    if (self.isFlash==NO)
    {
        [_kit setTorchMode:AVCaptureTorchModeOn];
        self.isFlash=YES;
        [_NormalAnchor.flashBtn setImage:[UIImage imageNamed:@"shanguangdeng1"] forState:UIControlStateNormal];
    }
    else
    {
        [_kit setTorchMode:AVCaptureTorchModeOff];
        self.isFlash=NO;
        [_NormalAnchor.flashBtn setImage:[UIImage imageNamed:@"shanguangdeng2"] forState:UIControlStateNormal];
    }
}
//明星直播页面的闪关灯按钮的点击事件
-(void)onFlashStar
{
    if (self.isStarFlash==NO)
    {
        [_kit setTorchMode:AVCaptureTorchModeOn];
        self.isStarFlash=YES;
        [_staranchorView.flashStar setImage:[UIImage imageNamed:@"shanguangdeng1"] forState:UIControlStateNormal];
    }
    else
    {
        [_kit setTorchMode:AVCaptureTorchModeOff];
        self.isStarFlash=NO;
        [_staranchorView.flashStar setImage:[UIImage imageNamed:@"shanguangdeng2"] forState:UIControlStateNormal];
    }

}

//闪光灯控制的按钮的点击事件
- (void)onFlash:(id)sender {
    
    if (self.isFlash==NO)
    {
        [_kit setTorchMode:AVCaptureTorchModeOff];
        self.isFlash=YES;
        [_NormalAnchor.flashBtn setImage:[UIImage imageNamed:@"shanguangdeng2"] forState:UIControlStateNormal];
    }
    else
    {
         [_kit setTorchMode:AVCaptureTorchModeOn];
        self.isFlash=NO;
        [_NormalAnchor.flashBtn setImage:[UIImage imageNamed:@"shanguangdeng1"] forState:UIControlStateNormal];
    }
    
}
//转换摄像头的按钮的点击事件
- (void)onCamera:(id)sender {
    
    if ( [_kit switchCamera ] == NO) {
        NSLog(@"切换失败 当前采集参数 目标设备无法支持");
        
        [self toast:@"请您开始直播后再切换摄像头"];
        
    }
    BOOL backCam = (_kit.cameraPosition == AVCaptureDevicePositionBack);
    if ( backCam ) {
        [_btnCamera setTitle:@"前摄像" forState: UIControlStateNormal];
       
    }
    else {
        [_btnCamera setTitle:@"后摄像" forState: UIControlStateNormal];
        
    }
    backCam = backCam && (_kit.captureState == KSYCaptureStateCapturing);
    [_btnFlash  setEnabled:backCam ];
}

#pragma mark - add UIs to view
- (UIButton *)addButton:(NSString*)title
                 action:(SEL)action {
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:button];
    return button;
}

//点击按钮开始推流
- (void)onStream {
    
    NSLog(@"=======开始直播了");
    
   

    
    [AccountModel shareAccount].isStrming=YES;
    //设置正在直播的状态
    //isPauseStrme=NO;
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //设置推流参数
        [self setStreamerCfg];
        
        
        
         //处理耗时操作的代码块...
        [self setCaptureCfg];
        
        //通知主线程刷新
      // dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
    
            [_kit startPreview: self.view];
            _btnCamera.hidden=NO;
            _btnFlash.hidden=NO;
            [self addObservers ];
            [UIApplication sharedApplication].idleTimerDisabled=YES;

            [_kit.streamerBase startStream:[NSURL URLWithString:_CreatLiveModel.userLive.userLiveBase.pushUrl]];
    
    NSLog(@"=========pxy 推流======%@===================",_CreatLiveModel.userLive.userLiveBase.pushUrl);
    
            [self initStatData];
//        });
//        
//    });

}

-(void)onPreview
{
    NSLog(@"开始预览画面，没有开始直播");
    [self setCaptureCfg]; // update capture settings
    [_kit startPreview: self.view];

}
#pragma mark - status monitor
- (void) initStatData {
    _lastByte    = 0;
    _lastSecond  = [[NSDate date]timeIntervalSince1970];
    _lastFrames  = 0;
    _netEventCnt = 0;
    _raiseCnt    = 0;
    _dropCnt     = 0;
    _startTime   =  [[NSDate date]timeIntervalSince1970];
}
- (void) setStreamerCfg {
    
    // stream settings
    //软件软解码
    //_kit.streamerBase.videoCodec = KSYVideoCodec_X264;
    
    //视频编码器，默认为264编码  视频硬编码 iOS8.0以后支持
    _kit.streamerBase.videoCodec = KSYVideoCodec_VT264;
    //视频编码起始码率（单位:kbps, 默认:500）
//    _kit.streamerBase.videoInitBitrate = 1000; // k bit ps
//    //下面两个属性设置最高编码率和最低编码率 编码率越高 视频的显示效果就会越好
//    _kit.streamerBase.videoMinBitrate  =1000; // k bit ps
//    _kit.streamerBase.videoMinBitrate  = 400; // k bit ps
    
    _kit.streamerBase.videoInitBitrate = [self.CreatLiveModel.liveParameter.rate intValue]; // k bit ps
    //下面两个属性设置最高编码率和最低编码率 编码率越高 视频的显示效果就会越好
    _kit.streamerBase.videoMinBitrate  =[self.CreatLiveModel.liveParameter.rate intValue]; // k bit ps
    _kit.streamerBase.videoMinBitrate  = [self.CreatLiveModel.liveParameter.minRate intValue]; // k bit ps
    
    
    //音频编码率
    
    _kit.streamerBase.audiokBPS        = 48; // k bit ps
    //设置自动调整音频的编码率
    _kit.streamerBase.enAutoApplyEstimateBW = YES;
    //收集网络相关状态的日志，默认开启
    _kit.streamerBase.shouldEnableKSYStatModule = YES;
    _kit.streamerBase.logBlock = ^(NSString* str){
        //NSLog(@"%@", str);
    };
    
    // rtmp server info
    if (_streamerUrl == nil){
        // stream name = 随机数 + codec名称 （构造流名，避免多个demo推向同一个流）
//        NSString *devCode  = [ [PXYAnchorController getUuid] substringToIndex:3];
//        NSString *codecSuf = _kit.streamerBase.videoCodec == KSYVideoCodec_QY265 ? @"265" : @"264";
//        NSString *streamName = [NSString stringWithFormat:@"%@.%@", devCode, codecSuf ];
//        
//        // hostURL = rtmpSrv + streamName
        
        //NSString *rtmpSrv  = @"rtmp://push.grtstar.com/live/96e79218965eb72c92a549dd5a330112";// rtmp://test.uplive.ksyun.com/live
//        NSString *url      = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, streamName];
        //_streamerUrl = [[NSURL alloc] initWithString:rtmpSrv];//url
        
        _streamerUrl = [[NSURL alloc] initWithString:_CreatLiveModel.userLive.userLiveBase.pushUrl];//推流地址
        NSLog(@"------------------推流地址------%@--------------------",_CreatLiveModel.userLive.userLiveBase.pushUrl);
        
        //_streamerUrl = [[NSURL alloc] initWithString:rtmpSrv];
    }
    [self setVideoOrientation];
}

//设置视频界面的朝向
- (void) setVideoOrientation {
    //UIInterfaceOrientation orgin=UIDeviceOrientationPortrait;
    UIInterfaceOrientation orien = [[UIApplication sharedApplication] statusBarOrientation];
    [_kit setVideoOrientationBy:orien];
    
}
+ (NSString *) getUuid{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
//引用一个cmsamplebuffer，包含零个或多个压缩的比照对象（或压缩）一个特定的媒体类型（音频、视频、混合样品，等）。
#pragma mark - image process
void processVideo (CMSampleBufferRef sampleBuffer) {
    CVPixelBufferRef imgBuf = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imgBuf, 0);
    uint8_t * uSrc = CVPixelBufferGetBaseAddressOfPlane(imgBuf, 1);
    int wdt = (int)CVPixelBufferGetBytesPerRowOfPlane(imgBuf, 1);
    const int offset = 20*wdt;
    for (int j = 0; j < 3; ++j){
        uSrc += offset;
        memset( uSrc, j*80, offset);
    }
    CVPixelBufferUnlockBaseAddress(imgBuf, 0);
}


#pragma mark - stream setup (采集推流参数设置)
- (void) setCaptureCfg {
    // capture settings
    
    //视频的分辨率
    _kit.videoDimension = KSYVideoDimension_16_9__960x540;
    //_kit.videoDimension = KSYVideoDimension_16_9__640x360;
    //视频的帧率
    //_kit.videoFPS = 20;
    _kit.videoFPS = [self.CreatLiveModel.liveParameter.frames intValue];
    //其他平台的音乐和本平台的音乐可以共存
    _kit.bInterruptOtherAudio = YES;
    //视频处理的回调函数
    _kit.videoProcessingCallback = ^(CMSampleBufferRef sampleBuffer){
        //        processVideo(sampleBuffer);
    };
    [self setVideoOrientation];
}
//添加观察者
- (void) addObservers {
    // statistics update every seconds
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(updateStat:)
                                             userInfo:nil
                                              repeats:YES];
    //KSYStreamer state changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCaptureStateChange:)
                                                 name:KSYCaptureStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStreamStateChange:)
                                                 name:KSYStreamStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetStateEvent:)
                                                 name:KSYNetStateEventNotification
                                               object:nil];
}
//删除
- (void) rmObservers {
    if (_timer) {
        [_timer setFireDate:[NSDate distantFuture]];
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSYCaptureStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSYStreamStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSYNetStateEventNotification
                                                  object:nil];
}


#pragma mark - state machine (state transition)
- (void) onCaptureStateChange:(NSNotification *)notification {
    
    if ( _kit.captureState == KSYCaptureStateIdle){
        //_stat.text = @"idle";
        [_button setEnabled:YES];
        [_button setTitle:@"Start" forState:UIControlStateNormal];
    }
    else if (_kit.captureState == KSYCaptureStateCapturing ) {
        // _stat.text = @"capturing";
        [_button setEnabled:YES];
        //[_btnTStream setEnabled:YES];
        [_button setTitle:@"Stop" forState:UIControlStateNormal];
        BOOL backCam = (_kit.cameraPosition == AVCaptureDevicePositionBack);
        [_btnFlash   setEnabled:backCam];
        //        [_btnAutoBw  setEnabled:NO];
        //        [_btnHighRes setEnabled:NO];
    }
    else if (_kit.captureState == KSYCaptureStateClosingCapture ) {
        //_stat.text = @"closing capture";
        [_button setEnabled:NO];
    }
    else if (_kit.captureState == KSYCaptureStateDevAuthDenied ) {
        //_stat.text = @"camera/mic Authorization Denied";
        [_button setEnabled:YES];
    }
    else if (_kit.captureState == KSYCaptureStateParameterError ) {
        //_stat.text = @"capture devices ParameterError";
        [_button setEnabled:YES];
    }
    else if (_kit.captureState == KSYCaptureStateDevBusy ) {
        //_stat.text = @"device busy, try later";
        //[self toast:_stat.text];
    }
    NSLog(@"newCapState: %lu", (unsigned long)_kit.captureState);
}

//网络状态改变的时候的通知
- (void) onNetStateEvent:(NSNotification *)notification {
    KSYNetStateCode netEvent = _kit.streamerBase.netStateCode;
    //NSLog(@"net event : %ld", (unsigned long)netEvent );
    if ( netEvent == KSYNetStateCode_SEND_PACKET_SLOW ) {
        _netEventCnt++;
        if (_netEventCnt % 10 == 9) {
            //[self toast:@"网络错误"];
            [self addHub:@"网络错误"];
        }
        NSLog(@"bad network" );
    }
    else if ( netEvent == KSYNetStateCode_EST_BW_RAISE ) {
        _netEventRaiseDrop = @"raising";
        _raiseCnt++;
        _netTimeOut = 5;
        
        //[self addHub:@"码率上调"];
        NSLog(@"bitrate raising" );
    }
    else if ( netEvent == KSYNetStateCode_EST_BW_DROP ) {
        _netEventRaiseDrop = @"dropping";
        _dropCnt++;
        _netTimeOut = 5;
        //[self toast:@"估计带宽调整，下调"];
        //[self addHub:@"带宽上调"];
        NSLog(@"bitrate dropping");
    }
    else if ( netEvent == KSYNetStateCode_KSYAUTHFAILED ) {
        _netEventRaiseDrop = @"auth failed";
        //[self toast:@"SDK 鉴权失败"];
        //[self addHub:@"SDK 鉴权失败"];
        NSLog(@"SDK auth failed, SDK will stop stream in a few minius" );
    }
}

//推流的状态改变的时候的通知
- (void) onStreamStateChange:(NSNotification *)notification {
    
    if ( _kit.streamerBase.streamState == KSYStreamStateIdle) {
        
        //kongixna
    }
    else if ( _kit.streamerBase.streamState == KSYStreamStateConnected){
        
        if (_kit.streamerBase.streamErrorCode == KSYStreamErrorCode_KSYAUTHFAILED ) {
            NSLog(@"Auth failed, stream would stop in 5~8 minute");
            //_stat.text = @"connected(auth failed";
            //[self toast:@"权限失败，稍后退出"];
        }
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnecting ) {
        //_stat.text = @"connecting";
        //[self toast:@"连接中..."];
        [self addHub:@"连接中..."];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateDisconnecting ) {
        // _stat.text = @"disconnecting";
        //[self toast:@"断开连接"];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateError ) {
        [self onStreamError];
        return;
    }
    NSLog(@"newState: %lu", (unsigned long)_kit.streamerBase.streamState);
}

//推流产生错误的时候的通知
- (void) onStreamError {
    KSYStreamErrorCode err = _kit.streamerBase.streamErrorCode;
    
    if ( KSYStreamErrorCode_FRAMES_THRESHOLD == err ) {
        //_stat.text = @"SDK auth failed, \npls check ak/sk";
        
        //[self toast:@"鉴权失败"];
    }
    else if ( KSYStreamErrorCode_CODEC_OPEN_FAILED == err) {
        //_stat.text = @"Selected Codec not supported \n in this version";
        //[self toast:@"无法打开配置指示的CODEC"];
    }
    else if ( KSYStreamErrorCode_CONNECT_FAILED == err) {
        //_stat.text = @"Connecting error, pls check host url \nor network";
        [self toast:@"连接出错，检查地址"];
    }
    else if ( KSYStreamErrorCode_CONNECT_BREAK == err) {
        //_stat.text = @"Connection break";
        [self toast:@"网络连接中断"];
    }
    else if (  KSYStreamErrorCode_RTMP_NonExistDomain   == err) {
        //_stat.text = @"error: NonExistDomain";
        //[self toast:@"rtmp 推流域名不存在 (KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_NonExistApplication   == err) {
        //_stat.text = @"error: NonExistApplication";
        //[self toast:@"rtmp 应用名不存在(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_AlreadyExistStreamName   == err) {
        //_stat.text = @"error: AlreadyExistStreamName";
       // [self toast:@"rtmp 流名已存在(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_ForbiddenByBlacklist   == err) {
        //_stat.text = @"error: ForbiddenByBlacklist";
        //[self toast:@"rtmp 被黑名单拒绝(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_InternalError   == err) {
        //_stat.text = @"error: InternalError";
       // [self toast:@" rtmp 内部错误(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_URLExpired   == err) {
        //_stat.text = @"error: URLExpired";
        //[self toast:@"rtmp URL 地址已过期(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_SignatureDoesNotMatch   == err) {
        //_stat.text = @"error: SignatureDoesNotMatch";
        //[self toast:@"rtmp URL 地址签名错误(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_InvalidAccessKeyId   == err) {
        //_stat.text = @"error: InvalidAccessKeyId";
        //[self toast:@"rtmp URL 中AccessKeyId非法(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_BadParams   == err) {
        //_stat.text = @"error: BadParams";
        //[self toast:@"rtmp URL 中参数错误(KSY 自定义)"];
    }
    else if (  KSYStreamErrorCode_RTMP_ForbiddenByRegion   == err) {
        //_stat.text = @"error: ForbiddenByRegion";
        //[self toast:@"rtmp URL 中的推流不在发布点内"];
    }
    else if ( KSYStreamErrorCode_NO_INPUT_SAMPLE   == err) {
        //_stat.text = @"error: No input sample";
        [self toast:@"没有输入的数据，无法开始直播"];
    }
    else {
        //_stat.text = [[NSString alloc] initWithFormat:@"error: %lu",  (unsigned long)err];
    }
    NSLog(@"onErr: %lu ", (unsigned long) err);
    // 断网重连
    if ( KSYStreamErrorCode_CONNECT_BREAK == err &&/* DISABLES CODE */ (YES) ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_kit.streamerBase stopStream];
            [_kit.streamerBase startStream:_streamerUrl];
            [self initStatData];
        });
        [self toast:@"重新连接"];
    }
}

//直播的时间的显示
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    
    int minutes = (totalSeconds / 60) % 60;
    //int hours = totalSeconds / 3600;
    //return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    
    if (isPauseStrme)
    {
        return [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%2d分钟%02d秒",minutes,seconds];
    }
    
}
//隔一段时间更新状态
- (void)updateStat:(NSTimer *)theTimer{
    if (_kit.streamerBase.streamState == KSYStreamStateConnected ) {
        int    KB          = _kit.streamerBase.uploadedKByte;
        int    curFrames   = _kit.streamerBase.encodedFrames; //总帧数
        int    droppedF    = _kit.streamerBase.droppedVideoFrames;
        
        int deltaKbyte = KB - _lastByte;
        double curTime = [[NSDate date]timeIntervalSince1970];
        double deltaTime = curTime - _lastSecond;
        double realKbps = deltaKbyte*8 / deltaTime;   // deltaByte / deltaSecond
        
        double deltaFrames =(curFrames - _lastFrames);
        double fps = deltaFrames / deltaTime;
        
        double dropRate = (droppedF - _lastDroppedF ) / deltaTime;
        _lastByte     = KB;
        _lastSecond   = curTime;
        _lastFrames   = curFrames;
        _lastDroppedF = droppedF;
        NSString *uploadDateSize = [ self sizeFormatted:KB ];
        NSString* stateurl  = [NSString stringWithFormat:@"%@\n", [_streamerUrl absoluteString]] ;
        NSString* statekbps = [NSString stringWithFormat:@"realtime:%4.1fkbps %.2f%@\n", realKbps, 0.5, _netEventRaiseDrop];
        NSString* statefps  = [NSString stringWithFormat:@"%2.1f fps | %@  | %@ \n", fps, uploadDateSize, [self timeFormatted: (int)(curTime-_startTime)]];
        
        //设置直播的时间
        _label.text=[self timeFormatted:(int)(curTime-_startTime)];
        _label.font=[UIFont systemFontOfSize:12];
        _label.textColor=[UIColor redColor];
        
        NSString* statedrop = [NSString stringWithFormat:@"dropFrame %4d | %3.1f | %2.1f%% \n", droppedF, dropRate, droppedF * 100.0 / curFrames ];
        NSString* netEvent = [NSString stringWithFormat:@"netEvent %d notGood | %d raise | %d drop", _netEventCnt, _raiseCnt, _dropCnt];
        
        NSLog(@"stateurl:%@ statekbps:%@ stateFps:%@ statedrop:%@ netEvent:%@",stateurl,statekbps,statefps,statedrop,netEvent);
        
        
        if (_netTimeOut == 0) {
            _netEventRaiseDrop = @" ";
        }
        else {
            _netTimeOut--;
        }
    }
}

- (NSString*) sizeFormatted : (int )KB {
    if ( KB > 1000 ) {
        double MB   =  KB / 1000.0;
        return [NSString stringWithFormat:@" %4.2f MB", MB];
    }
    else {
        return [NSString stringWithFormat:@" %d KB", KB];
    }
}
//弹出的提示框
- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    //提示框显示的时间长
    double duration = 1; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}
//添加label
- (UILabel *)addLable:(NSString*)title{
    UILabel *  lbl = [[UILabel alloc] init];
    lbl.text = title;
    [_controlView addSubview:lbl];
    return lbl;
}
//添加选择器
- (UISwitch *)addSwitch:(BOOL) on{
    UISwitch *sw = [[UISwitch alloc] init];
    [_controlView addSubview:sw];
    sw.on = on;
    return sw;
}









@end
