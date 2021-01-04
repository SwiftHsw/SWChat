//
//  MOKORecorderButton.h
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MOKORecordButton;
typedef void (^RecordTouchDown)         (MOKORecordButton *recordButton);
typedef void (^RecordTouchUpOutside)    (MOKORecordButton *recordButton);
typedef void (^RecordTouchUpInside)     (MOKORecordButton *recordButton);
typedef void (^RecordTouchDragEnter)    (MOKORecordButton *recordButton);
typedef void (^RecordTouchDragInside)   (MOKORecordButton *recordButton);
typedef void (^RecordTouchDragOutside)  (MOKORecordButton *recordButton);
typedef void (^RecordTouchDragExit)     (MOKORecordButton *recordButton);

@interface MOKORecordButton : UIButton
@property (nonatomic, copy) RecordTouchDown         recordTouchDownAction;
@property (nonatomic, copy) RecordTouchUpOutside    recordTouchUpOutsideAction;
@property (nonatomic, copy) RecordTouchUpInside     recordTouchUpInsideAction;
@property (nonatomic, copy) RecordTouchDragEnter    recordTouchDragEnterAction;
@property (nonatomic, copy) RecordTouchDragInside   recordTouchDragInsideAction;
@property (nonatomic, copy) RecordTouchDragOutside  recordTouchDragOutsideAction;
@property (nonatomic, copy) RecordTouchDragExit     recordTouchDragExitAction;

- (void)setButtonStateWithRecording;
- (void)setButtonStateWithNormal;
@end
