//
//  MLScanControl.m
//  MLScanControl
//
//  Created by Mrlu on 2018/4/23.
//  Copyright © 2018 Mrlu. All rights reserved.
//

#import "MLScanControl.h"
#import <AVFoundation/AVFoundation.h>

@interface MLScanControl()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoDataOutput * videoDataOutput;
@property (nonatomic, strong) AVCaptureSession *scanSession;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer * scanPreviewLayer;
@property (nonatomic, strong) MLScanFrameView * scanFrameView;
@property (nonatomic, strong) UIView * corverLayerView;
@property (nonatomic, strong) CAShapeLayer *maskShapLayer;

@property (nonatomic, strong) UIButton *torchBtn;
@property (nonatomic, assign) BOOL isTurnON;

@property (nonatomic, copy) ResultClosure resultClosure;
@property (nonatomic, assign) CGFloat zoomTemp;

@end

@implementation MLScanControl

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frameSize = CGSizeMake(260, 260);
        self.style = MLScanStyleWeChat;
        self.offsetY = 0;
        self.zoomTemp = 0;
        self.isTurnON = NO;
        self.isSoundEnable = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(MLScanStyle)style {
    self = [self initWithFrame:frame];
    if (self) {
        
        self.style = style;
        self.offsetY = -_frameSize.height/2;
    }
    return self;
}

- (void)initialize {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (self.device) {
        self.scanSession = [[AVCaptureSession alloc] init];
        [self.scanSession canSetSessionPreset:AVCaptureSessionPresetHigh];
        NSError *error = nil;
        self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        self.output = [[AVCaptureMetadataOutput alloc] init];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        if ([self.scanSession canAddInput:self.input]) {
            [self.scanSession addInput:self.input];
        }
        
        if ([self.scanSession canAddOutput:self.output]) {
            [self.scanSession addOutput:self.output];
        }
        
        if([self.scanSession canAddOutput:self.videoDataOutput]) {
            [self.scanSession addOutput:self.videoDataOutput];
        }
        
        self.output.metadataObjectTypes = @[
                                           AVMetadataObjectTypeQRCode,
                                           AVMetadataObjectTypeCode39Code,
                                           AVMetadataObjectTypeCode93Code,
                                           AVMetadataObjectTypeCode128Code,
                                           AVMetadataObjectTypeCode39Mod43Code,
                                           AVMetadataObjectTypeEAN13Code,
                                           AVMetadataObjectTypeEAN8Code
                                           ];
        
        self.scanPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.scanSession];
        self.scanPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.scanPreviewLayer.frame = self.layer.bounds;
        [self.layer insertSublayer:self.scanPreviewLayer atIndex:0];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.output.rectOfInterest = [self.scanPreviewLayer metadataOutputRectOfInterestForRect:self.scanFrameView.frame];
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAction:)];
        tapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAction:)];
        [self addGestureRecognizer:pinchGesture];
        
    }
}

- (void)setUpView {
    self.backgroundColor = [UIColor blackColor];
    
    self.corverLayerView = [[UIView alloc] initWithFrame:self.bounds];
    self.corverLayerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.corverLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.corverLayerView];
    
    self.scanFrameView = [[MLScanFrameView alloc] initWithFrame:CGRectMake(0, 0, self.frameSize.width, self.frameSize.height) style:self.style];
    self.scanFrameView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 + self.offsetY);
    [self addSubview:self.scanFrameView];
    
    self.torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.style == MLScanStyleWeChat) {
        [self.torchBtn setImage:[MLScanControl imageForName:@"weChatScan/ScanLowLight"] forState:UIControlStateNormal];
        [self.torchBtn setImage:[MLScanControl imageForName:@"weChatScan/ScanLowLight_HL"] forState:UIControlStateSelected];
    } else if (self.style == MLScanStyleAlipay) {
        [self.torchBtn setImage:[MLScanControl imageForName:@"zhifuBaoScan/icon_light_off"] forState:UIControlStateNormal];
        [self.torchBtn setImage:[MLScanControl imageForName:@"zhifuBaoScan/icon_light_on"] forState:UIControlStateSelected];
    } else {
        [self.torchBtn setImage:[MLScanControl imageForName:@"weChatScan/ScanLowLight"] forState:UIControlStateNormal];
        [self.torchBtn setImage:[MLScanControl imageForName:@"weChatScan/ScanLowLight_HL"] forState:UIControlStateSelected];
    }
    [self.torchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.torchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.torchBtn.hidden = YES;
    [self.torchBtn addTarget:self action:@selector(torchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.torchBtn.frame = CGRectMake(0, 0, 40, 40);
    
    self.torchBtn.center = CGPointMake(CGRectGetMidX(self.scanFrameView.frame), CGRectGetMaxY(self.scanFrameView.frame) + 30 + self.torchBtn.frame.size.height/2);
    [self addSubview:self.torchBtn];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        [self setUpView];
        __weak typeof(self) weakSelf = self;
        [self authorization:^{
            [weakSelf initialize];
            [weakSelf start];
        } error:^{
            [weakSelf showErrorAlertView];
        }];
    }
}

- (instancetype)result:(ResultClosure)closure {
    self.resultClosure = closure;
    return self;
}

- (void)start {
    if (self.scanSession && !self.scanSession.isRunning) {
        [self.scanSession startRunning];
        [self.scanFrameView startAnimation];
    }
}

- (void)stop {
    if (self.scanSession && self.scanSession.isRunning) {
        [self.scanSession stopRunning];
        [self.scanFrameView stopAnimation];
    }
    self.torchBtn.selected = NO;
}

- (void)authorization:(void(^)(void))authorized error:(void(^)(void))error {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            if (authorized) {
                                authorized();
                            }
                        } else {
                            if (error) {
                                error();
                            }
                        }
                    });
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            if (authorized) {
                authorized();
            }
            break;
        }
        default:
        {
            if (error) {
                error();
            }
            break;
        }
    }
}

