//
//  SWGroupChatController.m
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/6.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWGroupChatController.h"
#import "ATChatTitleView.h"
#import "ATFMDBTool.h"
#import "SWChatTouchInfoController.h"

#define needCount 20

@interface SWGroupChatController ()

@property (nonatomic, strong) SWChatGroupModel *needModel;

@property (nonatomic, strong) SWGroupServerModel *serverModel;
@property (nonatomic, strong) ATChatTitleView *titleView;
/** name */
@property (nonatomic, assign) BOOL isFirst; // 是否第一次显示页面

@property (nonatomic, assign) BOOL isAddAndReduce; // 是否增删成员

@end

@implementation SWGroupChatController

-(void)loadData
{
    WeakSelf(self);
    self.shouldShowNameDict = [[NSMutableDictionary alloc] init];
    [self.conversation loadMessagesStartFromId:nil count:needCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError) {
            NSMutableArray *timeArr = [[NSMutableArray alloc] init];
            NSMutableArray *addArr = [[NSMutableArray alloc] init];
            for (int i = 0; i<aMessages.count; i++) {
                SWChatTouchModel *model = [[SWChatTouchModel alloc] EMMToChatModel:aMessages[i] timeArr:timeArr];
                model.conversation = self.baseConversation;
                model.isShow = self.isShowMemberName;
                [timeArr addObject:model.timeArr];
                [addArr addObject:model];
                if (model.sendUserInfo) {
                    [self.shouldShowNameDict setObject:[model.sendUserInfo valueForKey:@"remarkName"] forKey:[NSString stringWithFormat:@"%@",[model.sendUserInfo valueForKey:@"loginName"]]];
                }
            }
            weakself.dataArray = addArr;
            [weakself.tableView reloadData]; 
        }
    }];
}
 
//收到对象发送的消息，进入的事件
-(void)addMessageToArr:(NSArray *)addArr
{
    if ([addArr count]) {
        if (!self.shouldShowNameDict) {
            self.shouldShowNameDict = [[NSMutableDictionary alloc] init];
        }
        self.isReceived = true;
        NSMutableArray *timeArr = [[NSMutableArray alloc] init];
        if (self.dataArray.count!=0) {
            SWChatTouchModel *last = [self.dataArray lastObject];
            timeArr = [[NSMutableArray alloc] initWithArray:last.timeArr];
        }
        NSMutableArray *add = [[NSMutableArray alloc] init];
        for (int i = 0; i<addArr.count; i++) {
            SWChatTouchModel *model = [[SWChatTouchModel alloc] EMMToChatModel:addArr[i] timeArr:timeArr];
            model.conversation = self.baseConversation;
                if ([model.messType isEqualToString:@"3"]) {
                    //修改群昵称
                    self.groupModel.subject = [model.messageInfo valueForKey:@"content"];
                    [[ATFMDBTool shareDatabase] updateGroupInfoWithGroup:self.groupModel];
                    [self setupNavTitleView];
                }else if ([model.messType isEqualToString:@"2"]){
                    //群红包记录
                }else if ([model.messType isEqualToString:@"8"]){
                    //群红包记录
                }else{
                    //1.如果是群邀请信息，群主邀请群成员进入，成员sdk内部同意需要一定的时间，这个时间不可控。
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/*延迟执行时间*/ * NSEC_PER_SEC));
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [self loadGroupInfoAction];
                    });
                    
                }
                [timeArr addObject:model.timeArr];
                [add addObject:model];
                NSString *userId = [NSString stringWithFormat:@"%@",[model.sendUserInfo valueForKey:@"loginName"]];
                if ([[self.shouldShowNameDict allKeys] containsObject:userId]) {
                    //草稿
                    NSString *oldName = [self.shouldShowNameDict valueForKey:userId];
                    if (![oldName isEqualToString:[model.sendUserInfo valueForKey:@"remarkName"]]) {
                        [[SWChatCellManager sharedManager].loadArr removeAllObjects];
                        [self.shouldShowNameDict setObject:[model.sendUserInfo valueForKey:@"remarkName"] forKey:userId];
                    }
                }else{
                    [self.shouldShowNameDict setObject:[model.sendUserInfo valueForKey:@"remarkName"] forKey:userId];
                }
        }
        if (add.count!=0) {
            [self baseAddMessageToData:add];
        }
        
    }
}

-(void)updateTitleState:(NSString *)state parames:(NSDictionary *)parames
{
    if ([state isEqualToString:@"withdrawMessage"])
    {
        NSString *messageID = [parames valueForKey:@"messageId"];
        for (int i = 0; i<self.dataArray.count; i++) {
            SWChatTouchModel *model = self.dataArray[i];
            if ([model.messageId isEqualToString:messageID]) {
                [self withdrawWithTouchModel:model index:i];
                NSString *con = [NSString stringWithFormat:@"“%@”撤回了一条信息",[model.sendUserInfo valueForKey:@"remarkName"]];
                [[SWHXTool sharedManager] insertSystemInfo:@"101"
                                                    toUser:self.groupModel.groupId
                                                systemInfo:nil
                                                  sendInfo:[SWChatManage sendInfoWithGroupModel:self.groupModel]
                                                   content:con
                                                  chatType:2
                                                  isInsert:YES];
                return;
            }
        }
    }
}

