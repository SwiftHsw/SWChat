//
//  ATSettingItem.h
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/29.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWChatGroupModel.h"
typedef void (^SWSettingItemOption)();
@interface SWSettingItem : NSObject
/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle; // 子标题
@property (nonatomic, strong) SWChatGroupModel *groupModel;

@property (nonatomic, assign) BOOL isNo;
@property (nonatomic, strong) NSString *topName;

/**
 *  点击那个cell需要做什么事情
 */
@property (nonatomic, copy) SWSettingItemOption option;

@property (nonatomic, copy) void (^Click)(BOOL flag,NSString *actionName);

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title;
@end
