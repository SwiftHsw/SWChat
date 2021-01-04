//
//  SWChatMessageViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatMessageViewController.h"
#import "SWMessageCell.h"
#import "SWSearchBar.h"
#import "SWSearchViewController.h"

@interface SWChatMessageViewController ()
<
   UITableViewDelegate,
   UITableViewDataSource,
   UISearchBarDelegate
>
{
    float keyBoardHeight;
    
}
@property (nonatomic,strong) SWHXTool *hxTool;
@property (nonatomic,strong) SWSearchBar *searchBar;

@end

@implementation SWChatMessageViewController


-(void)updateCount:(NSInteger)count
{
    if (count>0) {
        self.navigationItem.title = [NSString stringWithFormat:@"消息(%zd)",count];
    }else
        self.navigationItem.title =@"消息";
}


#pragma mark - 通知

-(void)setupNotification
{
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageCount:) name:@"updateMessageCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessages:) name:ATDIDRECEIVENEWMESSAGE_NOTIFICATION object:nil];
    
}
 
-(void)didReceiveNewMessages:(NSNotification *)info
{
    //群解散等通知，由APPdelegate 代理发送通知
    [self loadData];
}
- (void)updateMessageCount:(NSNotification *)noti{
    
    SWLog(@"%@",noti.object);
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [SWChatManage setMessageController:self];
     [self setupTable];
     [self setupHXTool];
     [self loadData];
  
}

- (void)setupHXTool
{
    self.navigationItem.title = @"收取中...";
    weakSelf(self);
    _hxTool = [SWHXTool sharedManager];
    _hxTool.OperationBlock = ^(NSDictionary *info, EMError *error) {
        if (!error) {
        }else{
            weakSelf.tableView.tableHeaderView = [weakSelf creatHeadView:1];
        }
    };
}

#pragma mark - 加载消息列表
- (void)loadData{
     self.tableView.tableHeaderView = [self creatHeadView:0];
        self.navigationItem.title = @"收取中";
    NSMutableArray *dataArr = [_hxTool getConversations];
       self.dataArray = [[NSMutableArray alloc] init];
       if (dataArr.count>0) {
           [self.dataArray addObjectsFromArray:dataArr];
       }
     [self updatePlaceAtTopAction:false];
     [self.tableView  reloadData];
}

-(void)updatePlaceAtTopAction:(BOOL)isReload
{
    NSMutableArray *topArr = [SWPlaceTopTool getPlacedAtheTop];
    for (int x = 0; x<topArr.count; x++) {
        NSString *object = topArr[x];
        for (int i = 0; i<self.dataArray.count; i++) {
           SWMessageModel *model = self.dataArray[i];
            if ([object isEqualToString:model.touchUser]) {
                [self.dataArray removeObject:model];
                [self.dataArray insertObject:model atIndex:0];
                model.isTop = true;
            }
        }
    }
    if (isReload) [self.tableView reloadData]; //不用刷新
}
- (void)setupTable{
    self.tableView.rowHeight = 80;
    self.tableView.backgroundColor = [SWKit colorWithHexString:@"#f2f2f2"];
    self.tableView.allowsSelectionDuringEditing = true;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView.userInteractionEnabled = YES;
    self.tableView.delaysContentTouches = NO;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
     self.tableView.dataSource = self;
     self.tableView.tableHeaderView = [self creatHeadView:0];
}

- (UIView *)creatHeadView:(int)index{
     //头部 index == 0 正常 1 失败
    UIView *headView = [UIView new];
    //未登录成功的View
    //未登录成功的View
    UIView *topView;
    if (index == 1) {
        UILabel *errorView = [SWKit labelWithText:@"聊天未登录成功,点击即可重新登录" fontSize:13 textColor:[SWKit colorWithHexString:@"#f76a24"] textAlignment:1 frame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        errorView.backgroundColor = [SWKit colorWithHexString:@"#fff9c6"];
        errorView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [errorView addGestureRecognizer:tapGesturRecognizer];
        [headView addSubview:errorView];
        topView = errorView;
}
    //搜索框
    _searchBar = [SWSearchBar defaultSearchBar];
     _searchBar.delegate = self;
     _searchBar.placeholder = @"搜索";
    _searchBar.frame = CGRectMake(0, topView == nil ? 0 : topView.maxY, SCREEN_WIDTH, [SWSearchBar defaultSearchBarHeight]);
    [headView addSubview:_searchBar];
    headView.height = _searchBar.maxY;
    return  headView;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
   //做一些输入框 搜索的逻辑
    return NO;
}
 
#pragma mark - tableView Delagete
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    weakSelf(self);
    SWMessageModel *model = self.dataArray[indexPath.row];
    UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //删除置顶
        //删除会话内容
        [SWPlaceTopTool removeFromTopArr:model.touchUser];
        [[SWHXTool sharedManager] deleteByConversationID:model.touchUser];
        weakSelf.unCount = weakSelf.unCount-model.messageCount;
        [weakSelf updateCount:weakSelf.unCount];
        [SWChatManage updateMessageCount:weakSelf.unCount];
        [weakSelf.dataArray removeObject:model];
        [weakSelf.tableView reloadData];
    }];
    NSString *name = [SWPlaceTopTool isPlaceAtTop:model.touchUser] ?@"取消置顶":@"置顶";
    UITableViewRowAction *topBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:name  handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([action.title isEqualToString:@"置顶"]) {
            [SWPlaceTopTool addFromTopARR:model.touchUser];
            [weakSelf loadData];
        }else {
            [SWPlaceTopTool removeFromTopArr:model.touchUser];
            [weakSelf loadData];
        }
    }];
    topBtn.backgroundColor = [SWKit colorWithHexString:@"#c7c7cc"];
    return @[deleteBtn,topBtn];
}
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath  {
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    SWMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[SWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    SWMessageModel *model = self.dataArray[indexPath.row];
    BOOL last = false;
    if (indexPath.row == self.dataArray.count-1) {
        last = true;
    }
    [cell setMessageLsitCellData:model top:YES last:last unCount:model.messageCount isVoice:NO isSearch:NO];
    if (model.isTop) {
        [cell setBackgroundColor:[SWKit colorWithHexString:@"#f8f8f8"]];
    }else
        [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
      SWMessageModel *model = self.dataArray[indexPath.row];
       if (model.messageCount!=0) {
           _unCount = _unCount - model.messageCount;
           [self updateCount:_unCount];
           [SWChatManage updateMessageCount:_unCount];
           [model.conversation markAllMessagesAsRead:nil]; //将所有未读消息设置为已读
           model.messageCount = 0;
           [tableView reloadData];
       }
       SWChatSingViewController *controller = [[SWChatSingViewController alloc] init];
           controller.drafrStr = model.draft;
           controller.messageModel = model;
           controller.conversation = model.conversation;
         [self.navigationController pushViewController:controller animated:YES];
    
}
 

#pragma mark === 按钮点击 操作区

//重新登陆
- (void)tapAction:(id)action{
        [[SWHXTool sharedManager] loginWithUsername:[SWChatManage getUserName] isReLogin:true didGoon:true];
}

 

@end
