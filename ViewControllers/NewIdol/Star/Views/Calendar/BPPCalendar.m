//
//  BPPCalendar.m
//  Animation
//
//  Created by Onway on 2017/4/7.
//  Copyright © 2017年 Onway. All rights reserved.
//

#import "BPPCalendar.h"
#import "BPPCalendarModel.h"
#import "MyCalendarCell.h"
#import "UILabel+Tool.h"
#import "NSString+Tool.h"
#import "TotalMethodViewModel.h"

@interface BPPCalendar () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, strong)  BPPCalendarModel *calendarModel;
@property (nonatomic, strong) NSArray *weekArray;
@property (nonatomic, strong) NSArray *dayArray;
@property (nonatomic, strong) UICollectionView *calendarCollectView;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) UILabel *titlelabel;
@property (nonatomic, strong) NSMutableDictionary *mutDict;
@property (nonatomic, assign) NSInteger currentMonth;
@property (nonatomic, assign) NSInteger currentPersonId;

@property (nonatomic, strong) NSMutableArray *haveSignArray;

@end

@implementation BPPCalendar
-(NSMutableArray *)haveSignArray{
    if (_haveSignArray == nil) {
        _haveSignArray = [NSMutableArray array];
    }
    return _haveSignArray;
}
- (UILabel *)titlelabel {
    if (!_titlelabel) {
        _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 60, 10, 120, 30)];
        [_titlelabel setLabelWithFontName:@"PingFangSC-Regular" andFontSize:23 andTextColor:UIColorFromRGB(0x000000) andTextAlignment:NSTextAlignmentCenter];
        _titlelabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titlelabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initDataSourse];
        [self stepUI];
    }
    return self;
}

//初始化数据
- (void)initDataSourse {
    __weak typeof(self) weakSelf = self;
    NSString * oneString = LocalizedOtherStr(@"Sunday");
    NSString * twoString = LocalizedOtherStr(@"Monday");
    NSString * threeString = LocalizedOtherStr(@"Tuesday");
    NSString * fourString = LocalizedOtherStr(@"Wednesday");
    NSString * fiveString = LocalizedOtherStr(@"Thursday");
    NSString * sixString = LocalizedOtherStr(@"Friday");
    NSString * sevenString = LocalizedOtherStr(@"Saturday");
    _weekArray = @[oneString,twoString,threeString,fourString,fiveString,sixString,sevenString];
   _calendarModel = [[BPPCalendarModel alloc] init];
    self.calendarModel.block = ^(NSUInteger year, NSUInteger month) {
        weakSelf.currentMonth = month;
        weakSelf.titlelabel.text = [weakSelf setUpMonthStringWith:month];
    };
    _dayArray = [_calendarModel setDayArr];
    self.index = _calendarModel.index;
    _mutDict = [NSMutableDictionary new];
}

-(NSString *)setUpMonthStringWith:(NSUInteger)month{
    NSString *monthString = nil;
    switch (month) {
        case 1:
            monthString = LocalizedOtherStr(@"January");
            break;
        case 2:
            monthString = LocalizedOtherStr(@"February");
            break;
        case 3:
            monthString = LocalizedOtherStr(@"March");
            break;
        case 4:
            monthString = LocalizedOtherStr(@"April");
            break;
        case 5:
            monthString = LocalizedOtherStr(@"May");
            break;
        case 6:
            monthString = LocalizedOtherStr(@"June");
            break;
        case 7:
            monthString = LocalizedOtherStr(@"July");
            break;
        case 8:
            monthString = LocalizedOtherStr(@"August");
            break;
        case 9:
            monthString = LocalizedOtherStr(@"September");
            break;
        case 10:
            monthString = LocalizedOtherStr(@"October");
            break;
        case 11:
            monthString = LocalizedOtherStr(@"November");
            break;
        case 12:
            monthString = LocalizedOtherStr(@"December");
            break;
        default:
            break;
    }
    return monthString;
}

