//
//  SWChatViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatViewController.h"
#import "SWTouchBaseCell.h"
#import "SWChatSingViewController.h"

NSString *const ATAPPDIDONBACKGROUND_NOTIFICATION  = @"appDidOnBackGround" ;


@interface SWChatViewController ()
/*是否发送过*/
@property (nonatomic, assign) BOOL isSend;
/*聊天cell管理器*/
@property (nonatomic, strong) SWChatCellManager *cellManager;

@property (nonatomic, assign) NSInteger isGroup;

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
                model.isShow = weakSelf.isShowMemberName;
                if (!weakSelf.dataArray) {
                    weakSelf.dataArray = [[NSMutableArray alloc] init];
                }
                [weakSelf.dataArray addObject:model];
                
                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                
                if (model.isBoom) {
                  
                                   //模拟微信发送炸弹后震动还有抖动动画
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       for ( SWTouchBaseCell *cell  in weakSelf.tableView.visibleCells) {
                                                 [cell.layer addAnimation:[self stratAnmation] forKey:@"stratAnmation"];
                                           }
                                       CGPoint center = CGPointMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - weakSelf.keyBoardHeight);
                                       SWLog(@">>>>>>>%@",NSStringFromCGPoint(center));
                                       
                                       [SWChatManage starBoomAnmintion:center];
                                   });
                    
                    
                    //找到最后一个cell 传入一个y值
                      model.isBoom = NO;
                   }
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
 
#define ANGLE_TO_RADIAN(angle) ((angle)/180.0 * M_PI)
- (CAKeyframeAnimation *)stratAnmation
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    //拿到动画 key
    anim.keyPath =@"transform.rotation";
    anim.duration= .5;//设置动画时间，如果动画组中动画已经设置过动画属性则不再生效
    // 重复的次数
    anim.repeatCount = 1;
    //设置抖动数值
    anim.values = @[@(ANGLE_TO_RADIAN(0)),@(ANGLE_TO_RADIAN(-17)),@(ANGLE_TO_RADIAN(17)),@(ANGLE_TO_RADIAN(0))];
    // 保持最后的状态
    anim.removedOnCompletion =NO;
    //动画的填充模式
    anim.fillMode =kCAFillModeForwards;
    return anim;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[LVRecordTool sharedRecordTool].player stop];
    [self viewBecomeFirstResponder];
    [self setTouchBarEditable:NO];

}
 
#pragma mark viewAction
-(void)viewDidAppear:(BOOL)animated
{
    WeakSelf(self);
    if (!kStringIsEmpty(self.touchBarView.sw_TextView.text)) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakself.touchBarView.sw_TextView becomeFirstResponder];
        });
    }
    [self setTouchBarEditable:YES];
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    _isReceived = YES;
    _cellManager = [SWChatCellManager sharedManager];
        
    [self setNotification];
   
    [self initHXTool];
  
    [self sw_bangdingSelfUI];
 
   
}
- (void)sw_bangdingSelfUI{
   
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50 - SAFEBOTTOM_HEIGHT - NAVBAR_HEIGHT);
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    self.view.backgroundColor =[UIColor colorWithHexString:@"#f2f2f2"];
    
    self.touchBarView = [[SWTouchBarView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50-SAFEBOTTOM_HEIGHT - NAVBAR_HEIGHT, SCREEN_WIDTH, 50+SAFEBOTTOM_HEIGHT)];
    self.touchBarView.userInfoModel = self.messageModel.friendModel;
    
    WeakSelf(self);
    self.touchBarView = [self.touchBarView initTouchBarView:^(NSString *btnName, NSString *blcokContent, NSString *index, NSMutableArray *moderArr) {
        StrongSelf(self);
         [self touchBarBlock:btnName content:blcokContent inde:index];
    }];
    
    [self.view addSubview:self.touchBarView];
     
    
    if ([self isKindOfClass:[SWChatSingViewController class]]) {
        _touchBarView.isGroup = 1;
        _touchBarView.isFrom = @"来自单聊";
        _isGroup = 1;
    }else{
        _isGroup = 2;
        _touchBarView.isGroup = 2;
        _touchBarView.isFrom = @"来自群聊";
        _touchBarView.groupModel = self.groupModel;
    }
    
} 
-(void)setNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchKeyBoarbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchKeyBoarbDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchKeyBoarbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidOnBackGround:) name:ATAPPDIDONBACKGROUND_NOTIFICATION object:nil];
    
}

- (void)setTouchBarEditable:(BOOL)isEdit{
    self.touchBarView.sw_TextView.editable = isEdit;
    self.touchBarView.imageField.enabled = isEdit;
    self.touchBarView.soundField.enabled = isEdit;
}

