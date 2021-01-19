//
//  SWChatSingViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatSingViewController.h"

@interface SWChatSingViewController ()
@property (nonatomic, strong) SWFriendInfoModel *friendInfo;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) float nowTimer;

@end

@implementation SWChatSingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.baseConversation = _conversation;
    self.isReceived = false;
    _friendInfo = [[ATFMDBTool shareDatabase] isFriendWithName:self.baseConversation.conversationId];
    self.touchBarView.userInfoModel = _friendInfo;
    if (_friendInfo) {
        self.messageModel.shouName = _friendInfo.remark;
        self.messageModel.headUrl = _friendInfo.headPic;
//        self.isJoin = YES;
    }
    self.title = self.baseConversation.conversationId;
     [self loadData];
}

-(void)loadData
{
    WeakSelf(self);
    [self.conversation loadMessagesStartFromId:nil count:20 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        StrongSelf(self);
        if (!aError) {
            NSMutableArray *timeArr = [[NSMutableArray alloc] init];
            NSMutableArray *addArr = [[NSMutableArray alloc] init];
            for (int i = 0; i<aMessages.count; i++) {
                SWChatTouchModel *model = [[SWChatTouchModel alloc] EMMToChatModel:aMessages[i] timeArr:timeArr]; 
                if ([model.type isEqualToString:@"img"]) {
                    model.isSuccess = @"success";
                }
                model.conversation = self.baseConversation;
                [timeArr addObject:model.timeArr];
                 [addArr addObject:model];
            }
            self.dataArray = addArr;
            [self.tableView reloadData];
            double delayInSeconds = 0.01;
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                   StrongSelf(self);
                   if (self.dataArray.count > 2) {
                       [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                   }
               });
        }
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SWChatManage setTouchUser:self.conversation.conversationId];
    [self timer];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_drafrStr && _drafrStr.length != 0) {
        self.touchBarView.sw_TextView.text = _drafrStr;
    }
}
//当界面开始侧滑返回时，如果当前输入框的值和草稿的值不一样，清空草稿原有的值，赋值成新值
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![self.touchBarView.sw_TextView.text isEqualToString:_drafrStr]) {
        if (self.touchBarView.sw_TextView.text.length!=0) {
            _drafrStr = self.touchBarView.sw_TextView.text;
        }else
            _drafrStr = @"";
    }
    [SWPlaceTopTool updateDraftWithName:self.messageModel.touchUser
                                content:self.touchBarView.sw_TextView.text];
    
    [_conversation markAllMessagesAsRead:nil];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark viewAction
-(void)dealloc
{
    NSLog(@"销毁单聊%@,%@",self.touchBarView.sw_TextView.text,self.messageModel.touchUser);
    [_timer invalidate];
    [SWChatManage setTouchUser:@""];
    [SWChatManage setLabelArr:[NSMutableArray array]];
  
}

-(NSTimer *)timer
{
    if (!_timer) {
        _nowTimer = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTitleState) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}
-(void)updateTitleState
{
    _nowTimer++;
    if (_nowTimer>=20) {
        self.title = [self.friendInfo.remark isEqualToString:@"-"]?self.friendInfo.nickName:self.friendInfo.remark;
        _nowTimer = 0;
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)updateTitleState:(NSString *)state parames:(NSDictionary *)parames
{
    if ([state isEqualToString:@"text_inputAction"]) {
        self.title  = @"对方正在输入中...";
        _nowTimer = 0;
        [_timer setFireDate:[NSDate date]];
    }else if ([state isEqualToString:@"text_outputAction"])
    {
        self.title = self.baseConversation.conversationId;
        _nowTimer = 0;
        [_timer setFireDate:[NSDate distantFuture]];
    }else if ([state isEqualToString:@"withdrawMessage"]){
         //通知对方我撤回了一条消息 “对方撤回了一条消息”
        
    }
}
//收到对象发送的消息，进入的事件
- (void)addMessageToArr:(NSArray *)addArr{
    
    if ([addArr count]) {
         _nowTimer = 0;
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
             if ([model.fromUser isEqualToString:self.messageModel.touchUser] && [model.toUser isEqualToString:[SWChatManage getUserName]]) {
                 [timeArr addObject:model.timeArr];
                 [add addObject:model];
             }
         }
         if (add.count!=0) {
             [self baseAddMessageToData:add];
         }
     }
    
}
 
@end