-(void)shouldUpdateData{
    [self.tableView reloadData];
}
- (void)setupNavTitleView
{
    float pointX = 0;
    if (!IS_iPhone_X) {
        pointX = 69+30;
    }
    if (self.navigationItem.rightBarButtonItem==NULL) {
        [_titleView onlyLabel:self.groupModel.subject count:(int)self.groupModel.occupantsCount isJin:YES];
    }else
        [_titleView onlyLabel:self.groupModel.subject count:(int)self.groupModel.occupantsCount isJin:self.groupModel.isPushNotificationEnabled];
    if (iOS10Later) {

    }else
        _titleView.centerX = SCREEN_WIDTH/2;
    if (IS_iPhone_X) {
        _titleView.centerX = self.navigationItem.titleView.frame.size.width/2;
    }
    self.navigationItem.titleView = _titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.baseConversation = _conversation;
    self.isReceived = false;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"surf_icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(didSingDetail)];
    
    self.isShouldUpdateDraft=false;
    [self loadData];
    _titleView = [[ATChatTitleView alloc] init];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isFirst) {
       [self setupNavTitleView];
    }
    _serverModel = [[ATFMDBTool shareDatabase] getGroupInfoModelWithGroupId:self.conversation.conversationId];
    //记录上次最后的群聊id
    [SWChatManage setTouchUser:self.conversation.conversationId];
    
    [self loadGroupInfoAction];
    
    if (self.isJoin) {
        self.isJoin = YES;
        self.groupModel = [[ATFMDBTool shareDatabase] getGroupModelWithGroupId:self.baseConversation.conversationId];
        [self loadGroupInfoAction];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"surf_icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(didSingDetail)];
    }else{
        NSLog(@"群聊被退出");
        self.navigationItem.rightBarButtonItem = nil;
        self.isJoin = false;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    if (_isFirst) {
        [self setupNavTitleView];
    }
    _isFirst = YES;
    if (_drafrStr && _drafrStr.length != 0 && !self.isShouldUpdateDraft) {
        self.touchBarView.sw_TextView.text = _drafrStr;
    }
    //重置
    self.isShouldUpdateDraft =false;
    [super viewDidAppear:animated];
}

- (void)didSingDetail{
    //跳转群详情
    WeakSelf(self);
    SWChatTouchInfoController *controller = [[SWChatTouchInfoController alloc] init];
    controller.baseConversation = self.baseConversation;
    controller.serverModel = self.serverModel;
    controller.groupModel = self.groupModel;
    [self.navigationController pushViewController:controller animated:YES];
    [controller setOperationAction:^(NSString * _Nonnull actionName, id  _Nonnull object) {
        if ([actionName isEqualToString:@"清空聊天记录"]) {
            [weakself.dataArray removeAllObjects];
            [weakself.tableView reloadData];
        }else if ([actionName isEqualToString:@"显示群成员昵称"])
        {
            self.groupModel.isShowMemberName = !self.isShowMemberName;
            [[ATFMDBTool shareDatabase] updateGroupInfoWithGroup:weakself.groupModel];
            [weakself.tableView reloadData];
            
        }
    }];
}


-(void)groupStateDidChange:(BOOL)isJoin
{
    self.isJoin = isJoin;
    if (!isJoin) {
        NSLog(@"群聊被退出");
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"surf_icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(didSingDetail)];
        _serverModel = [[ATFMDBTool shareDatabase] getGroupInfoModelWithGroupId:self.conversation.conversationId];
        self.isJoin = YES;
        self.groupModel = [[ATFMDBTool shareDatabase] getGroupModelWithGroupId:self.baseConversation.conversationId];
        [self loadGroupInfoAction];
    }
}

-(void)loadGroupInfoAction
{
    WeakSelf(self);
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.conversation.conversationId cursor:0 pageSize:200+500 completion:^(EMCursorResult *aResult, EMError *aError) {
        if (!aError) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:aResult.list];
            if (!weakself.groupModel) {
                weakself.groupModel = [SWChatGroupModel new];
            }
            if (weakself.groupModel.owner) {
                [arr insertObject:weakself.groupModel.owner atIndex:0];
            }
            weakself.groupModel.memberList=arr;
            weakself.groupModel.memberString = [arr componentsJoinedByString:@","];
            weakself.groupModel.occupantsCount = arr.count;
            weakself.groupModel.subject = @"群聊";
            [[ATFMDBTool shareDatabase] updateGroupInfoWithGroup:weakself.groupModel];
            [weakself setupNavTitleView];
            
            //请求后台获取群详情
            NSString *str = [NSString stringWithFormat:@"where groupId is '%@'",weakself.groupModel.groupId];
            NSArray *sqlArr = [[ATFMDBTool shareDatabase] at_lookupTable:@"chatGroupInfo" dicOrModel:[SWGroupServerModel new] whereFormat:str];
            if (sqlArr.count!=0) {
                SWGroupServerModel *old = [sqlArr firstObject];
                weakself.serverModel.memberStr = old.memberStr;
                weakself.serverModel.settingStr = old.settingStr;
                [[ATFMDBTool shareDatabase] at_deleteTable:@"chatGroupInfo" whereFormat:str];
               
            }
            
            weakself.serverModel.groupId = self.conversation.conversationId;
            weakself.serverModel.memberStr = [arr componentsJoinedByString:@","];
            weakself.serverModel.memberVos = arr ;
            [[ATFMDBTool shareDatabase] at_insertTable:@"chatGroupInfo" dicOrModel:weakself.serverModel];
            
           
            
            
        }
    }];
}
#pragma mark 网络请求
-(void)requestForgroupChatinfo
{
  
    
}
@end
