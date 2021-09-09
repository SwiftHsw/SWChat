//
//  ATSettingCell.m
//  ATYunPay
//
//  Created by 艾鹏软件有限公司 on 15/12/29.
//  Copyright © 2015年 艾腾软件. All rights reserved.
//

#import "SWSettingCell.h"
#import "SWSettingItem.h"
#import "SWSettingSwitchItem.h"
#import "SWSettingArrowItem.h"
#import "ATFMDBTool.h"
#import "SWPlaceTopTool.h"

@interface SWSettingCell()

@property (nonatomic, weak) UIView *shortLine;
@property (nonatomic, weak) UIView *longLine;
@property (nonatomic, weak) UIView *topLine;

/**
 *  开关
 */
@property (nonatomic, strong) UISwitch *switchView;
@end
@implementation SWSettingCell

{
    UISwitch *_swith;
}

- (UISwitch *)switchView
{
    if (_switchView == nil) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = SWMainColor;
        [_switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (void)switchValueChanged:(UISwitch *)swit
{
    WeakSelf(self);
    if (swit.tag==3) {//群聊消息免打扰
        if (swit.isOn) {
            
            [[EMClient sharedClient].groupManager updatePushServiceForGroup:_item.groupModel.groupId isPushEnabled:NO completion:^(EMGroup *aGroup, EMError *aError) {
                if (aError) {
                    [SVProgressHUD showErrorWithStatus:@"设置失败"];
                    [swit setOn:false];
                }else{
                    weakself.item.Click(swit.on, @"消息免打扰");
                }
            }];
        }else{
            [[EMClient sharedClient].groupManager updatePushServiceForGroup:_item.groupModel.groupId isPushEnabled:YES completion:^(EMGroup *aGroup, EMError *aError) {
                if (aError) {
                    [SVProgressHUD showErrorWithStatus:@"设置失败"];
                    [swit setOn:true];
                }else{
                    weakself.item.Click(swit.on, @"消息免打扰");
                }
            }];
        }
        
    }else if (swit.tag == 10){//是否显示群成员昵称
        weakself.item.Click(swit.on, @"显示群成员昵称");
    }else if (swit.tag == 4){//群聊聊天置顶
        weakself.item.Click(swit.on, @"置顶聊天");
    }
}


+ (instancetype)cellWithTableView:(UITableView *)tableView section:(NSInteger)section row:(NSInteger)row
{
    NSString *ID = [NSString stringWithFormat:@"setting_%zd_%zd",section,row];
    SWSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[SWSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    return cell;
}

- (void)setItem:(SWSettingItem *)item
{
    _item = item;
    
    // 1.设置数据
    [self setupData];
    
    // 2.设置右边的内容
    [self setupRightContent];
}

- (void)setLineType:(ATSettingCellLineType)lineType
{
    _lineType = lineType;
    
    if (lineType == ATSettingCellLineTypeLong) {
        self.shortLine.hidden = YES;
        self.longLine.hidden = NO;
        self.topLine.hidden = YES;
    } else if (lineType == ATSettingCellLineTypeShort) {
        self.shortLine.hidden = NO;
        self.longLine.hidden = YES;
        self.topLine.hidden = YES;
    }
    else if (lineType == ATSettingCellLineTypeTopAndShort) {
        self.shortLine.hidden = NO;
        self.longLine.hidden = YES;
        self.topLine.hidden = NO;
    }
    else if (lineType == ATSettingCellLineTypeTopAndLong) {
        self.shortLine.hidden = YES;
        self.longLine.hidden = NO;
        self.topLine.hidden = NO;
    }
}

/**
 *  设置右边的内容
 */
- (void)setupRightContent
{
    
    
    if ([self.item isKindOfClass:[SWSettingArrowItem class]])
    { // 箭头
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([self.item isKindOfClass:[SWSettingSwitchItem class]])
    { // 开关
        
        if ([self.item.title isEqual:@"手势密码"])
        {
            self.switchView.on =YES;
            self.accessoryView = self.switchView;
            self.switchView.tag = 0;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"开发成员邀请"])
        {
            self.accessoryView = self.switchView;
            self.switchView.tag = 2;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"消息免打扰"])
        {
            if (self.item.groupModel)
            {
                self.accessoryView = self.switchView;
                self.switchView.tag = 3;
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                NSString *isOpen = self.item.groupModel.isPushNotificationEnabled?@"1":@"0";
                if (![isOpen isEqual:@"1"])
                {
                    self.switchView.on = YES;
                }else
                    self.switchView.on = NO;
            }else
            {
                NSString *isOpen = self.item.groupModel.isPushNotificationEnabled?@"1":@"0";
                if ([isOpen isEqual:@"1"])
                {
                    self.switchView.on = YES;
                }else
                    self.switchView.on = NO;
                self.accessoryView = self.switchView;
                self.switchView.tag = 1;
                self.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else if ([self.item.title isEqual:@"置顶聊天"])
        {
            self.accessoryView = self.switchView;
            self.switchView.tag = 4;
            self.switchView.on = [SWPlaceTopTool isPlaceAtTop:self.item.topName];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"保存到通讯录"])
        {
            self.accessoryView = self.switchView;
            self.switchView.tag = 5;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"提示音开关"])
        {
            NSString *isOpen = @"1";
            if ([isOpen isEqual:@"1"])
            {
                self.switchView.on = YES;
            }else
                self.switchView.on = NO;
            self.accessoryView = self.switchView;
            self.switchView.tag = 1;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"消息提示音"])
        {
            NSString *isOpen = @"1";
            if ([isOpen isEqual:@"1"])
            {
                self.switchView.on = YES;
            }else
                self.switchView.on = NO;
            self.accessoryView = self.switchView;
            self.switchView.tag = 1;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"是否自动进群"])
        {
            self.switchView.on = self.item.isNo;
            self.accessoryView = self.switchView;
            self.switchView.tag = 8;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if ([self.item.title isEqual:@"指纹支付"])
        {
            self.switchView.on = YES;
            self.accessoryView = self.switchView;
            self.switchView.tag = 7;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if ([self.item.title isEqual:@"面部识别"])
        {
            self.switchView.on = YES;
            self.accessoryView = self.switchView;
            self.switchView.tag = 7;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if ([self.item.title isEqual:@"群聊邀请确认"])
        {
            if (self.item.groupModel)
            {
                self.accessoryView = self.switchView;
                self.switchView.tag = 9;
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                self.switchView.on = self.item.isNo;
            }
        }else if ([self.item.title isEqual:@"显示群成员昵称"])
        {
            if (self.item.groupModel)
            {
                self.accessoryView = self.switchView;
                self.switchView.tag = 10;
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                self.switchView.on = self.item.isNo;
            }
        }
    }else {
        self.accessoryView = nil;
    }
}

/**
 *  设置数据
 */
- (void)setupData
{
    if (self.item.icon) {
        
        if ([self.item.icon isEqual:@"myinfo_safe_set"])
        {
//            self.imageView.image = [StaticData scaleToSize:[UIImage imageNamed:self.item.icon] size:CGSizeMake(32, 32)];
        }else
            self.imageView.image = [UIImage imageNamed:self.item.icon];
       
        if ([self.item.icon isEqual:@"安全"])
        {
//            self.imageView.image = [StaticData scaleToSize:[UIImage imageNamed:self.item.icon] size:CGSizeMake(32, 32)];
        }else if ([self.item.icon isEqual:@"提示音"])
        {
//            self.imageView.image = [StaticData scaleToSize:[UIImage imageNamed:self.item.icon] size:CGSizeMake(30, 30)];
        }
        
        if ([self.item.icon isEqual:@"安全设置1"]|| [self.item.icon isEqual:@"通用图标1"] ||[self.item.icon isEqual:@"用户帮助1"] ||[self.item.icon isEqual:@"版本说明1"] ||[self.item.icon isEqual:@"关于我们1"] || [self.item.icon isEqual:@"安全设置"] || [self.item.icon isEqual:@"手机"] || [self.item.icon isEqual:@"我的银行卡"] || [self.item.icon isEqual:@"我的二维码"] || [self.item.icon isEqual:@"我的推荐"] || [self.item.icon isEqual:@"子账户新"] || [self.item.icon isEqual:@"我的相册"] || [self.item.icon isEqual:@"我的关注"]) {
            self.imageView.frame=CGRectMake(self.imageView.frame.origin.x, (self.frame.size.height-self.imageView.frame.size.height)/2, self.imageView.frame.size.width, self.imageView.frame.size.height);
        }
    }
    self.textLabel.text = self.item.title;
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.detailTextLabel.text = self.item.subTitle;
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    self.detailTextLabel.textColor = [UIColor grayColor];
    
    if ([self.item.title isEqualToString:@"群聊名称"] || [self.item.title isEqualToString:@"群二维码"] || [self.item.title isEqualToString:@"消息免打扰"] || [self.item.title isEqualToString:@"我在本群的昵称"] || [self.item.title isEqualToString:@"聊天图片"] || [self.item.title isEqualToString:@"查找聊天内容"] || [self.item.title isEqualToString:@"举报"] || [self.item.title isEqualToString:@"清空聊天记录"]|| [self.item.title isEqualToString:@"群聊邀请确认"]|| [self.item.title isEqualToString:@"聊天文件"] || [self.item.title isEqualToString:@"显示群成员昵称"]) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor= [UIColor colorWithHexString:@"f5f5f5"];
        topLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.4);
        [self.contentView addSubview:topLine];
        self.topLine = topLine;
        
        float one = IS_iPhone_X   ? 0.3:0.4;
        // 子控件的创建和初始化
        // 短线
        UIView *shortLine = [[UIView alloc] init];
        shortLine.backgroundColor=[UIColor colorWithHexString:@"f5f5f5"];
        shortLine.frame = CGRectMake(10, self.contentView.height - one, SCREEN_WIDTH - 10, one);
        [self.contentView addSubview:shortLine];
        self.shortLine = shortLine;
        
        // 长线
        UIView *longLine = [[UIView alloc] init];
        longLine.backgroundColor=[UIColor colorWithHexString:@"f5f5f5"];
        longLine.frame = CGRectMake(0, self.contentView.height - one, SCREEN_WIDTH, one);
        [self.contentView addSubview:longLine];
        self.longLine = longLine;
        
    }
    return self;
}


@end
