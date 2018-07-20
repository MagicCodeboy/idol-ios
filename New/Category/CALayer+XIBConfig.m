//
//  CALayer+XIBConfig.m
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/24.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "CALayer+XIBConfig.h"

@implementation CALayer (XIBConfig)
- (void)setBorderColorWithUIColor:(UIColor *)color

{
    
    self.borderColor = color.CGColor;
    
}

@end
