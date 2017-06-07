//
//  SunWaveView.h
//  SunVideoTest
//
//  Created by 孙兴祥 on 2017/6/7.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAsset;
@interface SunWaveView : UIView

- (void)showWaveWithAsset:(AVAsset *)asset;

@end
