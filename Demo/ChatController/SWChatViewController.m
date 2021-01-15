//
//  SWChatViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatViewController.h"
#import "SWTouchBaseCell.h"

NSString *const ATAPPDIDONBACKGROUND_NOTIFICATION  = @"appDidOnBackGround" ;


@interface SWChatViewController ()
/*是否发送过*/
@property (nonatomic, assign) BOOL isSend;

@property (nonatomic, strong) SWChatCellManager *cellManager;

@end

@implementation SWChatViewController

-(void)initHXTool
{
    __weak typeof(self) weakSelf = self;
    
    [SWHXTool sharedManager].messageSendBlock = ^(EMMessage *message, NSString *error) {
        if (!error && message) {
            if ([message.to isEqualToString:weakSelf.baseConversation.conversationId]) {
                //保证用户发送的对象和当前聊天的对象一致
                NSMutableArray *timerArr = [[NSMutableArray alloc] init];
                if (weakSelf.dataArray.count!=0) {
                    SWChatTouchModel *model = [weakSelf.dataArray lastObject];
                    timerArr = [[NSMutableArray alloc] initWithArray:model.timeArr];
                }
                SWChatTouchModel *model = [[SWChatTouchModel alloc] EMMToChatModel:message timeArr:timerArr];
                model.conversation = weakSelf.baseConversation;
                if (!weakSelf.dataArray) {
                    weakSelf.dataArray = [[NSMutableArray alloc] init];
                }
                [weakSelf.dataArray addObject:model];
                
                [weakSelf.tableView reloadData];
//                 [weakSelf.tableView scrollToRow:weakSelf.dataArray.count-1 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    };
    
    [SWHXTool sharedManager].messageInsertBlock = ^(EMMessage *message, NSString *error) {
          if (!error && message) {
              
              if (!weakSelf.dataArray) {
                  weakSelf.dataArray = [[NSMutableArray alloc] init];
              }
              NSMutableArray *timerArr = [[NSMutableArray alloc] init];
              if (weakSelf.dataArray.count!=0) {
                  //最后一条时间消息对比
                  SWChatTouchModel *model = [weakSelf.dataArray lastObject];
                  timerArr = [[NSMutableArray alloc] initWithArray:model.timeArr];
              }
              SWChatTouchModel *model = [[SWChatTouchModel alloc] EMMToChatModel:message timeArr:timerArr];
              model.conversation = weakSelf.baseConversation;
              if (model.EMMessage.chatType != EMChatTypeChat) {
                   //群聊
              }else{
                  //单聊
                  [weakSelf.dataArray addObject:model];
                  [weakSelf.tableView reloadData];
//                  [weakSelf.tableView scrollToRow:weakSelf.dataArray.count-1 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                  
                  [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
              }
              
          }
      };
    [SWHXTool sharedManager].messageReSendBlock = ^(SWChatTouchModel *model) {
           for (int i = 0; i<weakSelf.dataArray.count; i++) {
               SWChatTouchModel *old = weakSelf.dataArray[i];
               if ([old.pid isEqualToString:model.pid]) {
                   //交换model
                   [weakSelf.dataArray replaceObjectAtIndex:i withObject:model];
                   return;
               }
           }
       };
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[ATAVAudioPlayer sharedPlayTool].player stop];
    [self viewBecomeFirstResponder];
    self.touchBarView.sw_TextView.editable = NO;
    self.touchBarView.imageField.enabled = NO;
    self.touchBarView.soundField.enabled = NO;
     
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isNavFullBackEnable = YES;
    self.sw_leftNavItemSpacing = 15;
    
}
#pragma mark viewAction
-(void)viewDidAppear:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    if (self.touchBarView.sw_TextView.text.length!=0) {
        double delayInSecondss = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSecondss * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (weakSelf.touchBarView.sw_TextView.text.length!=0) {
                [weakSelf.touchBarView.sw_TextView becomeFirstResponder];
            }
        });
    }
    self.touchBarView.sw_TextView.editable = YES;
    self.touchBarView.imageField.enabled = YES;
    self.touchBarView.soundField.enabled = YES;
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    
    _isReceived = YES;
    _cellManager = [SWChatCellManager sharedManager];
    self.view .backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50 - SafeBottomHeight - NavBarHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor =  [UIColor colorWithHexString:@"#F5F5F5"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor =[UIColor colorWithHexString:@"#f2f2f2"];
    
      _touchBarView = [[SWTouchBarView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50-SafeBottomHeight - NavBarHeight, SCREEN_WIDTH, 50+SafeBottomHeight)];
     [self.view addSubview:[_touchBarView initTouchBarView:^(NSString *btnName, NSString *blcokContent, NSString *index, NSMutableArray *moderArr) {
        
          [self touchBarBlock:btnName content:blcokContent inde:index];
         
     }]];
  
    _touchBarView.userInfoModel = _messageModel.friendModel;
    
     [self setNotification];
    
      [self initHXTool];
}
-(void)setNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchKeyBoarbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchKeyBoarbDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchKeyBoarbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidOnBackGround:) name:ATAPPDIDONBACKGROUND_NOTIFICATION object:nil];
    
}

