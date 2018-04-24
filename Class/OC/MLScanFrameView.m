//
//  MLScanFrameView.m
//  MLScanControl
//
//  Created by Mrlu on 2018/4/23.
//  Copyright © 2018 Mrlu. All rights reserved.
//

#import "MLScanFrameView.h"

@interface MLScanFrameView()

@property (nonatomic, strong) NSArray *corners;
@property (nonatomic, assign) MLScanStyle style;
@property (nonatomic, assign) MLMaskContentStyle maskContentStyle;

@property (nonatomic, strong) UIImageView * corner1;
@property (nonatomic, strong) UIImageView * corner2;
@property (nonatomic, strong) UIImageView * corner3;
@property (nonatomic, strong) UIImageView * corner4;
@property (nonatomic, strong) UIImageView * maskImageView;

@end

@implementation MLScanFrameView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.style = MLScanStyleWeChat;
        self.maskContentStyle = MLMaskContentStyleCenter;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(MLScanStyle)style {
    self = [self initWithFrame:frame];
    if (self) {
        self.style = style;
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 0.5;
    
    [self addSubview:self.maskImageView];
    [self addSubview:self.corner1];
    [self addSubview:self.corner2];
    [self addSubview:self.corner3];
    [self addSubview:self.corner4];
    [self layoutCornersViews];
    [self loadMaskImage];
}

#pragma mark - Internal Helpers
- (void)layoutCornersViews {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MLScan" ofType:@"bundle"]];
    if (self.style == MLScanStyleWeChat) {
        self.corner1.image = [UIImage imageNamed:@"images/weChatScan/ScanQR1.png" inBundle:bundle compatibleWithTraitCollection:nil];
        self.corner2.image = [UIImage imageNamed:@"images/weChatScan/ScanQR2.png" inBundle:bundle compatibleWithTraitCollection:nil];
        self.corner3.image = [UIImage imageNamed:@"images/weChatScan/ScanQR3.png" inBundle:bundle compatibleWithTraitCollection:nil];
        self.corner4.image = [UIImage imageNamed:@"images/weChatScan/ScanQR4.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else if (self.style == MLScanStyleAlipay) {
        self.corner1.image = [UIImage imageNamed:@"images/zhifuBaoScan/scan_1.png" inBundle:bundle compatibleWithTraitCollection:nil];
        self.corner2.image = [UIImage imageNamed:@"images/zhifuBaoScan/scan_2.png" inBundle:bundle compatibleWithTraitCollection:nil];
        self.corner3.image = [UIImage imageNamed:@"images/zhifuBaoScan/scan_3.png" inBundle:bundle compatibleWithTraitCollection:nil];
        self.corner4.image = [UIImage imageNamed:@"images/zhifuBaoScan/scan_4.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else if (self.style == MLScanStyleCustom) {
        if  (self.corners && self.corners.count >= 4) {
            self.corner1.image = [UIImage imageNamed:self.corners[0]];
            self.corner2.image = [UIImage imageNamed:self.corners[1]];
            self.corner3.image = [UIImage imageNamed:self.corners[2]];
            self.corner4.image = [UIImage imageNamed:self.corners[3]];
        }
    }
    if (self.corner1.image) {
        CGSize size = self.corner1.image.size;
        self.corner1.frame = CGRectMake(0, 0, size.width, size.height);
    }
    if (self.corner2.image) {
        CGSize size = self.corner2.image.size;
        self.corner2.frame = CGRectMake(self.bounds.size.width - size.width, 0, size.width, size.height);
    }
    if (self.corner3.image) {
        CGSize size = self.corner3.image.size;
        self.corner3.frame = CGRectMake(0, self.bounds.size.height - size.height, size.width, size.height);
    }
    if (self.corner4.image) {
        CGSize size = self.corner4.image.size;
        self.corner4.frame = CGRectMake(self.bounds.size.width - size.width, self.bounds.size.height - size.height, size.width, size.height);
    }
}

- (void)loadMaskImage {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MLScan" ofType:@"bundle"]];
    if (self.style == MLScanStyleWeChat) {
        self.maskImageView.image = [UIImage imageNamed:@"images/weChatScan/ff_QRCodeScanLine.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else if (self.style == MLScanStyleAlipay) {
        self.maskImageView.image = [UIImage imageNamed:@"images/zhifuBaoScan/scan_net@2x.png" inBundle:bundle compatibleWithTraitCollection:nil];
    }
    if (self.maskImageView.image){
        CGSize size = self.maskImageView.image.size;
        CGFloat height = MIN(self.bounds.size.height, size.height);
        if (self.maskContentStyle == MLMaskContentStyleFull) {
            self.maskImageView.frame = CGRectMake(0, -height, self.bounds.size.width, height);
        } else {
            self.maskImageView.frame = CGRectMake(0, -height/2, self.bounds.size.width, height);
        }
    }
}

- (void)startAnimation {
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat animations:^{
        self.maskImageView.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    } completion:nil];
}

- (void)stopAnimation {
    [self.maskImageView.layer removeAllAnimations];
    self.maskImageView.transform = CGAffineTransformIdentity;
}

#pragma mark - property Getter/Setter
- (MLMaskContentStyle)maskContentStyle {
    if (self.style == MLScanStyleWeChat) {
        _maskContentStyle = MLMaskContentStyleCenter;
    }
    if (self.style == MLScanStyleAlipay) {
        _maskContentStyle = MLMaskContentStyleFull;
    }
    return _maskContentStyle;
}

- (UIImageView *)corner1 {
    if (_corner1 == nil) {
        _corner1 = [[UIImageView alloc] init];
        _corner1.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _corner1;
}

- (UIImageView *)corner2 {
    if (_corner2 == nil) {
        _corner2 = [[UIImageView alloc] init];
        _corner2.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _corner2;
}

- (UIImageView *)corner3 {
    if (_corner3 == nil) {
        _corner3 = [[UIImageView alloc] init];
        _corner3.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _corner3;
}

- (UIImageView *)corner4 {
    if (_corner4 == nil) {
        _corner4 = [[UIImageView alloc] init];
        _corner4.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _corner4;
}

- (UIImageView *)maskImageView {
    if (_maskImageView == nil) {
        _maskImageView = [[UIImageView alloc] init];
        _maskImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _maskImageView;
}


@end
