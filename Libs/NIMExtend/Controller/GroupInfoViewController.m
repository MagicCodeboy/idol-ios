//
//  GroupInfoViewController.m
//  jinshanStrmear
//
//  Created by wsmbp on 2018/4/20.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "NIMKit.h"
#import "UIView+Toast.h"
#import "UIViewController+JZExtension.h"

#import "NIMTeamCardHeaderCell.h"
#import "NIMCardMemberItem.h"
#import "GroupCollectionViewCell.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "MJRefresh.h"
#import "AccountModel.h"

#define CollectionCellReuseId @"cell"
#define CollectionItemWidth  55
#define CollectionItemHeight 80
#define CollectionEdgeInsetLeftRight 20

#define CollectionEdgeInsetTopFirstLine 25
#define CollectionEdgeInsetTop 15
@interface GroupInfoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,copy)   NSMutableArray *data;
@property (nonatomic,copy)   NSArray *infoArray;
@property (nonatomic, strong) NIMChatroom *chatroom;

@property (nonatomic, assign) NSInteger limit; //分页条数
@property (nonatomic, assign) BOOL isManager; //是否是管理员

@property (nonatomic, strong) NSMutableArray<NIMChatroomMember *> *members;

@end

@implementation GroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self showBackLayer];
    [self addBackBtn];
    self.fd_interactivePopDisabled = YES;

    self.jz_navigationBarTintColor=UIColorFromRGB(0x3E206A);
    self.navigationController.navigationBar.translucent=NO;
    self.infoArray=@[LocalizedStr(@"ChatName"),LocalizedStr(@"ChatAnnouncement")];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    flowLayout.minimumInteritemSpacing = CollectionEdgeInsetLeftRight;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:241.0/255.0 blue:245.0/255.0 alpha:1];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.backgroundColor=[UIColor clearColor];
    
    [self.collectionView registerClass:[NIMTeamCardHeaderCell class] forCellWithReuseIdentifier:CollectionCellReuseId];
    [self.view addSubview:self.collectionView];
//    self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top, CollectionEdgeInsetLeftRight, self.collectionView.contentInset.bottom, CollectionEdgeInsetLeftRight);
    [self.collectionView registerClass:[UICollectionReusableView class ]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerViewIdentifier"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupCollectionViewCell"];
    
//    __weak typeof(self) wself = self;
    
    NIMChatroomMembersByIdsRequest *reuqest=[[NIMChatroomMembersByIdsRequest alloc]init];
    reuqest.roomId=_chatroom.roomId;
    reuqest.userIds=@[[AccountModel read].userId];
    
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:reuqest completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        
        NIMChatroomMember *member=members.firstObject;
        if (member.type==NIMChatroomMemberTypeManager||member.type==NIMChatroomMemberTypeCreator) {
            self.isManager=YES;
        }
        
    }];
    
    [self prepareData];
    [self refresh];
    


    
}
-(void)refresh
{
    __weak typeof(self)weakSelf=self;
    self.collectionView.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}
- (instancetype)initWithChatroom:(NIMChatroom *)chatroom{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _limit     = 100;
        _chatroom = chatroom;
        _members   = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)updateInfo:(NSString *)content{
    NIMChatroomUpdateRequest *request=[[NIMChatroomUpdateRequest alloc]init];
    request.updateInfo= @{@(NIMChatroomUpdateTagAnnouncement) :content};
    request.roomId=_chatroom.roomId;
    
   
    [[NIMSDK sharedSDK].chatroomManager updateChatroomInfo:request completion:^(NSError * _Nullable error) {
        if (error==nil) {
            NSLog(@"修改成功");
            self.chatroom.announcement=content;
            [self reloadData];

        }
    }];
}
- (void)prepareData{
    __weak typeof(self) wself = self;
    [self requestTeamMembers:nil handler:^(NSError *error, NSArray *members) {
        if (!error)
        {
            [wself.members removeAllObjects];
            if (members.count == wself.limit)
            {
                [wself loadMoreData];

            }
            else
            {
            }
            wself.members = [NSMutableArray arrayWithArray:members];
            [wself sortMember];
            [wself.collectionView reloadData];
        }
        else
        {
            [wself.view makeToast:@"直播间成员获取失败"];
        }
    }];
}
- (void)loadMoreData{
    __weak typeof(self) wself = self;
    [self requestTeamMembers:self.members.lastObject handler:^(NSError *error, NSArray *members){
        [wself.collectionView.mj_footer endRefreshing];
        
        [wself.members addObjectsFromArray:members];
        [wself sortMember];
        [wself reloadData];
    }];
}

- (void)sortMember
{
    NSDictionary<NSNumber *,NSNumber *> *values =
    @{
      @(NIMChatroomMemberTypeCreator) : @(1),
      @(NIMChatroomMemberTypeManager) : @(2),
      @(NIMChatroomMemberTypeNormal ) : @(3),
      @(NIMChatroomMemberTypeLimit  ) : @(4),
      @(NIMChatroomMemberTypeGuest  ) : @(5),
      @(NIMChatroomMemberTypeAnonymousGuest  ) : @(6),
      };
    [self.members sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NIMChatroomMember *member1  = obj1;
        NIMChatroomMember *member2  = obj2;
        NIMChatroomMemberType type1 = member1.type;
        NIMChatroomMemberType type2 = member2.type;
        return values[@(type1)].integerValue > values[@(type2)].integerValue;
    }];
}

