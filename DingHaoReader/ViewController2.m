//
//  ViewController2.m
//  DingHaoReader
//
//  Created by JD on 16/12/28.
//  Copyright © 2016年 LYC. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()
{
    dispatch_queue_t queue;
}
@end

@implementation ViewController2

-(void)dealloc
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    queue = dispatch_queue_create("com.ConcurrentQueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
