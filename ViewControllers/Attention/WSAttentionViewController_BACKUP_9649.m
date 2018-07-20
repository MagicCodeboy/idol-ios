//
//  WSAttentionViewController.m
//  jinshanStrmear
//
//  Created by 123 on 16/6/4.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "WSAttentionViewController.h"
#import "PersonFansCell.h"
#import "ViewModel.h"
#import "MajorModel.h"
#import "MJExtension.h"
#import "UIView+Toast.h"

@interface WSAttentionViewController ()



@property(nonatomic,assign)BOOL isHaveStar;
//标记第一个是不是VIp
@property(nonatomic,assign)BOOL firstIsVip;
//标记普通用户出现的位置
@property(nonatomic,assign)NSInteger fansIndex;

//标记普通用户出现时候设置标记跳出循环
@property(nonatomic,assign)BOOL fansIndexbool;
@property(nonatomic,strong)ViewModel * viewMdoelTool;


@end

@implementation WSAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=UIColorFromRGB(0xf5f5f5);

    self.title=@"我的关注";
    [self addBackBtn];
    
    self.viewMdoelTool=[[ViewModel alloc]init];
    
    
    
    [self initWithTableViewNib:@"PersonFansCell" didSelectCellBlock:^(NSIndexPath *indexPath) {
        
    }];
    
    
    [self registerNib:@"PersonFansCell"];
    FRAME(self.tableview, 0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);

    _isHaveStar=NO;
    _firstIsVip=YES;
    _fansIndexbool=NO;

    
    [self loadDataAtten];
    
    __weak typeof(self)waekSelf=self;
    
[waekSelf setTableHeaderRefresh:^{
    self.currentIndex=1;
    
    
    [waekSelf.dataArray removeAllObjects];
    [self loadDataAtten];

}];
    
    [waekSelf setFooterfresh:^{
        waekSelf.currentIndex++;
        [self loadDataAtten];

    }];
    
    
    
    
    
    // Do any additional setup after loading the view.
}

-(void)loadDataAtten
{
    
    [self showWithStatus:nil];
    
    [self.viewMdoelTool requestAttentionViewControllerApiurl:@"/rest/follow/list" parmters:@{@"pageIndex":cunrrenIndex} succees:^(id responseProject) {
        
        NSLog(@"%@",responseProject);
        
         
//        [self removeStatuslable];
        [self endReFresh];
        
        NSArray *array=responseProject[@"ufList"];
        
        if (array.count<=0) {
            self.currentIndex--;
            
<<<<<<< HEAD
                [self addPromptViewWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) ImageName:@"meiyouuguanzhu" andLabel:@"您还没关注任何人"];

=======
            
>>>>>>> de19189ecd2ce70dc504500868069c6e0246be28
        }
        else{
        for (int i=0; i<array.count; i++) {
            UserFollow *model=[UserFollow mj_objectWithKeyValues:array[i]];
            
            if (_isHaveStar==NO) {
                if ([StringWithFormat(model.user.vip) isEqualToString:@"1"]) {
                    
                    _firstIsVip=YES;
                    
                }
                else{
                    _firstIsVip=NO;
                    
                }
                _isHaveStar=YES;
            }
            
            if (_fansIndexbool==NO) {
                if ([StringWithFormat(model.user.vip) isEqualToString:@"0"]) {
                    self.fansIndex=i;
                    _fansIndexbool=YES;
                    
                }
                
            }
         
            
            [self.dataArray addObject:model];
        }
            
            if (self.dataArray.count<=0) {
                
                
                [self addPromptViewWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) ImageName:@"meiyouuguanzhu" andLabel:@"您还没关注任何人"];
                
                
                
            }

            
        }
        
        NSLog(@"我记录的位置%ld",(long)self.fansIndex);
        
        [self.tableview reloadData];

        
        
        NSLog(@"关注列表%@",responseProject);
        
    } fail:^(NSString *error) {
      
        
           }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hiddenTabBar];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}




-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section==0) {
        
        if ( _firstIsVip==YES ) {
            return 10;
            
        }
        else
            return 0;
        
    }
    else
    {
        if (section==self.fansIndex) {
            return 10;
        }
        else
            return 0;
    }

    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count>0) {
        return 1;
    }
    else
        return 0;}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
        
    PersonFansCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonFansCell"];
    
    if (self.dataArray.count>0) {
        UserFollow *model=self.dataArray[indexPath.section];
        

    [cell cellFuzhi:model reload:^(NSString *tipLabel) {
        
        [self.view makeToast:tipLabel];
        
        if ([tipLabel isEqualToString:@"已取消关注"]) {
            model.mutual=@"0";
            
        }
        else
        {               model.mutual=@"1";
            
            
        }
        //改变被监控的关注数量刷新个人页面
        [UserModel shareUserInfo].followCount=[NSString stringWithFormat:@"%lu",(unsigned long)self.dataArray.count];
        

        [self.tableview reloadData];
        
        
    }type:10 ];
    }
    
    return cell;
    
    
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