//布局
- (void)stepUI {
    [self addSubview:self.titlelabel];
    [self.titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_offset(17);
        make.height.equalTo(@23);
    }];

    CGFloat width = (self.bounds.size.width - 50)/7.0;
    UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 60, 30)];
    [lastBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    lastBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [lastBtn setTitle:[self setUpMonthStringWith:(self.currentMonth - 1)] forState:UIControlStateNormal];
    [lastBtn addTarget:self action:@selector(lastMonthClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lastBtn];
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titlelabel);
        make.right.mas_equalTo(self.titlelabel.mas_left).offset(-23);
        make.height.equalTo(@15);
    }];
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 80, 20, 60, 30)];
    nextBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [nextBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [nextBtn setTitle:[self setUpMonthStringWith:(self.currentMonth - 1)] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextMonthClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titlelabel);
        make.left.mas_equalTo(self.titlelabel.mas_right).offset(23);
        make.height.equalTo(@15);
    }];
    
    for (int i = 0; i < [_weekArray count]; i ++) {
        UIButton *weekBtn = [[UIButton alloc] initWithFrame:CGRectMake(i * (width + 5) + 10, 60, width, 15)];
        [weekBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        weekBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
        [weekBtn setTitle:_weekArray[i] forState:UIControlStateNormal];
        [self addSubview:weekBtn];
    }
    
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    _calendarCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, width + 50, self.bounds.size.width - 20, self.bounds.size.height - width) collectionViewLayout:flowlayout];
    _calendarCollectView.delegate = self;
    _calendarCollectView.dataSource = self;
    _calendarCollectView.scrollEnabled = NO;
    [_calendarCollectView registerClass:[MyCalendarCell class] forCellWithReuseIdentifier:@"MyCalendarCell"];
    _calendarCollectView.backgroundColor = [UIColor clearColor];
    self.calendarCollectView.alwaysBounceVertical=YES;
    self.calendarCollectView.showsVerticalScrollIndicator = NO;
    [self addSubview:_calendarCollectView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dayArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.bounds.size.width - 50)/7.0, 30);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCalendarCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dayArray[indexPath.row];
    if (self.index == indexPath.row) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.bottomImageView.hidden = NO;
        cell.userInteractionEnabled = YES;
    } else {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.clipsToBounds = NO;
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
   
    if (self.haveSignArray.count > 0) {
        NSString *string = [NSString stringWithFormat:@"00%@",cell.textLabel.text];
        NSLog(@"--------%@",cell.textLabel.text);
        if ([self.haveSignArray containsObject:[string substringWithRange:NSMakeRange(string.length - 2, 2)]]) {
            cell.bottomImageView.hidden = YES;
            cell.haveSignImageView.hidden = NO;
        }
    }
    
    if (indexPath.row <= 6) {
        if ([self.dayArray[indexPath.row] integerValue] > 7) {
            cell.textLabel.textColor = UIColorFromRGB(0x999999);
            cell.haveSignImageView.hidden = YES;
        }
    } else if(indexPath.item > 27) {
        if ([self.dayArray[indexPath.row] integerValue] < 8) {
            cell.textLabel.textColor = UIColorFromRGB(0x999999);
            cell.haveSignImageView.hidden = YES;
        }
    }
    
    
    
    return cell;
}

- (void)lastMonthClick {
//    [self.mutDict removeAllObjects];
//    self.dayArray = [self.calendarModel lastMonthDataArr];
//    [self.calendarCollectView reloadData];
}

- (void)nextMonthClick {
//    [self.mutDict removeAllObjects];
//    self.dayArray = [self.calendarModel nextMonthDataArr];
//    [self.calendarCollectView reloadData];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCalendarCell *cell = (MyCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [[TotalMethodViewModel shareModel] requestPersonSignParmters:@{@"personId":@(self.currentPersonId)} succees:^(id response) {
        cell.bottomImageView.hidden = YES;
        cell.haveSignImageView.hidden = NO;
        cell.textLabel.textColor = [UIColor blackColor];
        if (self.signDoneBlock) {
            self.signDoneBlock(YES);
        }
    } fail:^(id error) {
        
    }];
//
//    [self.mutDict removeAllObjects];
//    [self.mutDict setValue:@"value" forKey:[NSString stringWithFormat:@"%ld",indexPath.row]];
//    [self.calendarCollectView reloadData];
//    
//    我将数据分为三部分处理，第一，获取本月的天数范围，第二，获取上个月与本月第一天遗留的天数，第三，获取到本月最后一天yu
    
    
}
-(void)setPersonModel:(PersonModel *)personModel{
    self.currentPersonId = personModel.personId;
    [self.haveSignArray removeAllObjects];
    WeakSelf(weakSelf, self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *string in personModel.userSignDateList) {
            NSString *dataString = [NSString getDateWithTimeString:string];
            NSArray *array = [dataString componentsSeparatedByString:@"-"];
            [weakSelf.haveSignArray addObject:[array lastObject]];
        }
    });
}


@end
