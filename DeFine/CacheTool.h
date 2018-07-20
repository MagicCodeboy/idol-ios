//
//  CacheTool.h
//  jinshanStrmear
//
//  Created by panhongliu on 2016/10/10.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheTool : NSObject
#pragma mark - 清除path文件夹下缓存大小

+(void)clearCacheWithFilePath:(NSString *)path withSuccessBlock:(void(^)(void))block;
#pragma mark - 清除所有缓存

+(void)clearAllCachewithSuccessBlock:(void(^)(void))block;
+(void)getCache:(void(^)(NSString *total))block;

@end
