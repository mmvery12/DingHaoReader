//
//  NSObject+Entity.m
//  Model
//
//  Created by JD on 17/1/19.
//  Copyright © 2017年 liyuchang. All rights reserved.
//

#import "NSObject+Entity.h"
#import <objc/runtime.h>


typedef NS_ENUM(NSInteger) {
    NSEntityType,
    NSStringType,
    NSMutableStringType,
    NSArrayType,
    NSMutableArrayType,
    NSDictionaryType,
    NSMutableDictionaryType,
    NSDecimalNumberType,
    NSNumberType,
    NSDataType,
    NSMutableDataType
}PropertyType;

@implementation NSObject (Entity)


+(id)EntityFromContainer:(id)container;
{
    if (container==nil||[container isKindOfClass:[NSNull class]]) {
        return nil;
    }
    id obj =  (id)[[self alloc] init];
    [obj autoPaddingParamsValues:container];
    return obj;
}

-(id)getContainer;
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in [self getAllProperties]) {
        NSString *key = [dict objectForKey:@"name"];
        NSString *attribute = [dict objectForKey:@"attribute"];
        PropertyType type = [self propertyType:attribute];
        Class cls = [self propertyClass:attribute];
        
        SEL getParamSel = NSSelectorFromString(key);
        id obj = [self performSelector:getParamSel];
        
        NSDictionary *ArrayPropertyArrayDict = [self containerArrayConvertToEntityPropertyArray];
        
        id containerValue = obj;
        if (valied(containerValue)) {
            if (type==NSEntityType)//非基本nsobject类,且是entity子类，数据类型不是array,dict
            {
                NSObject *base = (id)[obj getContainer];
                [temp setValue:base forKey:key];
            }
            else if ((type==NSArrayType|| type==NSMutableArrayType) &&
                     ArrayPropertyArrayDict[key])
            {//entitybase类集合
                NSMutableArray *arr = [NSMutableArray array];
                for (id data in containerValue) {
                    [arr addObject:(id)[data getContainer]];
                }
                [temp setValue:arr forKey:key];
            }
            else    //正常nsobject类
            {
                [temp setValue:containerValue forKey:key];
            }
        }else if (!valied(containerValue))
        {
            NSObject *obj = nil;
            if (type == NSEntityType)
            {
                obj = [[cls alloc] init];
            }
            else if (type == NSStringType) {
                obj = [[NSString  alloc] init];
            }
            else if (type == NSMutableStringType)
            {
                obj = [NSMutableString new];
            }
            else if (type == NSArrayType)
            {
                obj = [NSArray new];
            }
            else if (type == NSMutableArrayType)
            {
                obj = [NSMutableArray new];
            }
            else if (type == NSDictionaryType)
            {
                obj = [NSDictionary new];
            }
            else if (type == NSMutableDictionaryType)
            {
                obj = [NSMutableDictionary new];
            }
            else if (type == NSDecimalNumberType)
            {
                obj = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            else if (type == NSNumberType)
            {
                obj = [NSNumber new];
            }
            else if (type == NSDataType)
            {
                obj = [NSData data];
            }
            else if (type == NSMutableDataType)
            {
                obj = [NSMutableData data];
            }
            
            [temp setValue:obj forKey:key];
        }
    }
    return temp;
}

-(id)isVaildRequestObject:(NSObject *)object
{
    if ([object isKindOfClass:[NSNull class]]||object==nil) {
        return [NSNull null];
    }
    if ([object isKindOfClass:[NSObject class]]) {
        return [object getContainer];
    }
    return object;
}

// subclass overwrite
-(NSDictionary *)containerKeyNameConvertToEntityPropertyName;
{
    return @{};
}

// subclass overwrite
-(NSDictionary *)containerArrayConvertToEntityPropertyArray;
{
    return @{};
}

-(NSArray *)containerKeyValueNullNotConvertToEntityPropertyInit;
{
    return @[];
}

