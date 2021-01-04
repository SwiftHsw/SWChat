//
//  MOKOSecretTrainRecorder.h
//  MOKORecord
//
//  Created by Spring on 2017/4/26.
//  Copyright © 2017年 Spring. All rights reserved.
//  新建密训录音播放工具

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MOKORecorderTool;
@protocol MOKOSecretTrainRecorderDelegate <NSObject>

@optional
- (void)recorder:(MOKORecorderTool *)recorder filePath:(NSString *)file;
- (void)recordToolDidFinishPlay:(MOKORecorderTool *)recorder;
@end
@interface MOKORecorderTool : NSObject

//录音工具的单例
+ (instancetype)sharedRecorder;

//开始录音
- (void)startRecording;

//停止录音
- (void)stopRecording;

//播放录音文件
- (void)playRecordingFile;

//停止播放录音文件
- (void)stopPlaying;

//销毁录音文件
- (void)destructionRecordingFile;

//录音对象
@property (nonatomic, strong) AVAudioRecorder *recorder;

//播放器对象
@property (nonatomic, strong) AVAudioPlayer *player;

//更新图片的代理
@property (nonatomic, assign) id<MOKOSecretTrainRecorderDelegate> delegate;

@end
