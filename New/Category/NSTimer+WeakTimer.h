//
//  NSTimer+WeakTimer.h
//  jinshanStrmear
//
//  Created by wsmbp on 2018/3/29.
//  Copyright © 2018年 王森. All rights reserved.
//



@interface NSTimer (WeakTimer)

+ (NSTimer *)zx_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                       repeats:(BOOL)repeats
                                  handlerBlock:(void(^)())handler;
@end
