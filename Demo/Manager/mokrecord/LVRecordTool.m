//
//  LVRecordTool.m
//  RecordAndPlayVoice
//
//  Created by PBOC CS on 15/3/14.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#define LVRecordFielName @"lvRecord.caf"
#import <SWKit/SWKit.h>

#import "LVRecordTool.h"

@interface LVRecordTool () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>



/** 录音文件地址 */
@property (nonatomic, strong) NSURL *recordFileUrl;

@property (nonatomic, strong) NSString *filePath;


/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation LVRecordTool

- (void)startRecording {
    // 录音时停止播放 删除曾经生成的文件
//    [self stopPlaying];
    [self destructionRecordingFile];
    
    // 真机环境下需要的代码
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    self.session = session;
    
    
    self.filePath =  [[NSString stringWithFormat:@"%@/SWChatUI/chat/touchVoice/",SWDocumentPath] stringByAppendingString:[[[NSString getRandomString] substringToIndex:5] stringByAppendingString:@".wav"]];
    
    self.recordFileUrl = [NSURL fileURLWithPath:self.filePath];
 
  
//    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    [timer fire];
//    self.timer = timer;
       
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:[self getSettings] error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder record];
    if (!_isPlayBack) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}

 

- (NSMutableDictionary *)getSettings{
    // 3.设置录音的一些参数
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    // 音频格式
//    setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);
    // 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    setting[AVSampleRateKey] = @(44100);
    // 音频通道数 1 或 2
    setting[AVNumberOfChannelsKey] = @(1);
    // 线性音频的位深度  8、16、24、32
    setting[AVLinearPCMBitDepthKey] = @(8);
    //录音的质量
    setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];
    return setting;;
}
- (void)updateImage {
    
    [self.recorder updateMeters];
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    NSLog(@"%f", result);
    int no = 0;
    if (result > 0 && result <= 1.3) {
        no = 1;
    } else if (result > 1.3 && result <= 2) {
        no = 2;
    } else if (result > 2 && result <= 3.0) {
        no = 3;
    } else if (result > 3.0 && result <= 3.0) {
        no = 4;
    } else if (result > 5.0 && result <= 10) {
        no = 5;
    } else if (result > 10 && result <= 40) {
        no = 6;
    } else if (result > 40) {
        no = 7;
    }
    
    if ([self.delegate respondsToSelector:@selector(recordTool:didstartRecoring:)]) {
        [self.delegate recordTool:self didstartRecoring: no];
    }
}

- (void)stopRecording {
    
    double currentTime = self.recorder.currentTime;
    NSLog(@"说话时间====%lf", currentTime);
    if ([_recorder isRecording]) {
        [_recorder stop];
        [_timer invalidate];
        _recorder = nil;
    }
    
    !self.avCuttimeBlock ?:self.avCuttimeBlock(currentTime);
     
    if (currentTime < 2) {
        SWLog(@"说话时间太短");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self destructionRecordingFile];
        });
    } else {
        
        // 已成功录音
        SWLog(@"停止录音，已成功录音==%@====/n %@",self.filePath,self.recordFileUrl);
        int time = currentTime;
        NSString *disName = [[self.filePath componentsSeparatedByString:@"/"]lastObject];
        !self.avSuccessBlock?:self.avSuccessBlock(self.filePath,time ,disName);
    }
    
    
 
}

- (void)playRecordingFile:(NSURL *)urlString {
    // 播放时停止录音
    [self.recorder stop];
    
    // 正在播放就返回
    if ([self.player isPlaying]) return;
     
    
    NSString *url = [NSString stringWithFormat:@"%@", urlString];
    
    if ([url containsString:@"https"]) {
        
               NSData *data = [[NSData alloc]initWithContentsOfURL:urlString];
               NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
               NSString *filePath = [NSString stringWithFormat:@"%@/%@.wav", docDirPath , @"temp"];
               [data writeToFile:filePath atomically:YES];//在沙盒Document目录下缓存文件
               NSURL *musicurl = [NSURL fileURLWithPath:filePath];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicurl error:NULL];
    }else{
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlString error:NULL];
    }
    
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
    
    self.player.delegate = self;
    
}

- (void)stopPlaying {
    [self.player stop];
    if (_oldBtn) {
        _oldBtn.selected=false;
    }
    self.player = nil;
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    [_oldBtn.animationView stopAnimating];
    
}
static id instance;
#pragma mark - 单例
+ (instancetype)sharedRecordTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

 
- (void)destructionRecordingFile {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.recordFileUrl) {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        [self.session setActive:NO error:nil];
    }
}

@end