-(void)baseAddMessageToData:(NSArray *)addArr
{
    if (!self.dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    [self.dataArray addObjectsFromArray:addArr];
    [self.tableView reloadData];
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//     [self.tableView scrollToRow:self.dataArray.count-1 inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    });
}

-(void)setBaseConversation:(EMConversation *)baseConversation
{
    _baseConversation = baseConversation;
    _cellManager.conversation = _baseConversation;
}

#pragma mark 键盘监听
#pragma mark 键盘高度的监听事件
-(void)touchKeyBoarbDidShow:(NSNotification *)notification
{
    if (self.touchBarView.soundField.isFirstResponder) {
//        [self showPreView]; //这里做一个刚拍照的获取 类似微信
    }
    
}

-(void)touchKeyBoarbWillShow:(NSNotification *)notification
{
 
    if (![self isKindOfClass:[[UIView getCurrentVC] class]]) {
        // 其他界面的键盘通知
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyBoardHeight = keyboardRect.size.height;
    if (!_touchBarView.sw_TextView.isFirstResponder && !_touchBarView.soundField.isFirstResponder && !_touchBarView.imageField.isFirstResponder) { 
        return;
    }
    [_touchBarView updataLastView];
    _touchBarView.lastLineView.hidden = NO;
    if (_touchBarView.sw_TextView.isFirstResponder) {
        _touchBarView.lastLineView.hidden = YES;
    }
    
 
    if (Is_Iphone_X) {
           self.view.transform = CGAffineTransformMakeTranslation(0, -_keyBoardHeight+SafeBottomHeight);
    }else{
         self.view.transform = CGAffineTransformMakeTranslation(0, keyboardRect.origin.y-SCREEN_HEIGHT);
    }
           
       self.tableView.frame = CGRectMake(0, _keyBoardHeight-SafeBottomHeight, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height-_keyBoardHeight-NavBarHeight+SafeBottomHeight);
       if (self.dataArray.count != 0)
       {
           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
       }
}
-(void)touchKeyBoarbWillHide:(NSNotification *)notification
{
    self.view.transform = CGAffineTransformIdentity;
    self.tableView.frame =  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height - NavBarHeight);
    _touchBarView.lastLineView.hidden = YES;
    _keyBoardHeight = 0;
    if (self.touchBarView.sw_TextView.isFirstResponder) {
        //说明当前的键盘是输入框的。
        [self sendStateAction:true];
    }
}

#pragma mark - 动态刷新界面坐标
- (void)uploadViewFrame{
    if (_keyBoardHeight==0) {
               self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height-_keyBoardHeight - NavBarHeight);
           }else
                self.tableView.frame = CGRectMake(0, _keyBoardHeight-SafeBottomHeight, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height-_keyBoardHeight -NavBarHeight +SafeBottomHeight);
           [ self.tableView reloadData];
           if (self.dataArray.count>0) {
//                [self.tableView scrollToRow:self.dataArray.count-1 inSection:0 atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
               [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
           }
}


-(void)appDidOnBackGround:(NSNotification *)notification
{
    [self viewBecomeFirstResponder];
    self.view.transform = CGAffineTransformIdentity;
}

-(void)viewBecomeFirstResponder
{
    [_touchBarView.soundField resignFirstResponder];
    [_touchBarView.imageField resignFirstResponder];
    [_touchBarView.sw_TextView resignFirstResponder];
    [self.view becomeFirstResponder];
}
 
#pragma mark 滚动代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"开始滚动");
    [self.view endEditing:YES];
 
}


