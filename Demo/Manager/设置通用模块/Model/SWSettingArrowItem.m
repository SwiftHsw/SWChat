//
//  ATSettingArrowItem.m
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/29.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import "SWSettingArrowItem.h"

@implementation SWSettingArrowItem
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title destVcClass:(Class)destVcClass
{
    SWSettingArrowItem *item = [self itemWithIcon:icon title:title];
    item.destVcClass = destVcClass;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass
{
    return [self itemWithIcon:nil title:title destVcClass:destVcClass];
}


@end
