//
//  NSTimer+WeakTimer.m
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/29.
//  Copyright © 2018年 王森. All rights reserved.
//

#import "NSTimer+WeakTimer.h"

@implementation NSTimer (WeakTimer)
+ (NSTimer *)zx_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                       repeats:(BOOL)repeats
                                  handlerBlock:(void(^)())handler
{
    return [self scheduledTimerWithTimeInterval:timeInterval
                                         target:self
                                       selector:@selector(handlerBlockInvoke:)
                                       userInfo:[handler copy]
                                        repeats:repeats];
}
+ (void)handlerBlockInvoke:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}
@end
