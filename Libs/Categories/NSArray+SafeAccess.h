//
//  NSArray+SafeAccess.h
//  jinshanStrmear
//
//  Created by panhongliu on 16/9/26.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SafeAccess)
/*!
 @method objectAtIndexCheck:
 @abstract 检查是否越界和NSNull如果是返回nil
 @result 返回对象
 */
- (id)objectAtIndexCheck:(NSUInteger)index;

@end
