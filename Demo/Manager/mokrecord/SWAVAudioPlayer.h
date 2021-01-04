//
//  ATAVAudioPlayer.h
//  ATWeChatProject
//
//  Created by Qiaojun Chen on 2018/7/7.
//  Copyright © 2018年 Qiaojun Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface SWAVAudioPlayer : NSObject

@property (nonatomic , strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSString *audioUrl;

//是否是扬声器模式 默认是扬声器播放
@property (nonatomic, assign) BOOL isPlayBack;

@property (nonatomic, assign) BOOL needCountDown;

@property (nonatomic, strong) UIButton  *oldBtn;


@property (nonatomic, copy) void (^playFinishBlock)(BOOL isFinish,NSInteger timeCount);

+(instancetype)sharedPlayTool;

-(void)setCurrTime:(NSInteger)timer;

-(void)start;

-(void)stop;

@end
