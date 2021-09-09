//
//  SWChatTouchInfoController.m
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/7.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWChatTouchInfoController.h"
#import "SWSettingItem.h"
#import "SWSettingArrowItem.h"
#import "SWSettingGroup.h"
#import "SWSettingSwitchItem.h"

@interface SWChatTouchInfoController ()
<UIActionSheetDelegate>
{
    NSMutableArray *serverMemberArr;
}
@property (nonatomic, strong) UIView *memberviews;
@property (nonatomic, strong) UIButton *logoutBtn;
@property(nonatomic,weak) SWSettingItem *groupName;
@property(nonatomic,weak) SWSettingItem *nickG;
@property(nonatomic,weak) SWSettingItem *noDisItem;
@property(nonatomic,weak) SWSettingItem *remarkItem;
@property(nonatomic,weak) SWSettingItem *toTopItem;
@property(nonatomic,weak) SWSettingItem *owerAcceptItem;
@property (nonatomic, strong) SWHXTool *hxTool;
@property (nonatomic, strong) NSString *userImToken;
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, strong) UIView *tableHeadView;
@end

@implementation SWChatTouchInfoController

ATTableViewHeadFooterLineSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"聊天信息(%zd)",_groupModel.memberList.count];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [self setHeadView];
    [self setupGroup1];
    [self setupGroup2];
    [self setupGroup3];
    [self setupGroup4];
    [self setupGroup5];
    [self setupLogout];
    
    [self updateGroupInfo];
  
    
}
-(void)setHeadView{
    _tableHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    _tableHeadView.backgroundColor =  [UIColor colorWithHexString:@"#f5f5f5"];
    if (_memberviews) {
        [_memberviews removeFromSuperview];
    }
    _memberviews=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    _memberviews.backgroundColor=[UIColor whiteColor];
    
//    [self uploadMemberView];
    [_tableHeadView addSubview:_memberviews];
    //设置为列表头视图
    self.tableView.tableHeaderView= _tableHeadView;
    
}

-(void)setupGroup1
{
    SWSettingItem *groupName = [SWSettingArrowItem itemWithTitle:@"群聊名称" destVcClass:nil];
    self.groupName = groupName;
    SWSettingItem *groupQrcode = [SWSettingArrowItem itemWithTitle:@"群二维码" destVcClass:nil];
     
    SWSettingGroup *group = [[SWSettingGroup alloc] init];
    group.items = @[groupName,groupQrcode];
    [self.data addObject:group];
    
}
-(void)setupGroup2
{
//    WeakSelf(self);
    SWSettingItem *noDisturb = [SWSettingArrowItem itemWithTitle:@"我在本群的昵称" destVcClass:nil];
    self.nickG=noDisturb;
    
    SWSettingItem *remarkName = [SWSettingSwitchItem itemWithTitle:@"显示群成员昵称"];
    remarkName.groupModel = _groupModel;
    _remarkItem = remarkName;
    _remarkItem.Click = ^(BOOL flag, NSString *actionName) {
        if ([actionName isEqualToString:@"显示群成员昵称"]) {
            NSString *str = @"ENABLE";
            if (!flag) {
                str = @"DISABLE";
            }
            [self requestForSetting:str];
//
        }
    };
    
    SWSettingGroup *group = [[SWSettingGroup alloc] init];
    group.items = @[noDisturb,remarkName];
    [self.data addObject:group];
}

