//
//  NetManager.h
//  DingHaoReader
//
//  Created by JD on 17/1/23.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tracker.h"
@class TrackerSerialization;
typedef void (^TrackerAnnounceBlock) (NSData *data,NSError *error);
@interface NetManager : NSObject
+(void)Tracker:(TrackerSerialization *)trackserialization success:(TrackerAnnounceBlock)block;
@end


typedef NS_ENUM(NSUInteger){
    HttpTracker,
    UdpTracker
} TrackerType;

@interface TrackerSerialization : NSObject
@property (nonatomic,assign)TrackerType type;

//http tracker info
@property (nonatomic,copy)NSString *url;
//udp tracker info
@property (nonatomic,copy)NSString *ip;
@property (nonatomic,copy)NSString *port;

@property (nonatomic,strong)Tracker *tracker;
@end
