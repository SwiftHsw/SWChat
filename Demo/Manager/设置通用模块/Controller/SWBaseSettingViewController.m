//
//  ATBaseSettingViewController.m
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/30.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import "SWBaseSettingViewController.h"
#import "SWSettingArrowItem.h"
#import "SWSettingSwitchItem.h"
#import "SWSettingGroup.h"
#import "SWSettingCell.h"
@interface SWBaseSettingViewController ()

@end

@implementation SWBaseSettingViewController

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}


- (NSArray *)data
{
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SWSettingGroup *group = self.data[section];
    return group.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    SWSettingCell *cell = [SWSettingCell cellWithTableView:tableView section:indexPath.section row:indexPath.row];
    
    // 2.给cell传递模型数据
    SWSettingGroup *group = self.data[indexPath.section];
    cell.item = group.items[indexPath.row];
    
    if (indexPath.row == group.items.count - 1) {
        
        if (group.items.count==1) {
            cell.lineType = ATSettingCellLineTypeTopAndLong;
        }
        else
            cell.lineType = ATSettingCellLineTypeLong;
    } else {
        
        if (indexPath.row==0) {
            cell.lineType = ATSettingCellLineTypeTopAndShort;
        }
        else
            cell.lineType = ATSettingCellLineTypeShort;
    }
    
    // 3.返回cell
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.取消选中这行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 2.模型数据
    SWSettingGroup *group = self.data[indexPath.section];
    SWSettingItem *item = group.items[indexPath.row];
    
    if (item.option) { // block有值(点击这个cell,.有特定的操作需要执行)
        item.option();
    } else if ([item isKindOfClass:[SWSettingArrowItem class]]) { // 箭头
        SWSettingArrowItem *arrowItem = (SWSettingArrowItem *)item;
        if (!arrowItem.isNo)
        {
            // 如果没有需要跳转的控制器
            if (arrowItem.destVcClass == nil) return;
            UIViewController *vc = [[arrowItem.destVcClass alloc] init];
            vc.title = arrowItem.title;
            [self.navigationController pushViewController:vc  animated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SWSettingGroup *group = self.data[section];
    return group.header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    SWSettingGroup *group = self.data[section];
    return group.footer;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 14.f;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 14.f;
//}
@end
