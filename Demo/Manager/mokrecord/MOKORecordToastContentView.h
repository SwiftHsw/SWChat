//
//  MOKORecordToastContentView.h
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOKORecordToastContentView : UIView

@end

//----------------------------------------//
@interface MOKORecordingView : MOKORecordToastContentView

- (void)updateWithPower:(float)power;

@end

//----------------------------------------//
@interface MOKORecordReleaseToCancelView : MOKORecordToastContentView


@end

//----------------------------------------//

@interface MOKORecordCountingView : MOKORecordToastContentView

- (void)updateWithRemainTime:(float)remainTime;

@end

//----------------------------------------//
@interface MOKORecordTipView : MOKORecordToastContentView

- (void)showWithMessage:(NSString *)msg;

@end


