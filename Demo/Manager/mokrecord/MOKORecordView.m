//
//  MOKOVoiceRecordView.m
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import "MOKORecordView.h"
#import "MOKORecordToastContentView.h"
@interface MOKORecordView ()
@property (nonatomic, strong) MOKORecordingView *recodingView;
@property (nonatomic, strong) MOKORecordReleaseToCancelView *releaseToCancelView;
@property (nonatomic, strong) MOKORecordCountingView *countingView;
@property (nonatomic, assign) MOKORecordState currentState;
@end

@implementation MOKORecordView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

    self.recodingView = [[MOKORecordingView alloc] init];
    [self addSubview:self.recodingView];
    self.recodingView.hidden = YES;

    self.releaseToCancelView = [[MOKORecordReleaseToCancelView alloc] init];
    [self addSubview:self.releaseToCancelView];
    self.releaseToCancelView.hidden = YES;
    
    self.countingView = [[MOKORecordCountingView alloc] init];
    [self addSubview:self.countingView];
    self.countingView.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
    self.recodingView.frame = self.bounds;
    self.releaseToCancelView.frame = self.bounds;
    self.countingView.frame = self.bounds;
}

- (void)updatePower:(float)power
{
    if (self.currentState != MOKORecordState_Recording) {
        return;
    }
    [self.recodingView updateWithPower:power];
}

- (void)updateWithRemainTime:(float)remainTime
{
    if (self.currentState != MOKORecordState_RecordCounting || self.releaseToCancelView.hidden == false) {
        return;
    }
    [self.countingView updateWithRemainTime:remainTime];
}

- (void)updateUIWithRecordState:(MOKORecordState)state
{
    self.currentState = state;
    if (state == MOKORecordState_Normal) {
        self.recodingView.hidden = YES;
        self.releaseToCancelView.hidden = YES;
        self.countingView.hidden = YES;
    }
    else if (state == MOKORecordState_Recording)
    {
        self.recodingView.hidden = NO;
        self.releaseToCancelView.hidden = YES;
        self.countingView.hidden = YES;
    }
    else if (state == MOKORecordState_ReleaseToCancel)
    {
        self.recodingView.hidden = YES;
        self.releaseToCancelView.hidden = NO;
        self.countingView.hidden = YES;
    }
    else if (state == MOKORecordState_RecordCounting)
    {
        self.recodingView.hidden = YES;
        self.releaseToCancelView.hidden = YES;
        self.countingView.hidden = NO;
    }
    else if (state == MOKORecordState_RecordTooShort)
    {
        self.recodingView.hidden = YES;
        self.releaseToCancelView.hidden = YES;
        self.countingView.hidden = YES;
    }else if (state == MOKORecordState_RecordToonil)
    {
        self.recodingView.hidden = YES;
        self.releaseToCancelView.hidden = YES;
        self.countingView.hidden = YES;
    }
}
@end
