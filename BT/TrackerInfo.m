//
//  TrackerInfo.m
//  DingHaoReader
//
//  Created by JD on 17/1/19.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import "TrackerInfo.h"

@implementation TrackerInfo
-(NSDictionary  *)containerArrayConvertToEntityPropertyArray;
{
    return @{@"files":[TrackerFilesInfo class]};
}

-(NSDictionary<NSString_EntityPropertyString *,NSString_ContainerKeyString *> *)containerKeyNameConvertToEntityPropertyName
{
    return @{@"piecelength":@"piece length"};
}

@end
@implementation TrackerFilesInfo

@end