#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SWChatTouchModel *touchModel  = self.dataArray[indexPath.row];
     
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor randomColor];
    
     NSString *cellId = [NSString stringWithFormat:@"ATTouchBaseCell_%@",touchModel.type];
    if ([touchModel.type isEqualToString:@"text"]) {
        cellId = [NSString stringWithFormat:@"ATTouchBaseCell_%@_%zd",touchModel.type,indexPath.row];
    }
  SWTouchBaseCell *baseCell = (SWTouchBaseCell * )[self.cellManager createMessageCellForMessageModel:touchModel
                                                                   userModle:self.touchBarView.userInfoModel
                                                                    showName:NO //显示群昵称
                                                                      reSend:false
                                                                       index:indexPath.row
                                                         withReuseIdentifier:cellId
                                                                   tableview:tableView ];
 __weak typeof(self) weakSelf = self;
    //主要的点击事件回调
    [_cellManager setMenuTouchActionBlock:^(SWChatTouchModel * _Nonnull model, NSString * _Nonnull actionName, NSInteger index, SWChatButton * _Nonnull checkBtn) {
               
        [weakSelf menuBlockAction:model name:actionName index:index button:checkBtn];
        
    }];
    
    //处理选中背景色问题
//      UIView *backGroundView = [[UIView alloc]init];
//      backGroundView.backgroundColor = [UIColor clearColor];
//      baseCell.selectedBackgroundView = backGroundView;
    
    
    return baseCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWChatTouchModel *model  = self.dataArray[indexPath.row];
    return model.cellFinalHeight;
}
 
#pragma mark - 操作区
 
-(void)touchBarBlock:(NSString *)blockName content:(NSString *)content inde:(NSString *)index
{
    if ([blockName isEqualToString:@"发送消息"]) {
        _isSend = true;
        NSDictionary *info;
        //单聊  //群聊
         info = [SWChatManage sendInfoWithSing:self.touchBarView.userInfoModel];
        NSDictionary *contentDic = [[NSDictionary alloc] initWithObjectsAndKeys:content,@"content", nil];
         //IM发送文字
         //在这里执行事件
         [[SWHXTool sharedManager] sendMessageToUser:_messageModel.touchUser
                               messageType:@"text"
                                  chatType:1
                                  userInfo:info
                                   content:contentDic
                                 messageID:@""
                                  isInsert:false
                            isConversation:false
                                    isJoin:NO];
        [self sendStateAction:true];
    }
    else if ([blockName isEqualToString:@"进入@某人"]){
        self.isShouldUpdateDraft=true;
    }
    else if ([blockName isEqualToString:@"弹出文字键盘"]){
        [self.view resignFirstResponder];
        [_touchBarView.sw_TextView becomeFirstResponder];
    }
    else if ([blockName isEqualToString:@"刷新界面高度"]){
        [self uploadViewFrame];
    }
     else if ([blockName isEqualToString:@"键盘消失"]) {
         [self viewBecomeFirstResponder];
    }
    else if ([blockName isEqualToString:@"发送输入状态消息"])
    {
        //发送当前正在输入中
        if (self.touchBarView.sw_TextView.isFirstResponder) {
            if (_isSend && _isReceived) {
                [self sendStateAction:false];
            }
        }
    }else if ([blockName isEqualToString:@"上传状态"]){
        //修改model是否上传成功
        
        for (int i = 0; i<self.dataArray.count; i++) {
            SWChatTouchModel *model = self.dataArray[i];
            if ([model.pid isEqualToString:index]) {
                NSLog(@"可以更新数据");
                model = [[SWHXTool sharedManager] updateUploadState:@"" content:content touchModel:model conversation:self.baseConversation];
                [self.dataArray replaceObjectAtIndex:i withObject:model];
                [self.tableView reloadData];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
                return;
            }
        }
         
    }
}
-(void)sendStateAction:(BOOL)isCancel
{
        if (_isSend && _isReceived ) {
            if (self.touchBarView.sw_TextView.text.length==0 || isCancel) {
                   [[SWHXTool sharedManager] sendCMDMessageToUser:_messageModel.touchUser content:@"取消输入" action:@"text_outputAction" group:1 sendRemarkName:@""];
            }else
           
               [[SWHXTool sharedManager] sendCMDMessageToUser:_messageModel.touchUser content:@"输入中" action:@"text_inputAction" group:1 sendRemarkName:@""];
            
        }
}
#pragma mark - CellManager 操作区回调

