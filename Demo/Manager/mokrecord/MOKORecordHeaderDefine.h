//
//  MOKORecordHeaderDefine.h
//  MOKORecorder
//
//  Created by Spring on 2017/4/27.
//  Copyright © 2017年 Spring. All rights reserved.
//

#ifndef MOKORecordHeaderDefine_h
#define MOKORecordHeaderDefine_h

typedef NS_ENUM(NSInteger, MOKORecordState)
{
    MOKORecordState_Normal,          //初始状态
    MOKORecordState_Recording,       //正在录音
    MOKORecordState_ReleaseToCancel, //上滑取消（也在录音状态，UI显示有区别）
    MOKORecordState_RecordCounting,  //最后10s倒计时（也在录音状态，UI显示有区别）
    MOKORecordState_RecordTooShort,  //录音时间太短（录音结束了）
    MOKORecordState_RecordToonil,  //不显示是图
};

#endif
