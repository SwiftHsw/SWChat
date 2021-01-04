//
//  MOKORecordShowManager.h
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOKORecordHeaderDefine.h"
@interface MOKORecordShowManager : NSObject
- (void)updateUIWithRecordState:(MOKORecordState)state;
- (void)showToast:(NSString *)message;
- (void)updatePower:(float)power;
- (void)showRecordCounting:(float)remainTime;
@end
