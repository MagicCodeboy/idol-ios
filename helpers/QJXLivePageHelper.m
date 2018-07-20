//
//  QJXLivePageManager.m
//  jinshanStrmear
//
//  Created by 曹志宇 on 16/9/14.
//  Copyright © 2016年 曹志宇. All rights reserved.
//

#import "QJXLivePageHelper.h"

@implementation QJXLivePageHelper
+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _livePageArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

@end
