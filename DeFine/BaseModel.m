//
//  BaseModel.m
//  Doctors
//
//  Created by 王森 on 16/4/11.
//  Copyright © 2016年 王森. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"ID":@"id",@"descriptions":@"description"};}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
      NSLog(@"key %@ 没找到",key);
    
}

-(id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

@end