-(void)setupGroup3
{
    WeakSelf(self);
    SWSettingItem *noDisturb = [SWSettingSwitchItem itemWithTitle:@"消息免打扰"];
    noDisturb.groupModel = _groupModel;
    _noDisItem = noDisturb;
    noDisturb.Click = ^(BOOL flag, NSString *actionName) {
        if ([actionName isEqualToString:@"消息免打扰"]) {
            weakself.operationAction(actionName, [NSString stringWithFormat:@"%hhd",flag]);
            weakself.noDisItem.groupModel = weakself.groupModel;
        }
    };
    
    SWSettingItem *toTop = [SWSettingSwitchItem itemWithTitle:@"置顶聊天"];
    toTop.groupModel = _groupModel;
    toTop.topName = _groupModel.groupId;
    toTop.Click = ^(BOOL flag, NSString *actionName) {
        if ([actionName isEqualToString:@"置顶聊天"]) {
            if (flag) {
                [SWPlaceTopTool addFromTopARR:weakself.groupModel.groupId];
            }else{
                [SWPlaceTopTool removeFromTopArr:weakself.groupModel.groupId];
            }
        }
    };
    _toTopItem = toTop;
    SWSettingGroup *group = [[SWSettingGroup alloc] init];
    group.items = @[noDisturb,toTop];
    [self.data addObject:group];
}
-(void)setupGroup4
{
    SWSettingItem *messageImage = [SWSettingArrowItem itemWithTitle:@"聊天图片" destVcClass:nil];
    SWSettingItem *findMessage = [SWSettingArrowItem itemWithTitle:@"查找聊天内容" destVcClass:nil];
    SWSettingItem *tip = [SWSettingArrowItem itemWithTitle:@"举报" destVcClass:nil];
    
    SWSettingGroup *group = [[SWSettingGroup alloc] init];
    group.items = @[messageImage,findMessage,tip];
    [self.data addObject:group];
}

-(void)setupGroup5
{
    SWSettingItem *deleteMessage = [SWSettingArrowItem itemWithTitle:@"清空聊天记录" destVcClass:nil];
    SWSettingGroup *group = [[SWSettingGroup alloc] init];
    group.items = @[deleteMessage];
    [self.data addObject:group];
}


- (void)setupLogout
{
    UIView *logoutView = [[UIView alloc] init];
    logoutView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
    UIButton *logoutBtn = [[UIButton alloc] init];
    logoutBtn.layer.masksToBounds = YES;
    logoutBtn.layer.cornerRadius = 5;
    if (!_groupModel) {
        logoutBtn.enabled=NO;
        [logoutBtn setBackgroundColor:[UIColor colorWithHexString:@"#aaaaaa"]];
    }else
    {
        logoutBtn.enabled=YES;
        [logoutBtn setBackgroundColor:SWMainColor];
    }
    if ([_groupModel.owner isEqual:_userImToken])
    {
        [logoutBtn setTitle:@"解散该群" forState:(UIControlStateNormal)];
    }else
        [logoutBtn setTitle:@"删除并退出" forState:(UIControlStateNormal)];
    [logoutBtn addTarget:self action:@selector(logoutClick:) forControlEvents:(UIControlEventTouchUpInside)];
    logoutBtn.frame = CGRectMake(15, 20, SCREEN_WIDTH-30, 50);
    [logoutView addSubview:logoutBtn];
    _logoutBtn = logoutBtn;
    self.tableView.tableFooterView = logoutView;
    ATBtnColorTool(_logoutBtn);
    
}

