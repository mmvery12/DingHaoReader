//
//  Announce.h
//  DingHaoReader
//
//  Created by JD on 17/1/23.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Peer;

@interface Announce : NSObject
@property (nonatomic,strong)NSString *failure_reason;//: 如果有本项,说明发生了一个严重错误,将不会返回其他任何信息. 键值是人类可读的错误信息.
@property (nonatomic,strong)NSString *warning_message;//: (新的) 键值是人类可读的的一般警告信息.
@property (nonatomic,strong)NSString *interval;//: 发送请求之间必须的间隔时间(秒)  (必须执行)
@property (nonatomic,strong)NSString *min_interval;//: 最小的发布间隔时间 (秒). 限制客户端重新发布.
@property (nonatomic,strong)NSString *tracker; //id: 一个必须被回送的字符串,当客户端再次发布.
@property (nonatomic,strong)NSString *complete;//: 整数, 拥有完全文件的伙伴数.
@property (nonatomic,strong)NSString *incomplete;//: 整数, 拥有不完全文件的伙伴数,也就是"水蛭".
@property (nonatomic,strong)NSArray<Peer *> *peers;//: 一个含有字典的列表, 每一个字典含有如下内容:
@end


@interface Peer : NSObject
@property (nonatomic,strong)NSString *peer;// id: 字符串, 伙伴的唯一名称.
@property (nonatomic,strong)NSString *ip;//: 字符串,伙伴的IPv4或IPv6地址,或是DNS名.
@property (nonatomic,strong)NSString *port;//: 整数,伙伴的端口
//有一些Tracker能返回"Compact"模式的伙伴列表,如果是这种 情况,peers列表就会被一个peers字符串所代替,每个伙伴占6个字节.其中前4个字节是主机IP(网络字序) , 后2个字节是端口(网络字序).

@end
