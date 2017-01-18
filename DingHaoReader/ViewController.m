//
//  ViewController.m
//  DingHaoReader
//
//  Created by JD on 16/12/28.
//  Copyright © 2016年 LYC. All rights reserved.
//
#import "Bdecoder.h"
#import "ViewController.h"
#import "ViewController2.h"
#import "CocoaAsyncSocket.h"
@interface ViewController ()<GCDAsyncUdpSocketDelegate>
{
    UISearchBar *search;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"shadowhunters the mortal instruments s02e02 hdtv x264-fleeteztv mkv" ofType:@"torrent"];
//    file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"torrent"];
    
    NSError *eror;
    NSData *data =
    [[NSData alloc] initWithContentsOfFile:file];
    if (eror) {
        return;
    }
    NSDictionary *temp = [Bdecoder BInfoDecoder:data];
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
        }
        NSData *datat = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:urlss] returningResponse:&resp error:&error];
        NSString *xxxx = [[NSString alloc] initWithData:datat encoding:NSASCIIStringEncoding];
        NSLog(@"%@",xxxx);
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