-(void)menuBlockAction:(SWChatTouchModel *)model name:(NSString *)actionName index:(NSInteger)index button:(SWChatButton *)sender
{
    if ([actionName isEqualToString:@"删除"]) {
        [_touchBarView.soundField resignFirstResponder];
           [_touchBarView.imageField resignFirstResponder];
           [_touchBarView.sw_TextView resignFirstResponder];
           [self.view becomeFirstResponder];
           [[GMenuController sharedMenuController] setMenuVisible:NO];
           //模拟从环信im服务器数据库删除
            [self.baseConversation deleteMessageWithId:model.messageId error:nil];
            //本地数组删除
            [self.dataArray removeObject:model];
            //清空这个数组
            [_cellManager.loadArr removeAllObjects];
            [self.tableView  reloadData];
            if (index-1>0) {
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
//              [self.tableView  scrollToRow:index-1 inSection:0 atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
           }
    }else if ([actionName isEqualToString:@"键盘消失"]) {
        [self viewBecomeFirstResponder];
        
    }else if ([actionName isEqualToString:@"刷新红包状态"]){
         NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
              [self.dataArray replaceObjectAtIndex:index withObject:model];//替换model
          [self.tableView reloadRowAtIndexPath:path withRowAnimation:UITableViewRowAnimationNone];
        
    }else if ([actionName isEqualToString:@"撤回"])
    {
        NSDictionary *info = [SWChatManage sendInfoWithSing:self.touchBarView.userInfoModel];
        NSString *remark = [self.touchBarView.userInfoModel.remark isEqualToString:@"-"]?self.touchBarView.userInfoModel.nickName:self.touchBarView.userInfoModel.remark;
        remark =  kStringIsEmpty(remark) ? self.baseConversation.conversationId : remark;
        
        //发送透传消息
        [[SWHXTool sharedManager] sendCMDMessageToUser:_messageModel.touchUser
                                               content:model.messageId
                                                action:@"withdrawMessage"
                                                 group:1
                                        sendRemarkName:remark];
        //删除撤回的数据
         [self.baseConversation deleteMessageWithId:model.messageId error:nil];
         [self.dataArray removeObject:model];
         [[SWChatCellManager sharedManager].loadArr removeAllObjects];
       [self.tableView reloadData];
       if (index-1>0) {
           
           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
           
           
//           [self.tableView scrollToRow:index-1 inSection:0 atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
       }
        
       //插入一条系统消息
        [[SWHXTool sharedManager] insertSystemInfo:@"101"
                                            toUser:[SWChatManage GetTouchUser]
                                        systemInfo:nil
                                          sendInfo:info
                                           content:@"你撤回了一条信息"
                                          chatType:1
                                          isInsert:YES];
    }
    
    
}
@end
