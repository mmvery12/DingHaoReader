//
//  ViewController.m
//  DingHaoReader
//
//  Created by JD on 16/12/28.
//  Copyright © 2016年 LYC. All rights reserved.
//

#import "Tracker.h"
#import "BDecoder.h"
#import "ViewController.h"
#import "ViewController2.h"
#import "CocoaAsyncSocket.h"
#import "AFNetworking.h"
@interface ViewController ()<GCDAsyncUdpSocketDelegate>
{
    UISearchBar *search;
    AFHTTPSessionManager *mg;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"3DMGAME-The.Elder.Scrolls.V.Skyrim.Special.Edition.Cracked-3DM" ofType:@"torrent"];
//    file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"torrent"];
    
    NSError *eror;
    NSData *data =
    [[NSData alloc] initWithContentsOfFile:file];
    if (eror) {
        return;
    }
    NSDictionary *temp = [BDecoder BInfoDecoder:data];
    Tracker *tracker = [Tracker EntityFromContainer:temp];
    mg = [AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    mg.securityPolicy  = securityPolicy;
    mg.requestSerializer = [AFHTTPRequestSerializer serializer];
    mg.responseSerializer = [AFHTTPResponseSerializer serializer];
    mg.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    mg.requestSerializer.timeoutInterval = 300;
//
    NSData *tdata = temp[@"sha1_data"];
    tdata = temp[@"peer_id"];
    
    for (NSArray *arr in temp[@"announce-list"]) {
        NSString *uri = [arr firstObject];
        NSError *error;
        NSURLResponse *resp;
        NSString *url = [NSString stringWithFormat:@"%@?info_hash=%@&peer_id=%@&uploaded=%@&downloaded=%@&left=%@&compact=%@&event=started&port=10775",uri,temp[@"sha1"],@"19089278372819205789",@"0",@"0",temp[@"info"][@"length"],@"1"];
        NSURL *urlss = [NSURL URLWithString:url];
        NSString *scheme = [urlss.scheme lowercaseString];
        NSString *port = [[urlss.port stringValue] lowercaseString];
        NSString *host = urlss.host;
        if ([scheme isEqualToString:@"udp"]) {
//            GCDAsyncUdpSocket * _udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//            NSError * error = nil;
//            [_udpSocket bindToPort:[port intValue] error:&error];
//            if (error) {//监听错误打印错误信息
//                NSLog(@"error:%@",error);
//            }else {//监听成功则开始接收信息
//                [_udpSocket beginReceiving:&error];
//            }
//            [_udpSocket sendData:sendData toHost:host port:udpPort withTimeout:-1 tag:0];
        }else
        {
            [mg GET:uri parameters:@{@"info_hash":tracker.info_hash,
                                     @"peer_id":tracker.peer_id,
                                     @"uploaded":@"0",
                                     @"downloaded":@"0",
                                     @"left":@"206321100",
                                     @"compact":@"1",
                                     @"event":@"started",
                                     @"port":@"6889"}
           progress:^(NSProgress * _Nonnull downloadProgress)
             {
                 NSLog(@"a");
             }
            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
             {
                 NSLog(@"a %@ %@",uri,[BDecoder BInfoDecoder:responseObject]);
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"b %@",uri);
             }];
        }
       
    }
    
}
    
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送信息成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送信息失败");
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"接收到%@的消息:%@",address,data);//自行转换格式吧
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString*encodedString=(NSString*)
    
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              
                                                              (CFStringRef)unencodedString,
                                                              
                                                              NULL,
                                                              
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
