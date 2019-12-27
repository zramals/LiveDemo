//
//  JPushViewController.m
//  rmtpTest
//
//  Created by 荆博zramals on 2019/12/24.
//  Copyright © 2019 LAP0332180314. All rights reserved.
//

#import "JPushViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface JPushViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic,strong)AVCaptureSession *captureSession; //session
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic,strong)UIImageView *bufferImageView;
@property (nonatomic,strong)NSString *filterName;
@end

@implementation JPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    self.filterName = @"CISepiaTone";
    NSArray *testArray = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@",testArray);
}

-(void)configUI{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //拍摄,展示拍摄
    [self setupAVCapture];
    //美颜的imageView
    [self initImageView];
    //一些功能键
    [self initFunctions];
    //推视频流
    [self initPushStream];
}

-(void)initPushStream{
    /*
    Swift框架: lf.swift
    OC框架: LFLiveKit
    - (LFLiveSession*)session {
        if (!_session) {
            _session = [[LFLiveSession alloc] initWithAudioConfiguration:  [LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:  [LFLiveVideoConfiguration defaultConfiguration]];
            _session.preView = self.view;
            _session.delegate = self;
        }
        return _session;
    }

    - (IBAction)startLive {
        LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
        streamInfo.url = @"rtmp://47.92.137.30/live/demo";
        self.session.running = YES;
        [self.session startLive:streamInfo];
    }
    */
}
-(void)initFunctions{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(30, 700, 60, 40)];
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitle:@"礼物" forState:UIControlStateNormal];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(130, 700, 60, 40)];
    [button2 setBackgroundColor:[UIColor blueColor]];
    [button2 setTitle:@"发言" forState:UIControlStateNormal];
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setFrame:CGRectMake(230, 700, 60, 40)];
    [button3 setBackgroundColor:[UIColor blueColor]];
    [button3 addTarget:self action:@selector(switchFilter) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"切换滤镜" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
}

-(void)initImageView{
    self.bufferImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 370, 300, 300)];
    [self.view addSubview:self.bufferImageView];
}

#pragma mark - AVCaptureSession
/**
 *  相机初始化方法
 */
- (void)setupAVCapture
{
    NSError *error = nil;
    
    // 1 创建session
    
    self.captureSession = [AVCaptureSession new];
    // 2 设置session显示分辨率
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    else
        [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // 3 获取摄像头device,并且默认使用的前置摄像头,并且将摄像头加入到captureSession中
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];//AVCaptureDevicePositionBack
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ([self.captureSession canAddInput:deviceInput]){
        [self.captureSession addInput:deviceInput];
    }
    // 4 创建预览output,设置预览videosetting,然后设置预览delegate使用的回调线程,将该预览output加入到session
    AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];//设置像素格式
    if ([self.captureSession canAddOutput:videoOutput])
        [self.captureSession addOutput:videoOutput];
    
    //    5 显示捕捉画面
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [videoOutput setSampleBufferDelegate:self queue:queue];
    self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];//相机拍摄预览图层
    self.captureVideoPreviewLayer.frame = CGRectMake(0, 60, 300,300);
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    // 6 启动session,output开始接受samplebuffer回调
    [self.captureSession startRunning];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    if (width == 0 || height == 0) {
        return nil;
    }
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGContextConcatCTM(context, transform);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 裁剪 图片
    struct CGImage *cgImage = CGImageCreateWithImageInRect(quartzImage, CGRectMake(0, 0, height, height));
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //    UIImage *image =  [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    // 释放Quartz image对象
    CGImageRelease(cgImage);
    CGImageRelease(quartzImage);
    //    NSLog(@"原来的%ld %f",(long)image.size.width,image.size.height);
    //    image = [self image:image rotation:UIImageOrientationRight];
    //    NSLog(@"变换过的%ld %f",(long)image.size.width,image.size.height);

    //    image.imageOrientation = 2;

    //    CGImageRelease(cgImage);

//    UIImage *resultImage = [[JBFaceDetectorHelper sharedInstance] rotateWithImage:image isFont:isFront];
    return (image);

}
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CFRetain(sampleBuffer);
    // 把samplebuffer 转化为图片 在方法里可做裁剪
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    // 在这你可以对图片做一些算法操作
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bufferImageView.image = [self imageProcessedUsingCoreImage:image];
    });
    CFRelease(sampleBuffer);
}
-(void)switchFilter{
    NSArray *filterArray = @[@"CISepiaTone",@"CIBloom",@"CIWhitePointAdjust",@"CIHeightFieldFromMask",@"CIDotScreen",@"CISpotColor",@"CIXRay",@"CIPhotoEffectMono"];
    
    NSUInteger index = [filterArray indexOfObject:self.filterName];
    if (index<([filterArray count]-1)) {
        index++;
    }else{
        index = 0;
    }
    self.filterName = [filterArray objectAtIndex:index];
}
#pragma mark - coreImage function
- (UIImage *)imageProcessedUsingCoreImage:(UIImage *)imageToProcess;
{
    CIImage *inputImage = [[CIImage alloc] initWithCGImage:imageToProcess.CGImage];
    CIFilter *sepiaTone = [CIFilter filterWithName:self.filterName];
    [sepiaTone setValue:inputImage forKey:kCIInputImageKey];
//    CIFilter *sepiaTone = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCICategoryColorEffect, inputImage, nil];
    
//    CIFilter *sepiaTone = [CIFilter filterWithName:@"CISepiaTone"
//                                     keysAndValues: kCIInputImageKey, inputImage,
//                           @"inputIntensity", [NSNumber numberWithFloat:1.0], nil];
    
    CIImage *result = [sepiaTone outputImage];
    
    UIImage *resultImage = [UIImage imageWithCIImage:result]; // This gives a nil image, because it doesn't render, unless I'm doing something wrong
//    CIContext *ciContext = [[CIContext alloc] init];
    // 获取OpenGLES渲染环境
//    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
//    CIContext *ciContext = [CIContext contextWithEAGLContext:eaglContext];
//    CGImageRef resultRef = [coreImageContext createCGImage:result fromRect:CGRectMake(0, 0, imageToProcess.size.width, imageToProcess.size.height)];
//    UIImage *resultImage = [UIImage imageWithCGImage:resultRef];
//    CGImageRelease(resultRef);

    
    return resultImage;
}

#pragma mark - memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
