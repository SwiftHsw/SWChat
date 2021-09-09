//
//  SWGroupServerModel.m
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/6.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWGroupServerModel.h"

@implementation SWGroupServerModel
-(void)setMemberVos:(NSArray *)memberVos{
    _memberVos = memberVos;
    if (_memberVos.count>0 && _memberVos) {
        [self setMemberStr:@""];
    }
    
}

-(void)setMemberStr:(NSString *)memberStr{
    if (_memberVos.count>0 && _memberVos) {
        NSString *newJson = @"";
        for (int i = 0; i<_memberVos.count; i++) {
            NSDictionary *json = _memberVos[i];
            NSString *str = [SWChatManage toJSOStr:json];
            newJson = newJson.length==0?str:[NSString stringWithFormat:@"%@@%@",newJson,str];
        }
        _memberStr = newJson;
    }else{
        _memberStr = memberStr;
    }
    
}

-(void)setSetting:(NSArray *)setting{
    _setting = setting;
    if (_setting.count!=0 && _setting) {
        [self setSettingStr:@""];
    }
    
}
-(void)setSettingStr:(NSString *)settingStr{
    if (_setting.count>0 && _setting) {
        NSString *newJson = @"";
        for (int i = 0; i<_setting.count; i++) {
            NSString *str = _setting[i];
            newJson = newJson.length==0?str:[NSString stringWithFormat:@"%@@%@",newJson,str];
        }
        _settingStr = newJson;
    }else{
        _settingStr = settingStr;
    }
    
    
}
@end
