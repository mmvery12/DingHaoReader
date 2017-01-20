//
//  TrackerInfo.h
//  DingHaoReader
//
//  Created by JD on 17/1/19.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrackerFilesInfo;
@interface TrackerInfo : NSObject
@property (nonatomic,copy) NSString *length;
@property (nonatomic,copy) NSString *md5sum;//（可选)
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *piecelength;
@property (nonatomic,copy) NSString *pieces;

@property (nonatomic,strong) NSArray<TrackerFilesInfo *> *files;

@end

@interface TrackerFilesInfo : NSObject
@property (nonatomic,copy) NSString *length;
@property (nonatomic,copy) NSArray *path;
@end
