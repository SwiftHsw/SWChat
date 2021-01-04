//
//  ATAVAudioPlayer.m
//  ATWeChatProject
//
//  Created by Qiaojun Chen on 2018/7/7.
//  Copyright © 2018年 Qiaojun Chen. All rights reserved.
//

#import "SWAVAudioPlayer.h"


@interface SWAVAudioPlayer()<AVAudioPlayerDelegate>

@property (nonatomic, strong) NSTimer *timer;
//当前的播放进度
@property (nonatomic, assign) NSInteger timeCount;

@property (nonatomic, strong) NSString *oldPlayUrl;
@end

@implementation SWAVAudioPlayer
#pragma mark 严格单例实现
static SWAVAudioPlayer* _instance = nil;
+(instancetype)sharedPlayTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [SWAVAudioPlayer sharedPlayTool] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [SWAVAudioPlayer sharedPlayTool] ;
}
-(void)setAudioUrl:(NSString *)audioUrl
{
    _audioUrl = audioUrl;
    if (!_oldPlayUrl) {
        _timeCount = 0;
    }else{
        if (![_oldPlayUrl isEqualToString:audioUrl]) {
            _timeCount = 0;
        }
    }
    _oldPlayUrl = audioUrl;
}
-(void)setCurrTime:(NSInteger)timer
{
    _timeCount = timer;
    self.player.currentTime = _timeCount;
}
-(void)addTimer
{
//    _timeCount =0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)start
{
    if (self.player) {
        [self.player stop];
        self.player = nil;
        [_timer invalidate];
        _timer = nil;
    }
    NSError *error;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:_audioUrl];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    NSLog(@"error=%@",error.debugDescription);
    self.player.delegate = self;
    if (_needCountDown) {
        [self addTimer];
        self.player.currentTime = _timeCount;
    }else
        self.player.currentTime = 0;
    [self.player prepareToPlay];
    self.player.delegate = self;
    
    self.player.volume = 1;
    [self.player play];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    if (!_isPlayBack) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}
-(void)stop
{
    [_player stop];
    if (_oldBtn) {
        _oldBtn.selected=false;
    }
    self.player = nil;
    [_timer invalidate];
    _timer = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    

//    [_oldBtn.animationView stopAnimating];
    [_timer invalidate];
    _timer = nil;
    _timeCount = 0;
    _oldPlayUrl = nil;
    ! self.playFinishBlock ? : self.playFinishBlock(YES, _timeCount);
}

-(void)updateProgress{
    _timeCount++;
    ! self.playFinishBlock ? : self.playFinishBlock(false,_timeCount);
}
@end
