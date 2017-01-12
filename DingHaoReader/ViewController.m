//
//  ViewController.m
//  DingHaoReader
//
//  Created by JD on 16/12/28.
//  Copyright © 2016年 LYC. All rights reserved.
//
#import<CommonCrypto/CommonDigest.h>
#import "ViewController.h"
#import "ViewController2.h"
@interface ViewController ()
{
    UISearchBar *search;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"txt"];
//    file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"torrnet"];
//    file = [[NSBundle mainBundle] pathForResource:@"test 2" ofType:@"txt"];
    
    NSData *data =
    [NSData dataWithContentsOfFile:file];
    NSString *str = nil;
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSDictionary *temp = [self torrnet:str];
    for (NSArray *arr in temp[@"announce-list"]) {
        NSString *host = [arr firstObject];
        NSError *error;
        NSURLResponse *resp;
        NSString *url = [NSString stringWithFormat:@"%@?info_hash=%@&peer_id=%@&uploaded=%@&downloaded=%@&left=%@&compact=%@&event=started",host,temp[@"sha1"],@"19089278372819205789",@"0",@"0",temp[@"info"][@"length"],@"1"];
        //    NSString *url = [NSString stringWithFormat:@"%@?info_hash=%@",temp[@"announce"],temp[@"sha1"]];
        NSURL *urlss = [NSURL URLWithString:url];
        NSData *datat = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:urlss] returningResponse:&resp error:&error];
        NSString *xxxx = [[NSString alloc] initWithData:datat encoding:NSASCIIStringEncoding];
        NSLog(@"%@",xxxx);
    }
    
}

NS_ENUM(NSInteger,Type)
{
    DictionaryType = 1,
    ArrayType,
    IntegerType
};

-(NSDictionary *)torrnet:(NSString *)str
{
    //    str = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
    //    3:abc             \d+:
    //    d3:defe           d^e$
    //    i3e               i\d+e
    //    ld3:xyzei3e           l (以上三种)
    
    NSInteger infoIndexBegin = 0;
    NSInteger infoIndexEnd = 0;
    
    NSMutableArray *typeList = [NSMutableArray new];
    int step = 0;
    NSMutableString *length = [NSMutableString new];
    NSMutableString *key = [NSMutableString new];
    NSMutableArray * firstrongqi = [NSMutableArray new];
    id lastrongqi = firstrongqi;
    NSMutableArray * lastpreviosrongqi = [NSMutableArray new];
    enum Type lastType = 0;
    
    for (int i=0; i<str.length; i++) {
        NSString *sub = [str substringWithRange:NSMakeRange(i, 1)];
        if (typeList.count!=0) {
            lastType = [[typeList lastObject] integerValue];
        }
        if (step!=0) {
            step--;
            continue;
        }
        NSScanner* scan = [NSScanner scannerWithString:sub];
        int val;
        if ([scan scanInt:&val]) {
            [length appendString:sub];
        }
        else if (lastType != IntegerType)
        {
            if ([sub isEqualToString:@":"] && length.length!=0) {
                step = (int)[length integerValue];
                NSString *xx = [str substringWithRange:NSMakeRange(i+1, step)];
                if ([lastrongqi isKindOfClass:[NSDictionary class]]) {
                    if (key.length==0) {
                        [key appendString:xx];
                        if ([xx isEqualToString:@"info"]) {
                            infoIndexBegin = i+4+1;
                        }
                    }else
                    {
                        [lastrongqi setObject:xx forKey:key];
                        key = [NSMutableString new];
                    }
                }
                else
                    if ([lastrongqi isKindOfClass:[NSArray class]]) {
                        [lastrongqi addObject:xx];
                    }
                length = [NSMutableString new];
            }else
                length = [NSMutableString new];
        }
        
        if ([sub isEqualToString:@"d"]) {
            [typeList addObject:@(DictionaryType)];
            NSMutableDictionary *temp = [NSMutableDictionary new];
            
            if ([lastrongqi isKindOfClass:[NSDictionary class]]) {
                [lastrongqi setObject:temp forKey:key];
                key = [NSMutableString new];
            }
            else
                if ([lastrongqi isKindOfClass:[NSArray class]]) {
                    [lastrongqi addObject:temp];
                }
            
            [lastpreviosrongqi addObject:temp];
            lastrongqi = temp;
        }
        
        if ([sub isEqualToString:@"l"]) {
            [typeList addObject:@(ArrayType)];
            NSMutableArray *temp = [NSMutableArray new];
            
            if ([lastrongqi isKindOfClass:[NSDictionary class]]) {
                [lastrongqi setObject:temp forKey:key];
                key = [NSMutableString new];
            }
            else
                if ([lastrongqi isKindOfClass:[NSArray class]]) {
                    [lastrongqi addObject:temp];
                }
            
            [lastpreviosrongqi addObject:temp];
            lastrongqi = temp;
        }
        
        if ([sub isEqualToString:@"i"]) {
            [typeList addObject:@(IntegerType)];
        }
        
        if ([sub isEqualToString:@"e"]) {
            if (lastType==IntegerType) {
                if ([lastrongqi isKindOfClass:[NSDictionary class]]) {
                    [lastrongqi setObject:length forKey:key];
                    key = [NSMutableString new];
                }
                else
                    if ([lastrongqi isKindOfClass:[NSArray class]]) {
                        [lastrongqi addObject:length];
                    }
                length = [NSMutableString new];
            }
            if (lastType==DictionaryType || lastType==ArrayType) {
                for (id temp in firstrongqi) {
                    if ([temp isKindOfClass:[NSDictionary class]]) {
                        id dict = temp[@"info"];
                        if (dict==lastrongqi) {
                            infoIndexEnd = i;
                        }
                    }
                }
                [lastpreviosrongqi removeLastObject];
                lastrongqi = [lastpreviosrongqi lastObject];
            }
            [typeList removeLastObject];
        }
    }
    NSString *needsha1str = [str substringFromIndex:infoIndexBegin];
    needsha1str = [needsha1str substringToIndex:infoIndexEnd-infoIndexBegin];
    NSString *sha1 = [self sha1:needsha1str];
    [[firstrongqi firstObject] setObject:sha1 forKey:@"sha1"];
    return [firstrongqi firstObject];
}

//sha1加密方式
- (NSString *) sha1:(NSString *)input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}



-(void)viewDidAppear:(BOOL)animated
{
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
