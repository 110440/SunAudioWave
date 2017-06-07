//
//  SunVideoTool.m
//  SunVideoTest
//
//  Created by 孙兴祥 on 2017/6/7.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import "SunVideoTool.h"

@implementation SunVideoTool

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset forSize:(CGSize)size completeTionBlock:(SunSampleDataCompletionBlock)completionBlock; {
    
    
    NSString *tracks = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:@[tracks] completionHandler:^{
       
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        
        NSData *sampleData = nil;
        
        if(status == AVKeyValueStatusLoaded){
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *filteredArray = [self filteredSamplesForSize:size sampleDatas:sampleData];
            completionBlock(filteredArray);
        });
    }];
}

//读取音频样本
+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    
    NSError *error = nil;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if(!assetReader){
        return nil;
    }
    //获取音频轨道
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    NSDictionary *outputSetting = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                                    AVLinearPCMIsBigEndianKey:@NO,
                                    AVLinearPCMIsFloatKey:@NO,
                                    AVLinearPCMBitDepthKey:@16};
    //设置音频输出格式
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSetting];
    
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    
    NSMutableData *sampleData = [NSMutableData data];
    
    while(assetReader.status == AVAssetReaderStatusReading){
        
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
        
        if(sampleBuffer){
            
            CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
            
            size_t length = CMBlockBufferGetDataLength(blockBuffer);
            SInt16 sampleBytes[length];
            
            CMBlockBufferCopyDataBytes(blockBuffer, 0, length, sampleBytes);
            
            [sampleData appendBytes:sampleBytes length:length];
            //指定样本buffer已经处理和不在继续使用
            CMSampleBufferInvalidate(sampleBuffer);
            //释放
            CFRelease(sampleBuffer);
        }
    }
    
    [assetReader cancelReading];
    
    if(assetReader.status == AVAssetReaderStatusCompleted){
        return sampleData;
    }else{
        return nil;
    }

}

//缩减音频样本
+ (NSArray *)filteredSamplesForSize:(CGSize)size sampleDatas:(NSData *)sampleDatas {
    
    if(size.width <= 0.0 || size.height <= 0.0 || sampleDatas == nil){
        return nil;
    }
    
    NSMutableArray *filteredSamples = [NSMutableArray array];
    //得到音频赝本个数
    NSUInteger sampleCount = sampleDatas.length/sizeof(SInt16);
    //计算每个像素含有多少音频样本
    NSUInteger binSize = sampleCount / size.width;
    
    SInt16 *bytes = (SInt16 *)sampleDatas.bytes;
    //记录所有音频样本中的最大值
    SInt16 maxSample = 0;
    //遍历每个像素内音频样本
    for(NSUInteger i = 0; i < sampleCount; i += binSize){
        
        SInt16 sampleBin[binSize];
    
        for(NSUInteger j = 0; j < binSize; j++){
            sampleBin[j] = CFSwapInt16LittleToHost(bytes[i+j]);
        }
        
        SInt16 value = [self maxValueInArray:sampleBin ofSize:binSize];
        [filteredSamples addObject:@(value)];
        
        if(value > maxSample){
            maxSample = value;
        }
    }
    
    CGFloat scaleFactor = (size.height/2.0)/maxSample;
    
    for(NSUInteger i = 0;i < filteredSamples.count; i++){
        filteredSamples[i] = @(([filteredSamples[i] integerValue])*scaleFactor);
    }
    
    return filteredSamples;
}

//取最大值
+ (SInt16)maxValueInArray:(SInt16[])values ofSize:(NSUInteger)size {
    
    SInt16 maxValue = 0;
    for(int i = 0;i<size;i++){
        if(values[i] > maxValue){
            maxValue = values[i];
        }
    }
    return maxValue;
}

@end
