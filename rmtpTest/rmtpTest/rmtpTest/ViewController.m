//
//  ViewController.m
//  rmtpTest
//
//  Created by 荆博zramals on 2019/12/23.
//  Copyright © 2019 LAP0332180314. All rights reserved.
//

#import "ViewController.h"
#import "JPlayViewController.h"
#import "JPushViewController.h"
#import "JPushFLLiveViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
}
- (IBAction)playAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"];
    [self.navigationController pushViewController:[[JPlayViewController alloc] initWithURL:url] animated:YES];
//     [self presentViewController:[[JPlayViewController alloc] initWithURL:url] animated:YES completion:nil];
}

- (IBAction)pushAction:(id)sender {
    JPushViewController *vc = [JPushViewController new];
    vc.title = @"up主";
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)FLPushAction:(id)sender {
    JPushFLLiveViewController *vc = [JPushFLLiveViewController new];
    vc.title = @"up主";
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)zhiboPlayAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"rtmp://10.10.47.27:1935/myRmtp/room"];
    [self.navigationController pushViewController:[[JPlayViewController alloc] initWithURL:url] animated:YES];
//    [self presentViewController:[[JPlayViewController alloc] initWithURL:url] animated:YES completion:nil];
}

@end
