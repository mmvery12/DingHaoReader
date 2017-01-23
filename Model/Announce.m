//
//  Announce.m
//  DingHaoReader
//
//  Created by JD on 17/1/23.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import "Announce.h"

@implementation Announce
-(NSDictionary <NSString_EntityPropertyString * ,NSString_ContainerKeyString *>*)containerKeyNameConvertToEntityPropertyName;
{
    return @{@"failure_reason":@"failure reason",
             @"min_interval":@"min interval",
             @"warning_message":@"warning message"};
}

-(NSDictionary<NSString_EntityPropertyString *,Class> *)containerArrayConvertToEntityPropertyArray
{
    return @{@"peers":[Peer class]};
}
@end


@implementation Peer



@end
