//
//  JPushFLLiveViewController.m
//  rmtpTest
//
//  Created by 荆博zramals on 2019/12/26.
//  Copyright © 2019 LAP0332180314. All rights reserved.
//

#import "JPushFLLiveViewController.h"
#import "LFLiveKit.h"
@interface JPushFLLiveViewController ()<LFLiveSessionDelegate>
@property (nonatomic, strong)LFLiveSession *session;
@end

@implementation JPushFLLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
    
    [self requestAccessForVideo];
    [self requestAccessForAudio];
    
    [self LFLiveKitInit];
    
//    [self startRMTP];
}
-(void)configUI{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(30, 700, 60, 40)];
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitle:@"美颜-" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bjian) forControlEvents:UIControlEventTouchUpInside];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(130, 700, 60, 40)];
    [button2 setBackgroundColor:[UIColor blueColor]];
    [button2 setTitle:@"美颜+" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(bjia) forControlEvents:UIControlEventTouchUpInside];
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setFrame:CGRectMake(230, 700, 60, 40)];
    [button3 setBackgroundColor:[UIColor blueColor]];
    [button3 addTarget:self action:@selector(lightjian) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"光亮-" forState:UIControlStateNormal];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 setFrame:CGRectMake(330, 700, 60, 40)];
    [button4 setBackgroundColor:[UIColor blueColor]];
    [button4 addTarget:self action:@selector(lightPlus) forControlEvents:UIControlEventTouchUpInside];
    [button4 setTitle:@"光亮+" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
    [self.view addSubview:button4];
}
-(void)bjian{
    self.session.beautyLevel = self.session.beautyLevel-0.1;
}
-(void)bjia{
    self.session.beautyLevel = self.session.beautyLevel+0.1;
}
-(void)lightjian{
    self.session.brightLevel = self.session.brightLevel-0.1f;
}
-(void)lightPlus{
    self.session.brightLevel = self.session.brightLevel+0.1f;
}
-(void)startRMTP{
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];

//    stream.url = RTMP_URL_1;

    [self.session startLive:stream];
}
-(void)LFLiveKitInit{
    UIView *previewView = [[UIView alloc] init];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [previewView setFrame:CGRectMake(0, 0, 400, 400)];
    [previewView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:previewView];
    
    self.session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration] captureType:LFLiveCaptureDefaultMask];

    self.session.preView= previewView;

    //设置代理

    self.session.delegate = self;

    self.session.running = YES;
    self.session.beautyLevel = 0.8;
    self.session.brightLevel = 0.8;
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    
    #warning --填写推流地址
    stream.url = @"http://10.10.47.27:1935/myRmtp/room";
    [self.session startLive:stream];
//    [self.session startLive:[NSURL URLWithString:@""]];
}

-(void)dealloc{
    [self.session stopLive];
}

#pragma mark - LFLiveSessionDelegate
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    /*
     typedef NS_ENUM (NSUInteger, LFLiveState){
     /// 准备
     LFLiveReady = 0,
     /// 连接中
     LFLivePending = 1,
     /// 已连接
     LFLiveStart = 2,
     /// 已断开
     LFLiveStop = 3,
     /// 连接出错
     LFLiveError = 4,
     ///  正在刷新
     LFLiveRefresh = 5
     };
     */
    NSLog(@"%ld",state);
}
- (void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    NSLog(@"连接失败");
}


#pragma mark -- 请求权限
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }
}
- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

@end
