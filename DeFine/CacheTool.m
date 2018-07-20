//
//  CacheTool.m
//  jinshanStrmear
//
//  Created by panhongliu on 2016/10/10.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "CacheTool.h"
#import "AccountModel.h"
#import "YYCache+Cache.h"

@implementation CacheTool
+ (void)clearCacheWithFilePath:(NSString *)path withSuccessBlock:(void(^)(void))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        
        NSString *cachPath = path;
        if (cachPath==nil) {
            cachPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)objectAtIndex:0];

        }
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
        
        NSLog(@"files :%lu",(unsigned long)[files count]);
        
        for (NSString *p in files) {
            //如有需要，加入条件，过滤掉不想删除的文件
            
            NSError *error;
            
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                
            }
            
        }
        
        block();
        
        
    });
    
    
}

+ (void)clearAllCachewithSuccessBlock:(void(^)(void))block{
    [AccountModel deleteAccount];
   
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"signDate"];
//    签到逻辑去掉
//    [[YYCache shareCache]removeObjectForKey:@"signCache"];

    
    [[YYCache shareCache]removeAllObjects];
    
    [self clearCacheWithFilePath:nil withSuccessBlock:^{
    
        block();
        
    }];
    
    
}

+(void)getCache:(void(^)(NSString *total))block{
    
    //获取缓存
    
    GlobalGCD(^{
        NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)objectAtIndex:0];
        
    
        block([self getCacheSizeWithFilePath:cachPath]);
        
    } );
    
    
}
#pragma mark - 获取path路径下文件夹大小
+(NSString *)getCacheSizeWithFilePath:(NSString *)path{
    
    // 获取“path”文件夹下的所有文件
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    NSString *filePath  = nil;
    NSInteger totleSize = 0;
    
    for (NSString *subPath in subPathArr){
        
        // 1. 拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subPath];
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = NO;
        // 3. 判断文件是否存在
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // 4. 以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]){
            // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
            continue;
        }
        
        // 5. 指定路径，获取这个路径的属性
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */
        
        // 6. 获取每一个文件的大小
        NSInteger size = [dict[@"NSFileSize"] integerValue];
        
        // 7. 计算总大小
        totleSize += size;
    }
    
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    
    if (totleSize > 1000 * 1000){
        totleStr = [NSString stringWithFormat:@"%.2fM",totleSize / 1000.00f /1000.00f];
        
    }else if (totleSize > 1000){
        totleStr = [NSString stringWithFormat:@"%.2fKB",totleSize / 1000.00f ];
        
    }else{
        totleStr = [NSString stringWithFormat:@"%.2fB",totleSize / 1.00f];
    }
    
    return totleStr;
}




@end
