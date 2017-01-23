//
//  NetManager.m
//  DingHaoReader
//
//  Created by JD on 17/1/23.
//  Copyright © 2017年 LYC. All rights reserved.
//

#import "NetManager.h"
#import "CocoaAsyncSocket.h"

@interface NetManager ()<NSURLSessionDelegate,GCDAsyncUdpSocketDelegate>
{
    NSOperationQueue *queue;
    TrackerSerialization *trackerserialization;
    long long connection_id;
}
@property (nonatomic,strong)NSURLSession *session;
@property (nonatomic,strong)GCDAsyncUdpSocket * udpSocket;
@property (nonatomic,copy)TrackerAnnounceBlock announceblock;
@end

@implementation NetManager
@synthesize session = session;
@synthesize udpSocket = udpSocket;
+(id)Share
{
    static NetManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [NetManager new];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        connection_id = 0x41727101980;
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:queue];
        udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

+(void)Tracker:(TrackerSerialization *)trackserialization success:(TrackerAnnounceBlock)block;
{
    NetManager *share = [self Share];
    [share Tracker:trackserialization success:block];
}

-(void)Tracker:(TrackerSerialization *)serialization success:(TrackerAnnounceBlock)block;
{
    self.announceblock = block;
    trackerserialization = serialization;
    switch (trackerserialization.type) {
        case HttpTracker:
            [self HttpTracker];
            break;
        case UdpTracker:
            [self UdpTracker:6188];
            break;
    }
}


-(void)HttpTracker
{
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@?",trackerserialization.url];
    NSDictionary *dict = [self trackerHttpParams:trackerserialization.tracker];
    for (int i=0; i<dict.allKeys.count; i++) {
        [url appendFormat:@"%@%@=%@",(i&1?@"":@"&"),dict.allKeys[i],dict.allValues[i]];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    request.HTTPMethod = @"GET";
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.announceblock(data,error);
    }] resume];
}

-(NSDictionary *)trackerHttpParams:(Tracker *)tracker
{
    return @{};
}

-(void)UdpTracker:(unsigned)port
{
    NSError * error = nil;
    [udpSocket bindToPort:port error:&error];
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
        [self UdpTracker:++port];
    }else {//监听成功则开始接收信息
        [udpSocket beginReceiving:&error];
    }
}

-(void)udpTrackerSendConnectrequest
{
    [udpSocket sendData:[self data1] toHost:trackerserialization.ip port:(unsigned)[trackerserialization.port intValue] withTimeout:60 tag:0];
}

-(void)udpTrackerSendAnnouncerequest
{
    [udpSocket sendData:[self data2] toHost:trackerserialization.ip port:(unsigned)[trackerserialization.port intValue] withTimeout:60 tag:0];
}

-(void)udpTrackerSendScraperequest
{
    [udpSocket sendData:[self data3] toHost:trackerserialization.ip port:(unsigned)[trackerserialization.port intValue] withTimeout:60 tag:0];
}

-(NSData *)data1
{
//    Offset  Size            Name            Value
//    0       64-bit integer  connection_id   0x41727101980
//    8       32-bit integer  action          0 // connect
//    12      32-bit integer  transaction_id
//    16
    
    long long mconnection_id = htonll(connection_id);
    int action = htonl(0);
    int transaction_id = htonl(123456);
    
    
    NSMutableData *data = [NSMutableData new];
    [data appendBytes:&mconnection_id length:8];
    [data appendBytes:&action length:4];
    [data appendBytes:&transaction_id length:4];
    return data;
}

-(NSData *)data2
{
//    Offset  Size    Name    Value
//    0       64-bit integer  connection_id
//    8       32-bit integer  action          1 // announce
//    12      32-bit integer  transaction_id
//    16      20-byte string  info_hash
//    36      20-byte string  peer_id
//    56      64-bit integer  downloaded
//    64      64-bit integer  left
//    72      64-bit integer  uploaded
//    80      32-bit integer  event           0 // 0: none; 1: completed; 2: started; 3: stopped
//    84      32-bit integer  IP address      0 // default
//    88      32-bit integer  key
//    92      32-bit integer  num_want        -1 // default
//    96      16-bit integer  port
//    98
    
    long long mconnection_id = htonll(connection_id);
    int action = htonl(0);
    int transaction_id = htonl(123456);
    NSString *hash_info = trackerserialization.tracker.info_hash;
    NSString *peer_id = trackerserialization.tracker.peer_id;
    
//    [self.data appendData:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableData *data = [NSMutableData new];
    
    return data;
}

-(NSData *)data3
{
//    Offset          Size            Name            Value
//    0               64-bit integer  connection_id
//    8               32-bit integer  action          2 // scrape
//    12              32-bit integer  transaction_id
//    16 + 20 * n     20-byte string  info_hash
//    16 + 20 * N
    NSMutableData *data = [NSMutableData new];
    return data;
}



- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address;
{

}
/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error;
{
    self.announceblock(nil,error);
}
/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
{

}
/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error;
{
    self.announceblock(nil,error);
}
/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext;
{

    int action = -1;
    [data getBytes:&action range:NSMakeRange(0, 4)];
    action = ntohl(action);
    int transaction_id = -1;
    switch (action) {
        case 0:
//            Offset  Size            Name            Value
//            0       32-bit integer  action          0 // connect
//            4       32-bit integer  transaction_id
//            8       64-bit integer  connection_id
//            16
            if (data.length>=16) {
                [data getBytes:&transaction_id range:NSMakeRange(4, 4)];
                transaction_id = ntohl(action);
                [data getBytes:&connection_id range:NSMakeRange(4, 8)];
                connection_id = ntohll(action);
                [self udpTrackerSendAnnouncerequest];
                return;
            }
            break;
        case 1:
//            Offset      Size            Name            Value
//            0           32-bit integer  action          1 // announce
//            4           32-bit integer  transaction_id
//            8           32-bit integer  interval
//            12          32-bit integer  leechers
//            16          32-bit integer  seeders
//            20 + 6 * n  32-bit integer  IP address
//            24 + 6 * n  16-bit integer  TCP port
//            20 + 6 * N

            if (data.length>=20) {
                return;
            }
            break;
        case 2:
//            Offset      Size            Name            Value
//            0           32-bit integer  action          2 // scrape
//            4           32-bit integer  transaction_id
//            8 + 12 * n  32-bit integer  seeders
//            12 + 12 * n 32-bit integer  completed
//            16 + 12 * n 32-bit integer  leechers
//            8 + 12 * N

            if (data.length>=8) {
                return;
            }
            break;
        case 3:
//            Offset  Size            Name            Value
//            0       32-bit integer  action          3 // error
//            4       32-bit integer  transaction_id
//            8       string  message
            if (data.length>=8) {
                return;
            }
            break;
    }
}
/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error;
{

}




@end