-(void)updateGroupInfo
{
    //群聊名称
    self.groupName.subTitle = _groupModel.subject;
    self.nickG.subTitle = _groupModel.userGroupName;
    //是否免打扰
    _noDisItem.isNo = !_groupModel.isPushNotificationEnabled?YES:NO;
    //是否显示群成员昵称
    _remarkItem.isNo = _groupModel.isShowMemberName;
    _toTopItem.isNo = [SWPlaceTopTool isPlaceAtTop:_groupModel.groupId];
    [self.tableView reloadData];
}
//是否显示群昵称
-(void)requestForSetting:(NSString *)isOpen{
    
    _operationAction(@"显示群成员昵称", @([isOpen isEqualToString:@"ENABLE"]));
    
//    NSDictionary *parames = [[NSDictionary alloc] initWithObjectsAndKeys:
//                             self.baseConversation.conversationId,@"groupId",
//                             @"SHOW_NICK",@"name",
//                             isOpen,@"isOpen", nil];
//    [[ATRequestTool shareManager] requestWithType:requestForPost hubType:requestForNil withUrlString:getGroupsetting withParaments:parames withSuccessBlock:^(NSDictionary *object) {
//        NSMutableArray *setting = [[NSMutableArray alloc] initWithArray:_serverModel.setting];
//
//        if ([isOpen isEqualToString:@"ENABLE"]) {
//            [setting addObject:@"SHOW_NICK"];
//            _groupModel.isShowMemberName = true;
//        }else{
//            [setting removeObject:@"SHOW_NICK"];
//            _groupModel.isShowMemberName = false;
//        }
//        _serverModel.setting = setting;
//        [self updateGroupInfo];
//        NSString *sql = [NSString stringWithFormat:@"where groupId = %@",self.groupModel.groupId];
//        [[ATFMDBTool shareDatabase] at_deleteTable:@"chatGroupInfo" whereFormat:sql];
//        [[ATFMDBTool shareDatabase] at_insertTable:@"chatGroupInfo" dicOrModel:_serverModel];
//        [[ATFMDBTool shareDatabase] at_updateTable:@"chatGroupList" dicOrModel:self.groupModel whereFormat:sql];
//        _operationAction(@"显示群成员昵称", @([isOpen isEqualToString:@"ENABLE"]));
//    } withFailureBlock:^(NSError *error) {
//        if ([isOpen isEqualToString:@"ENABLE"]) {
//            _groupModel.isShowMemberName = false;
//        }else{
//            _groupModel.isShowMemberName = true;
//        }
//        [self updateGroupInfo];
//    } progress:nil];
}
/**
 退出群聊或解散群聊的点击事件

 @param sender 点击的按钮
 */
-(void)logoutClick:(UIButton *)sender
{
    
    WeakSelf(self);
    
    [[SWHXTool sharedManager] exitChatGroupWithGroupId:_groupModel.groupId isOwner:1];
    
    
    [SWHXTool sharedManager].leverFromGroupBlock = ^(NSDictionary *info, EMError *error) {
        if (!error) {
                NSString *str;
                str=[_groupModel.owner isEqualToString:_userImToken]?@"群聊解散成功":@"退出群聊成功";
                [[EMClient sharedClient].chatManager deleteConversation:weakself.baseConversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError){
                    [SVProgressHUD  showSuccessWithStatus:str];
                    [weakself.navigationController popToRootViewControllerAnimated:YES];
                }];
        }
    };
    
}

#pragma mark - Table view data source
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    WeakSelf(self);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SWSettingGroup *group = self.data[indexPath.section];
    SWSettingItem *item = group.items[indexPath.row];
    if ([item isKindOfClass:[SWSettingArrowItem class]])
    { // 箭头
        SWSettingArrowItem *arrowItem = (SWSettingArrowItem *)item;
        if ([arrowItem.title isEqualToString:@"群聊名称"]) {
            if ([_groupModel.owner isEqualToString:_userImToken])
            {
                //@"修改群名称"
            }
        }else if ([arrowItem.title isEqualToString:@"群二维码"])
        {
            //@"群二维码"
        }else if ([arrowItem.title isEqualToString:@"聊天图片"])
        {
            //@"聊天图片"
            
        }else if ([arrowItem.title isEqualToString:@"查找聊天内容"])
        {
            //@"查找聊天内容"
        }else if ([arrowItem.title isEqualToString:@"清空聊天记录"])
        {
            EMError *error;
            [self.baseConversation deleteAllMessages:&error];
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:@"清空消息成功"];
                
                self.operationAction(@"清空聊天记录", nil);
            }else{
                [SVProgressHUD showErrorWithStatus:@"清空消息失败"];
            }
        }else if ([arrowItem.title isEqualToString:@"我在本群的昵称"])
        {
            //@"我在本群的昵称";
             
        }else if ([arrowItem.title isEqualToString:@"举报"])
        {
            //举报
        }
    }
}

@end