#pragma mark - Private
- (void)requestTeamMembers:(NIMChatroomMember *)lastMember handler:(NIMChatroomMembersHandler)handler{
    NIMChatroomMemberRequest *request = [[NIMChatroomMemberRequest alloc] init];
    request.roomId = self.chatroom.roomId;
    request.lastMember = lastMember;
    request.type   = (lastMember.type == NIMChatroomMemberTypeGuest || lastMember.type == NIMChatroomMemberTypeAnonymousGuest)? NIMChatroomFetchMemberTypeTemp : NIMChatroomFetchMemberTypeRegularOnline;
    request.limit  = self.limit;
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:request completion:^(NSError *error, NSArray *members) {
        if (!error)
        {
            if (members.count < wself.limit && request.type == NIMChatroomFetchMemberTypeRegularOnline) {
                //固定的没抓够，再抓点临时的充数
                NIMChatroomMemberRequest *req = [[NIMChatroomMemberRequest alloc] init];
                req.roomId = wself.chatroom.roomId;
                req.lastMember = nil;
                req.type   = NIMChatroomFetchMemberTypeTemp;
                req.limit  = wself.limit;
                [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:req completion:^(NSError *error, NSArray *tempMembers) {
                    NSArray *result;
                    if (!error) {
                        result = [members arrayByAddingObjectsFromArray:tempMembers];
                        if (result.count > wself.limit) {
                            result = [result subarrayWithRange:NSMakeRange(0, wself.limit)];
                        }
                    }
                    handler(error,result);
                }];
            }
            else
            {
                handler(error,members);
            }
        }
        else
        {
            handler(error,members);
        }
    }];
}

-(void)reloadData{
    [self.collectionView reloadData];

}




#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
 
    
    if (section==1) {
        return self.members.count;
//        NSInteger lastTotal = self.collectionItemNumber * section;
//        NSInteger remain    = self.data.count - lastTotal;
//
//        return remain < self.collectionItemNumber ? remain:self.collectionItemNumber;
    }else{
        return self.infoArray.count;
        
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    NSInteger sections = self.data.count / self.collectionItemNumber;
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        NIMTeamCardHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellReuseId forIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        cell.roleImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.roleImageView.layer.masksToBounds = YES;
        NIMChatroomMember *member = self.members[indexPath.row];

        [cell refreshData:member];
        return cell;
    }else{
        GroupCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCollectionViewCell" forIndexPath:indexPath];
        cell.titleLabel.text=self.infoArray[indexPath.row];
        if (self.chatroom) {
            cell.desLabel.text=@[self.chatroom.name,self.chatroom.announcement?self.chatroom.announcement:@""][indexPath.row];

        }
        
        return cell;
        
    }
 
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            if (self.isManager!=YES) {
                return;
            }
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedStr(@"AnnouncementContent")
                                                                                     message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            // 2.1 添加文本框
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"username";
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalizedStr(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"Cancel Action");
            }];
            UIAlertAction *loginAction = [UIAlertAction actionWithTitle:LocalizedStr(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               
                UITextField *userName = alertController.textFields.firstObject;
                if (userName==nil||[userName.text isEqualToString:@""]) {
                    [self.view makeToast:LocalizedStr(@"AnnouncementContent")];
                    return ;
                }
                [self updateInfo:userName.text];
                
                
            }];
            UITextField *userName = alertController.textFields.firstObject;
            userName.text=_chatroom.announcement;
            
            [alertController addAction:cancelAction];
            [alertController addAction:loginAction];
            
            // 3.显示警报控制器
            [self presentViewController:alertController animated:YES completion:nil];
         
          
            }

            
        
    }
    
}

//定义并返回每个headerView或footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==1) {
        
        UICollectionReusableView *header = [collectionView  dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerViewIdentifier"  forIndexPath:indexPath];
        header.backgroundColor=[UIColor clearColor];
        
        return header;
    }
    return nil;
    
    
    
}
// 设置视图内边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section==1) {
        return UIEdgeInsetsMake(18, CollectionEdgeInsetLeftRight, 0, CollectionEdgeInsetLeftRight);

    }else{
        return UIEdgeInsetsMake(15, 0, 0, 0);

    }
}




#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section==1) {
        return CGSizeMake(CollectionItemWidth, CollectionItemHeight);

    }else{
        return CGSizeMake(SCREEN_WIDTH  , 36);

    }
    
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    
    if (section==0) {
        
        return CGSizeMake(0, 0);
        
    }
    else{
        return CGSizeMake(SCREEN_WIDTH, 15);

    }
    
    
}

#pragma mark - Private

- (NSInteger)collectionItemNumber{
    CGFloat minSpace = 20.f; //防止计算到最后出现左右贴边的情况
    return (int)((self.collectionView.frame.size.width - minSpace)/ (CollectionItemWidth + CollectionEdgeInsetLeftRight));
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent=NO;

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent=YES;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
