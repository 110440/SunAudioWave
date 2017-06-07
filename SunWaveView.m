//
//  SunWaveView.m
//  SunVideoTest
//
//  Created by 孙兴祥 on 2017/6/7.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import "SunWaveView.h"
#import <AVFoundation/AVFoundation.h>
#import "SunVideoTool.h"

static const CGFloat WidthScaling = 0.95;
static const CGFloat HeightScaling = 0.85;

@interface SunWaveView ()

@property (nonatomic,strong) NSArray *sampleDatas;

@end

@implementation SunWaveView

- (void)showWaveWithAsset:(AVAsset *)asset {

    [SunVideoTool loadAudioSamplesFromAsset:asset forSize:self.bounds.size completeTionBlock:^(NSArray *sampleDatas) {
       
        _sampleDatas = sampleDatas;
        [self setNeedsDisplay];
    }];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, WidthScaling, HeightScaling);

    CGFloat xOffset = self.bounds.size.width-self.bounds.size.width*WidthScaling;
    CGFloat yOffset = self.bounds.size.height-self.bounds.size.height*HeightScaling;
    
    CGContextTranslateCTM(context, xOffset/2.0, yOffset/2.0);
    
    CGFloat midY = CGRectGetMidY(rect);
    
    CGMutablePathRef halfPath = CGPathCreateMutable();
    CGPathMoveToPoint(halfPath, NULL, 0, midY);
    
    for(NSUInteger i = 0; i < _sampleDatas.count; i++){
        
        float sample = [_sampleDatas[i] floatValue];
        CGPathAddLineToPoint(halfPath, NULL, i, midY-sample);
//        NSLog(@"x = %lu,y = %f",(unsigned long)i,midY-sample);
    }
    
    CGPathAddLineToPoint(halfPath, NULL, _sampleDatas.count, midY);
    
    CGMutablePathRef fullPath = CGPathCreateMutable();
    CGPathAddPath(fullPath, NULL, halfPath);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, midY*2);
    transform = CGAffineTransformScale(transform, 1, -1);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    CGContextAddPath(context, fullPath);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    
    CGPathRelease(fullPath);
    CGPathRelease(halfPath);
    
}

@end