- (CAShapeLayer *)maskShapLayer {
    if (_maskShapLayer == nil) {
        _maskShapLayer = [[CAShapeLayer alloc] init];
    }
    return _maskShapLayer;
}

- (void)showErrorAlertView {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请您设置允许该应用访问您的相机" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertVC animated:YES completion:nil];
}

- (void)setTorchBtnEnabel:(BOOL)enabel {
    if (self.torchBtn && !self.torchBtn.selected) {
        self.torchBtn.hidden = !enabel;
        if (!enabel) {
            [self torch:false];
            self.torchBtn.selected = NO;
        }
    }
}

- (void)torchBtnAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self torch:sender.selected];
}

- (void)zoomAction:(UIGestureRecognizer *)gesture {
    if (self.device) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (self.device.videoZoomFactor == self.device.activeFormat.videoMaxZoomFactor) {
                [self zoom:1 rate:10];
            } else {
                [self zoom:self.device.activeFormat.videoMaxZoomFactor rate:10];
            }
        } else if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            if (gesture.state == UIGestureRecognizerStateBegan) {
                self.zoomTemp = self.device.videoZoomFactor;
            }
            if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
                UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)gesture;
                [self zoom:pinchGesture.scale * self.zoomTemp rate:0];
            }
        }
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self stop];
    [self playSound];
    
    if (metadataObjects.count > 0) {
        if ([metadataObjects.firstObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        AVMetadataMachineReadableCodeObject * resultObj = (AVMetadataMachineReadableCodeObject *)metadataObjects.firstObject;
            if (self.resultClosure) {
                self.resultClosure(resultObj.stringValue);
            }
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metaData = (__bridge_transfer NSDictionary *)metadataDict;
    NSDictionary *exifMetadata = [[metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        if (brightnessValue <= 0) {
            [self setTorchBtnEnabel:YES];
        } else {
            [self setTorchBtnEnabel:NO];
        }
}

#pragma mark - Internal Helpers
- (void)playSound {
    if (!self.isSoundEnable) { return; }
    
    NSString *soundPath = [[NSBundle bundleWithPath:[MLScanControl bundlePath]] pathForResource:@"sound/noticeMusic.caf" ofType:nil];
    NSURL *soundUrl = [NSURL URLWithString:soundPath];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundUrl), &soundID);
}

- (void)torch:(BOOL)isTurnOn {
    if (self.device && self.device.hasTorch) {
        if (isTurnOn) {
            [self.device lockForConfiguration:nil];
            self.device.torchMode = AVCaptureTorchModeOn;
            [self.device unlockForConfiguration];
        } else {
            [self.device lockForConfiguration:nil];
            self.device.torchMode = AVCaptureTorchModeOff;
            [self.device unlockForConfiguration];
        }
    }
}

- (void)zoom:(CGFloat)value rate:(CGFloat)rate {
    if (self.device) {
        [self.device lockForConfiguration:nil];
        if (rate > 0) {
            [self.device rampToVideoZoomFactor:MIN(MAX(value, 1),self.device.activeFormat.videoMaxZoomFactor) withRate:rate];
        } else {
            self.device.videoZoomFactor = MIN(MAX(value, 1),self.device.activeFormat.videoMaxZoomFactor);
        }
        [self.device unlockForConfiguration];
    }
}

+ (NSString *)bundlePath {
    return [[NSBundle mainBundle] pathForResource:@"MLScan" ofType:@"bundle"];
}

+ (UIImage *)imageForName:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleWithPath:[self bundlePath]];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"images/%@",name] inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

@end
