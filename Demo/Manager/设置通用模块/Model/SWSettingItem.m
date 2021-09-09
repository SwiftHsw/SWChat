//
//  ATSettingItem.m
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/29.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import "SWSettingItem.h"

@implementation SWSettingItem
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title
{
    SWSettingItem *item = [[self alloc] init];
    item.icon = icon;
    item.title = title;
    
    return item;
}


+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithIcon:nil title:title];
}
@end