- (BOOL)autoPaddingParamsValues:(NSObject*)dataSource
{
    BOOL ret = NO;
    for (NSDictionary *dict in [self getAllProperties]) {
        NSString *key = [dict objectForKey:@"name"];
        NSString *attribute = [dict objectForKey:@"attribute"];
        PropertyType type = [self propertyType:attribute];
        Class cls = [self propertyClass:attribute];
        
        NSDictionary *KeyNamePropertyNameDict = [self containerKeyNameConvertToEntityPropertyName];
        NSDictionary *ArrayPropertyArrayDict = [self containerArrayConvertToEntityPropertyArray];
        NSArray *KeyValueNullNotPropertyInitArray = [self containerKeyValueNullNotConvertToEntityPropertyInit];
        
        id containerValue = [dataSource valueForKey:KeyNamePropertyNameDict[key]?:key];
        if (valied(containerValue)) {
            if (type==NSEntityType)//非基本nsobject类,且是entity子类，数据类型不是array,dict
            {
                NSObject *base = (id)[cls EntityFromContainer:containerValue];
                [self setValue:base forKey:key];
            }
            else if ((type==NSArrayType|| type==NSMutableArrayType) &&
                     ArrayPropertyArrayDict[key])
            {//entitybase类集合
                NSMutableArray *arr = [NSMutableArray array];
                for (id data in containerValue) {
                    [arr addObject:(id)[ArrayPropertyArrayDict[key] EntityFromContainer:data]];
                }
                [self setValue:arr forKey:key];
            }
            else if (type==NSDecimalNumberType)
            {
                NSDecimalNumber * obj = [NSDecimalNumber decimalNumberWithString:[containerValue stringValue]];
                [self setValue:obj forKey:key];
            }
            else    //正常nsobject类
            {
                [self setValue:containerValue forKey:key];
            }
        }else if (!valied(containerValue) && ![KeyValueNullNotPropertyInitArray containsObject:key])
        {
            NSObject *obj = nil;
            if (type == NSEntityType)
            {
                obj = [[cls alloc] init];
            }
            else if (type == NSStringType) {
                obj = [[NSString  alloc] init];
            }
            else if (type == NSMutableStringType)
            {
                obj = [NSMutableString new];
            }
            else if (type == NSArrayType)
            {
                obj = [NSArray new];
            }
            else if (type == NSMutableArrayType)
            {
                obj = [NSMutableArray new];
            }
            else if (type == NSDictionaryType)
            {
                obj = [NSDictionary new];
            }
            else if (type == NSMutableDictionaryType)
            {
                obj = [NSMutableDictionary new];
            }
            else if (type == NSDecimalNumberType)
            {
                obj = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            else if (type == NSNumberType)
            {
                obj = [NSNumber new];
            }
            else if (type == NSDataType)
            {
                obj = [NSData data];
            }
            else if (type == NSMutableDataType)
            {
                obj = [NSMutableData data];
            }
            
            [self setValue:obj forKey:key];
        }
    }
    return ret;
}

-(PropertyType)propertyType:(NSString *)attribute
{
    NSRange range1 = [attribute rangeOfString:@"NSString"];
    NSRange range2 = [attribute rangeOfString:@"NSMutableString"];
    NSRange range3 = [attribute rangeOfString:@"NSArray"];
    NSRange range4 = [attribute rangeOfString:@"NSMutableArray"];
    NSRange range5 = [attribute rangeOfString:@"NSDictionary"];
    NSRange range6 = [attribute rangeOfString:@"NSMutableDictionary"];
    NSRange range7 = [attribute rangeOfString:@"NSDecimalNumber"];
    NSRange range8  =[attribute rangeOfString:@"NSNumber"];
    NSRange range9  =[attribute rangeOfString:@"NSData"];
    NSRange range10  =[attribute rangeOfString:@"NSMutableData"];
    return (range10.length?10:0) | (range9.length?9:0) | (range8.length?8:0) | (range7.length?7:0) | (range6.length?6:0) | (range5.length?5:0) | (range4.length?4:0) | (range3.length?3:0) | (range2.length?2:0) | (range1.length?1:0);
}

-(Class)propertyClass:(NSString *)attribute
{
    NSString *className = [[[[attribute componentsSeparatedByString:@"T@\""] lastObject] componentsSeparatedByString:@"\""] firstObject];
    return NSClassFromString(className);
}

- (NSArray *)getAllProperties
{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        const char * attributes = property_getAttributes(properties[i]);//获取属性类型
        NSDictionary *dict = @{@"name":[NSString stringWithUTF8String:propertyName],@"attribute":[NSString stringWithUTF8String:attributes]};
        [propertiesArray addObject:dict];
    }
    free(properties);
    return propertiesArray;
}





#pragma mark -- coding
- (void)encodeWithCoder:(NSCoder*)coder
{
    for (NSDictionary *dict in [self getAllProperties]) {
        NSString *key = [dict objectForKey:@"name"];
        SEL getParamSel = NSSelectorFromString(key);
        id obj = [self performSelector:getParamSel];
        [coder encodeObject:obj forKey:key];
    }
}

- (id)initWithCoder:(NSCoder*)decoder
{
    if (self = [self init])
    {
        for (NSDictionary *dict in [self getAllProperties]) {
            NSString *key = [dict objectForKey:@"name"];
            [self setValue:[decoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

static BOOL valied(id obj){
    if (obj==nil) {
        return NO;
    }
    if ([obj isKindOfClass:[NSObject class]])
    {
        if (![obj isKindOfClass:[NSNull class]])
            if (obj!=nil) {
                return YES;
            }else
                return NO;
        else
            return YES;
    }
    return YES;
}

@end
