//
//  NSArray+SafeAccess.m
//  jinshanStrmear
//
//  Created by panhongliu on 16/9/26.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "NSArray+SafeAccess.h"

@implementation NSArray (SafeAccess)
- (id)objectAtIndexCheck:(NSUInteger)index
{
    if (index >= [self count]) {
        return nil;
    }
    id value;
    if ([self objectAtIndex:index]) {
       value = [self objectAtIndex:index];
      
    }
    
    if (value == [NSNull null] ) {
        return nil;
    }

       return value;
}
@end