-(void)baseAddMessageToData:(NSArray *)addArr
{
    if (!self.dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    [self.dataArray addObjectsFromArray:addArr];
    [self.tableView reloadData];
    WeakSelf(self);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakself.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    
    if (IS_iPhone_X) {
           self.view.transform = CGAffineTransformMakeTranslation(0, -_keyBoardHeight+SAFEBOTTOM_HEIGHT);
    }else{
         self.view.transform = CGAffineTransformMakeTranslation(0, keyboardRect.origin.y-SCREEN_HEIGHT);
    }
           
       self.tableView.frame = CGRectMake(0, _keyBoardHeight-SAFEBOTTOM_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height-_keyBoardHeight-NAVBAR_HEIGHT+SAFEBOTTOM_HEIGHT);
    
       if (self.dataArray.count != 0)
       {
           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
       }
}
-(void)touchKeyBoarbWillHide:(NSNotification *)notification
{
    self.view.transform = CGAffineTransformIdentity;
    self.tableView.frame =  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height - NAVBAR_HEIGHT);
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
         self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height-_keyBoardHeight - NAVBAR_HEIGHT);
     }else
         self.tableView.frame = CGRectMake(0, _keyBoardHeight-SAFEBOTTOM_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-_touchBarView.frame.size.height-_keyBoardHeight -NAVBAR_HEIGHT +SAFEBOTTOM_HEIGHT);
        [self.tableView reloadData];
        if (self.dataArray.count>0) {
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
                                                                    showName:self.isShowMemberName //显示群昵称
                                                                      reSend:false
                                                                       index:indexPath.row
                                                         withReuseIdentifier:cellId
                                                                   tableview:tableView ];
    WeakSelf(self);
    //主要的点击事件回调
    [_cellManager setMenuTouchActionBlock:^(SWChatTouchModel * _Nonnull model, NSString * _Nonnull actionName, NSInteger index, SWChatButton * _Nonnull checkBtn) {
        StrongSelf(self);
        [self menuBlockAction:model name:actionName index:index button:checkBtn];
        
    }];
      
    return baseCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWChatTouchModel *model  = self.dataArray[indexPath.row];
    CGFloat cellHeigh = model.cellHeight;
       float showName = 0;
       BOOL  isShowMemberName =_isShowMemberName;//是否显示群昵称
         if (![model.fromUser isEqualToString:[SWChatManage getUserName]] && isShowMemberName) {
             showName = 20;
         }
         if ([model.type isEqualToString:@"system"]) {
             //系统消息
             return cellHeigh;
         }
         if ([model.type isEqualToString:@"location"] || [model.type isEqualToString:@"envelope"] || [model.type isEqualToString:@"text"] || [model.type isEqualToString:@"voiceAud"] ) {
             //地图 ｜｜ 红包 || 文本  || 语音
             if ([model.type isEqualToString:@"text"] && cellHeigh<49) {
                 return 54+showName; //文本只有一行的情况下
             }
              return [model.showTime isEqualToString:@"0000"]?cellHeigh+5+showName:cellHeigh+35+showName;
         }else if ([model.type isEqualToString:@"img"]){
             //图片
              return [model.showTime isEqualToString:@"0000"]?cellHeigh+showName+15:cellHeigh+30+showName+15;
         }
         return 44+showName;
     
}
 
#pragma mark - 操作区
 
-(void)touchBarBlock:(NSString *)blockName content:(NSString *)content inde:(NSString *)index
{
    if ([blockName isEqualToString:@"发送消息"]) {
        _isSend = true;
        NSDictionary *info;
        //单聊  //群聊
        if (_isGroup == 2) {
            info = [SWChatManage sendInfoWithGroupModel:_groupModel];
        }else{
            info = [SWChatManage sendInfoWithSing:self.touchBarView.userInfoModel];
        }
       
        NSDictionary *contentDic = [[NSDictionary alloc] initWithObjectsAndKeys:content,@"content", nil];
         //IM发送文字
         //在这里执行事件
         [[SWHXTool sharedManager] sendMessageToUser:_messageModel.touchUser
                               messageType:@"text"
                                  chatType:_isGroup
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
                model = [[SWHXTool sharedManager] updateUploadState:@"" content:content touchModel:model conversation:self.baseConversation];
                [self.dataArray replaceObjectAtIndex:i withObject:model];
                [self.tableView reloadData];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                 
                return;
            }
        }
         
    }
}
-(void)sendStateAction:(BOOL)isCancel
{
       if (_isSend && _isReceived ) {
            if (kStringIsEmpty(self.touchBarView.sw_TextView.text) || isCancel) {
               [[SWHXTool sharedManager] sendCMDMessageToUser:_messageModel.touchUser
                                                          content:@"取消输入"
                                                           action:@"text_outputAction"
                                                            group:1
                                                   sendRemarkName:@""];
         }else
           
               [[SWHXTool sharedManager] sendCMDMessageToUser:_messageModel.touchUser
                                                      content:@"输入中"
                                                       action:@"text_inputAction"
                                                        group:1 sendRemarkName:@""];
            
        }
}

-(void)withdrawWithTouchModel:(SWChatTouchModel *)model index:(NSInteger)index
{
    [self menuBlockAction:model name:@"撤回删除" index:index button:nil];
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
        NSString *remark = [self.touchBarView.userInfoModel.remark isEqualToString:@"-"] ? self.touchBarView.userInfoModel.nickName:self.touchBarView.userInfoModel.remark;
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


-(void)setIsJoin:(BOOL)isJoin
{
    _isJoin = isJoin;
    self.touchBarView.isJoin = _isJoin;
//    self.groupModel.isJoin = _isJoin;
}
-(void)setTouchBarHideen:(BOOL)touchBarHideen
{
    _touchBarHideen = touchBarHideen;
    if (_touchBarHideen) {
        [_touchBarView removeFromSuperview];
    }else{
        WeakSelf(self);
        [self.view addSubview:[_touchBarView initTouchBarView:^(NSString *btnName, NSString *blcokContent, NSString *index, NSMutableArray *moderArr) {
            [weakself touchBarBlock:btnName content:blcokContent inde:index];
        }]];
//        [self.view addSubview:self.bottomView];
    }
}

-(void)setGroupModel:(SWChatGroupModel *)groupModel
{
    _groupModel = groupModel;
    _touchBarView.groupModel =_groupModel;
    if (_isShowMemberName != groupModel.isShowMemberName) {
        self.isShowMemberName = _groupModel.isShowMemberName;
        [_cellManager.loadArr removeAllObjects];
    }
}
 
@end
