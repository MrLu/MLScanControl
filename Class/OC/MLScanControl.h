//
//  MLScanControl.h
//  MLScanControl
//
//  Created by Mrlu on 2018/4/23.
//  Copyright © 2018 Mrlu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLScanFrameView.h"

typedef void(^ResultClosure)(NSString *result);

@interface MLScanControl : UIControl

@property (nonatomic, assign) MLScanStyle style;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) BOOL isSoundEnable;
- (instancetype)initWithFrame:(CGRect)frame style:(MLScanStyle)style;
- (instancetype)result:(ResultClosure)closure;
- (void)start;
- (void)stop;

@end
