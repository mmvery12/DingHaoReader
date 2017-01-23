//
//  TrackerModel.m
//  DingHaoReader
//
//  Created by JD on 17/1/19.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import "Tracker.h"

@implementation Tracker
-(NSDictionary <NSString_EntityPropertyString * ,NSString_ContainerKeyString *>*)containerKeyNameConvertToEntityPropertyName;
{
    return @{@"announcelist":@"announce-list",
             @"createdby":@"created by",
             @"creationdate":@"creation date"};
}
@end


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
