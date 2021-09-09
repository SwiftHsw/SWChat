//
//  ATSettingCell.h
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/29.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ATSettingCellLineTypeLong,
    ATSettingCellLineTypeShort,
    ATSettingCellLineTypeTopAndShort,
    ATSettingCellLineTypeTopAndLong
} ATSettingCellLineType;

@class SWSettingItem;
@interface SWSettingCell : UITableViewCell
@property (nonatomic, strong) SWSettingItem *item;

+ (instancetype)cellWithTableView:(UITableView *)tableView section:(NSInteger)section row:(NSInteger)row;

@property (nonatomic, assign) ATSettingCellLineType lineType;

@end
