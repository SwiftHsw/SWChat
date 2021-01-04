//
//  MOKORecordShowManager.m
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import "MOKORecordShowManager.h"
#import "MOKORecordView.h"
#import "MOKORecordToastContentView.h"

@interface MOKORecordShowManager()
@property (nonatomic, strong) MOKORecordView *voiceRecordView;
@property (nonatomic, strong) MOKORecordTipView *tipView;
@end

@implementation MOKORecordShowManager

- (void)updatePower:(float)power
{
    [self.voiceRecordView updatePower:power];
}

- (void)showRecordCounting:(float)remainTime
{
    [self.voiceRecordView updateWithRemainTime:remainTime];
}

- (void)showToast:(NSString *)message
{
    if (self.tipView.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.tipView];
        [self.tipView showWithMessage:message];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tipView removeFromSuperview];
        });
    }
}

- (void)updateUIWithRecordState:(MOKORecordState)state
{
    if (state == MOKORecordState_Normal) {
        if (self.voiceRecordView.superview) {
            [self.voiceRecordView removeFromSuperview];
        }
        return;
    }
    
    if (self.voiceRecordView.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.voiceRecordView];
    }
    
    [self.voiceRecordView updateUIWithRecordState:state];
}

- (MOKORecordView *)voiceRecordView
{
    if (_voiceRecordView == nil) {
        _voiceRecordView = [MOKORecordView new];
        _voiceRecordView.frame = CGRectMake(0, 0, 150, 150);
        _voiceRecordView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }
    return _voiceRecordView;
}

- (MOKORecordTipView *)tipView
{
    if (_tipView == nil) {
        _tipView = [MOKORecordTipView new];
        _tipView.frame = CGRectMake(0, 0, 150, 150);
        _tipView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }
    return _tipView;
}

@end

