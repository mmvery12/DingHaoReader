//
//  TrackerModel.h
//  DingHaoReader
//
//  Created by JD on 17/1/19.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TrackerInfo;
@interface Tracker : NSObject
@property (nonatomic,copy)NSString *announce;//：tracker服务器的URL,http：//tracker.cnxp.com:8080/announce。
@property (nonatomic,strong)NSArray *announcelist;//：可选。备用tracker服务器的URL列表
@property (nonatomic,copy)NSString * creationdate;//：可选。.torrent文件的创建日期时间戳
@property (nonatomic,copy)NSString *comment;//：可选。.torrent文件制作者添加的任意格式的说明。
@property (nonatomic,copy)NSString *createdby;//：可选。制作.torrent文件的工具
@property (nonatomic,copy)NSString *encoding;//：可选。发布的资源使用的编码方式
@property (nonatomic,strong)TrackerInfo *info;
@property (nonatomic,strong)NSString *info_hash;
@property (nonatomic,strong)NSString *peer_id;
@property (nonatomic,copy)NSString *HASH;
@end
