//
//  MOKOVoiceRecordView.h
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOKORecordHeaderDefine.h"
@interface MOKORecordView : UIView

- (void)updateUIWithRecordState:(MOKORecordState)state;
- (void)updatePower:(float)power;
- (void)updateWithRemainTime:(float)remainTime;

@end
