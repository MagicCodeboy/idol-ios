//
//  UITextField+PlaceHolder.h
//  jinshanStrmear
//
//  Created by lalala on 2017/6/14.
//  Copyright © 2017年 王森. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@interface UITextField (PlaceHolder)<UITextFieldDelegate>
@property (nonatomic, strong) UILabel *placeHolderTextView;
- (void)addPlaceHolder:(NSString *)placeHolder;
@end
