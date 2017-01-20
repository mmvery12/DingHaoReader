//
//  NSObject+Entity.h
//  Model
//
//  Created by JD on 17/1/19.
//  Copyright © 2017年 liyuchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/Objc.h>
typedef NSString NSString_ContainerKeyString;
typedef NSString NSString_EntityPropertyString;
/**************************************
 entity : 针对ns数据结构转化为model实体，
 使用须知：实体中的property需为nsobject类别，无法转化基本数据类型
         使用时时，只针对当前class中包涵的property，对super class未做解析与转化
**************************************/
@interface NSObject (Entity)<NSCoding>

//初始化方法 container 转entity
+(id)EntityFromContainer:(id)container;
//entity转container方法
-(id)getContainer;

/***
 数据源中的key与entity的property名字不对应是，在这里做映射关系
 @{protertyname:containerkey}
 ***/
// subclass overwrite
-(NSDictionary <NSString_EntityPropertyString * ,NSString_ContainerKeyString *>*)containerKeyNameConvertToEntityPropertyName;
/***
 数据源中的array与entity的property是array是，在这里做array中entity的映射关系
 @{protertyname:arrayclass}
 ***/
// subclass overwrite
-(NSDictionary <NSString_EntityPropertyString *,Class> *)containerArrayConvertToEntityPropertyArray;

/***
 数据源中的keyvalue没与entity的property对应，或是keyvalue为null时，在这里做entity中不需要初始化的property
 @{protertyname:arrayclass}
 ***/
-(NSArray <NSString_EntityPropertyString *> *)containerKeyValueNullNotConvertToEntityPropertyInit;

@end
