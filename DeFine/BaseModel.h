//
//  BaseModel.h
//  Doctors
//
//  Created by 王森 on 16/4/11.
//  Copyright © 2016年 王森. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromPropertyName;
-(id)initWithDic:(NSDictionary*)dic;

-(void)setValue:(id)value forUndefinedKey:(NSString *)key;


@end
