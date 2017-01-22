//
//  Bdecoder.m
//  DingHaoReader
//
//  Created by JD on 17/1/18.
//  Copyright © 2017年 LYC. All rights reserved.
//
#import<CommonCrypto/CommonDigest.h>
#import "BDecoder.h"
NS_ENUM(NSInteger,Type)
{
    DictionaryType = 1,
    ArrayType,
    IntegerType
};
@implementation BDecoder

+(NSString *)BTInfostr:(NSData *)data
{
    NSString *str = nil;
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+(id)BInfoDecoder:(NSData *)infodata;
{

    NSString *str = [self BTInfostr:infodata];
    
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
    if (infoIndexBegin!=0 && infoIndexEnd!=0) {
        NSString *needsha1str = [str substringFromIndex:infoIndexBegin];
        needsha1str = [needsha1str substringToIndex:infoIndexEnd-infoIndexBegin];
        //日了够了，搞半天info_hash 需要去掉4:info头，但是d的结尾e我也给去掉了！！不能去掉啊
        NSData *tempdata = [infodata subdataWithRange:NSMakeRange(infoIndexBegin, infoIndexEnd-infoIndexBegin+1)];
        
        NSString *sha1 = [self sha1:tempdata];
        [[firstrongqi firstObject] setObject:sha1 forKey:@"HASH"];
        
        NSString *data = [self sha1data:tempdata];
        [[firstrongqi firstObject] setObject:data forKey:@"info_hash"];
        
        data = [self ret20bitString];
        [[firstrongqi firstObject] setObject:data forKey:@"peer_id"];
        
    }
    return [firstrongqi firstObject];
}




//sha1加密方式
+ (NSString *) sha1:(NSData *)data
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (uint32_t)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}


+ (NSString *)sha1data:(NSData *)data
{
    unsigned char source[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (uint32_t)data.length, source);
    NSMutableString* output = [NSMutableString new];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%02x", source[i]];
        //change value to 0x 
    }
    return [self urlencoder:source];
}

+(NSString *)ret20bitString
{
    char data[20];
    for (int x=0;x<20;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [self urlencoder:data];
}

+(NSString *)urlencoder:(char *)source
{
//const char source[20] = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf1, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef, 0x12, 0x34, 0x56, 0x78, 0x9a};
    NSMutableString *output = [NSMutableString string];
    NSLog(@"Raw Data: %@", [NSData dataWithBytes:source length:20]);
    int sourceLen = strlen(source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}




@end
