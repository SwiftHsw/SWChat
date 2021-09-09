//
//  ATSettingArrowItem.h
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/29.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import "SWSettingItem.h"

@interface SWSettingArrowItem : SWSettingItem
/**
 *  点击这行cell需要跳转的控制器
 */
@property (nonatomic, assign) Class destVcClass;




+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title destVcClass:(Class)destVcClass;
+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass;

@end
