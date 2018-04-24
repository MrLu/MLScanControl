//
//  MLScanFrameView.h
//  MLScanControl
//
//  Created by Mrlu on 2018/4/23.
//  Copyright © 2018 Mrlu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MLScanStyleWeChat,
    MLScanStyleAlipay,
    MLScanStyleCustom
} MLScanStyle;

typedef enum : NSUInteger {
    MLMaskContentStyleFull,
    MLMaskContentStyleCenter
} MLMaskContentStyle;

@protocol MLScanFrameViewProtocol <NSObject>

-(void)startAnimation;
-(void)stopAnimation;

@end

@interface MLScanFrameView : UIView <MLScanFrameViewProtocol>

- (instancetype)initWithFrame:(CGRect)frame style:(MLScanStyle)style;

@end
