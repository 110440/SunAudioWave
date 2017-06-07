//
//  SunVideoTool.h
//  SunVideoTest
//
//  Created by 孙兴祥 on 2017/6/7.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^SunSampleDataCompletionBlock)(NSArray *sampleDatas);

@interface SunVideoTool : NSObject

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset forSize:(CGSize)size completeTionBlock:(SunSampleDataCompletionBlock)completionBlock;

@end
