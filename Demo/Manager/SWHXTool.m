//
//  SWHXTool.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWHXTool.h"
#import "SWFriendSortManager.h"
#import "SWChatMessageViewController.h"

@implementation SWHXTool


CREATE_SHARED_MANAGER(SWHXTool)


-(void)registerWithUsername:(NSString *)name isReLogin:(BOOL)isReLogin didGoon:(BOOL)goon
{
    EMError *error = [[EMClient sharedClient] registerWithUsername:name password:KIMLOGINPASSWORD];
    if (error==nil) {
        NSLog(@"注册成功");
        [self loginWithUsername:name isReLogin:isReLogin didGoon:goon];
    }else
    {
        NSLog(@"注册失败");
        if ([error.errorDescription isEqualToString:@"User already exist"]) {
//            [self loginWithUsername:name isReLogin:isReLogin didGoon:goon];
            [SVProgressHUD showErrorWithStatus:@"用户名已经存在"];
        }else{
            if (!isReLogin) {
                [SVProgressHUD showErrorWithStatus:@"注册失败"];
            }
        }
    }
}


-(void)loginWithUsername:(NSString *)name isReLogin:(BOOL)isReLogin didGoon:(BOOL)goon
{
    [SVProgressHUD show];
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (!isAutoLogin) {
        [self logout];
        [[EMClient sharedClient] loginWithUsername:name password:KIMLOGINPASSWORD completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                [SVProgressHUD dismiss];
                NSLog(@"环信登录成功");
                if (goon) {
                    //加载数据
                    [self didLoginSuccess];
                }else{
                    if (self.OperationBlock) {
                        self.OperationBlock([NSDictionary dictionary], aError);
                    }
                }

            }
            else if ([aError.errorDescription isEqualToString:@"User dosn't exist"])
            {
                 [SVProgressHUD showErrorWithStatus:@"登陆失败"];
                [self registerWithUsername:name isReLogin:isReLogin didGoon:goon];
            }else if ([aError.errorDescription isEqualToString:@"Username or password is wrong"])
            {
                [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
            }else{
                if (self.OperationBlock) {
                     self.OperationBlock([NSDictionary dictionary], aError);
                }
            }
        }];
    }else{
        SWLog(@"自动登录，直接获取数据");
        [[SWHXTool sharedManager] getFriendList];
       
    }
    
}

-(void)logout
{
    EMError *error = [[EMClient sharedClient] logout:YES];
    if (!error) {
        NSLog(@"退出成功");
    }
    
}

-(void)didLoginSuccess
{
    [self getConversations];
     //获取好友列表
    [self getFriendList];
//    //获取群列表
//    [self getChatGroupList];
    if (self.OperationBlock) {
        self.OperationBlock(nil, nil);
    }
   
}
#pragma mark -
#pragma mark - 获取会话列表
-(NSMutableArray *)getConversations
{
    //从环信获取
    NSArray* arr = [[[EMClient sharedClient].chatManager getAllConversations] sortedArrayUsingComparator:
                    ^(EMConversation *obj1, EMConversation* obj2){
                        EMMessage *message1 = [obj1 latestMessage];
                        EMMessage *message2 = [obj2 latestMessage];
                        if(message1.timestamp > message2.timestamp) {
                            return(NSComparisonResult)NSOrderedAscending;
                        }else {
                            return(NSComparisonResult)NSOrderedDescending;
                        }
                    }];
    NSMutableArray *messageArr = [[NSMutableArray alloc] init];
    NSInteger unCount = 0;
    for (int i = 0; i<arr.count; i++) {
        EMConversation *conver = arr[i];
        EMMessage *message = conver.latestMessage;
//        BOOL canAdd = true;
        SWMessageModel *model = [SWMessageModel new];
        model.touchUser = conver.conversationId;
//        ATChatGroupModel *groupModel;
        SWFriendInfoModel *infoModel;
        model.messageID = message.messageId;
        model.isGroupChat =message.chatType==EMChatTypeChat ?false:true;
  
        infoModel = [[ATFMDBTool shareDatabase] isFriendWithName:conver.conversationId];
        if (infoModel == nil ) {
            //强制匹配吧，数据库这边没做处理，没有匹配网络
            infoModel = [SWFriendInfoModel new];
            infoModel.userId = conver.conversationId;
            infoModel.remark = conver.conversationId;
              
        }
        model.friendModel = infoModel;
        if ([model.touchUser isEqualToString:[SWChatManage GetTouchUser]]) {
            model.messageCount = 0;
        }else{
            //对方发送的计入未读数据
            model.messageCount = conver.unreadMessagesCount;
        }
        model.lastTime = [SWChatManage longLongToStr:message.timestamp dateFormat:@"HH:mm"];
        model.lastContent = [self textContent:message];
        model.conversation = conver;
        NSDictionary *last = [SWChatManage JsonToDict:model.lastContent];
        if ([last allKeys].count !=0) {
            model.messageType  = [last valueForKey:@"type"];
            NSDictionary *data = [last valueForKey:@"data"];
            NSDictionary *userInfo = [last valueForKey:@"sendUser"];
            NSString *send = [userInfo valueForKey:@"loginName"];
            model.isSend = [send isEqualToString:[SWChatManage getUserName]];
            unCount = unCount + model.messageCount;
            if (model.isGroupChat) {
                //群聊暂时不实现
//                model.groupModel = groupModel;
//                model.shouName = [userInfo valueForKey:@"groupName"];
//                if (model.groupModel) {
//                    model.shouName = model.groupModel.subject;
//                    if (!model.groupModel.isPushNotificationEnabled) {
//                        unCount = unCount - model.messageCount;
//                    }
//                }else{
//                    groupModel = [ATChatGroupModel new];
//                    groupModel.groupId = [userInfo valueForKey:@"groupId"];
//                    unCount = unCount - model.messageCount;
//                    if (!model.shouName) {
//                        model.shouName = @"群聊";
//                    }
//                }
//                model.headUrl=groupImage(groupModel.groupId);
            }else{
                if (model.friendModel) {//是好友
                    NSString *remark = infoModel.remark;
                    if ([remark isEqualToString:@"-"]) {
                        remark = infoModel.nickName;
                    }
                    model.shouName= remark;
                    model.headUrl = infoModel.headPic;
                }else{//不是好友
                    if (model.isSend) {
                        model.shouName= [userInfo valueForKey:@"singleReceiveRemark"];
                        model.headUrl = [userInfo valueForKey:@"singleReceiveHeadPic"];
                    }else{
                        model.shouName= [userInfo valueForKey:@"remarkName"];
                        model.headUrl = [userInfo valueForKey:@"headUrl"];
                    }
                }
            }
             
            if ([model.messageType isEqualToString:@"text"]) {
                
                NSDictionary *sendInfo = [last valueForKey:@"sendUser"];
                if ([[data allKeys] containsObject:@"atUser"]) {
                    if (message.isRead) {
                        model.shouContent = [NSString stringWithFormat:@"%@:%@",[sendInfo valueForKey:@"remarkName"],[data valueForKey:@"content"]];
                    }else{
                        NSDictionary *atUser = [data valueForKey:@"atUser"];
                        NSString *loginName = [atUser valueForKey:@"loginName"];
                        if ([loginName containsString:[SWChatManage getUserName]] || [loginName isEqualToString:@"ALL"]) {
//                            model.showAttrContent = [ATGeneralFuncUtil labelWithString:@"有人@我" oldStr:[NSString stringWithFormat:@"%@:%@",[sendInfo valueForKey:@"remarkName"],[data valueForKey:@"content"]]];
                        }else
                            model.shouContent = [NSString stringWithFormat:@"%@:%@",[sendInfo valueForKey:@"remarkName"],[data valueForKey:@"content"]];
                    }
                    
                }else
                {
                    if (message.chatType == EMChatTypeChat) {
                        model.shouContent = [data valueForKey:@"content"];
                    }else{
                        model.shouContent = [NSString stringWithFormat:@"%@:%@",[sendInfo valueForKey:@"remarkName"],[data valueForKey:@"content"]];
                    }
                }
            }else if ([model.messageType isEqualToString:@"voiceAud"])
            {
                model.shouContent = @"[语音]";
            }
            else if ([model.messageType isEqualToString:@"location"])
            {
                model.shouContent = @"[位置]";
            }else if ([model.messageType isEqualToString:@"envelope"])
            {
                if (message.chatType == EMChatTypeChat) {
                    model.shouContent = [NSString stringWithFormat:@"[收到红包]:%@",@"恭喜发财"];
                }else{
                   
                }
 
            }else if ([model.messageType isEqualToString:@"imgGif"])
            {
                model.shouContent = [data valueForKey:@"mean"];
            }else if ([model.messageType isEqualToString:@"groupInvitation"])
            {
                model.shouContent = @"[群邀请]";
            }else if ([model.messageType isEqualToString:@"system"])
            {
                /**
                 1. 1为群系统消息，删除和加入消息
                 2. 2为群系统消息，红包消息--类是xxxxx领取了xxxx的红包
                 3. 3为群系统消息，修改群名称--类是xxxxxx修改了群名
                 4. 4为群系统消息，禁言或者解除禁言
                 5. 5为单聊系统消息，领取红包详情
                 6. 100为本地的被删除好友，好友验证消息
                 7. 101为消息撤回
                 */
                NSString *loginName = [userInfo valueForKey:@"loginName"];
                NSString *content = [data valueForKey:@"content"];
                NSString *systemType = [data valueForKey:@"systemType"];
                if ([systemType isEqualToString:@"3"]) {
//                    model.shouContent = [NSString stringWithFormat:@"群主修改群名为\"%@\"",content];
//                    groupModel.subject = [userInfo valueForKey:@"groupName"];
//                    [[ATFMDBTool shareDatabase] updateGroupInfoWithGroup:groupModel];
                }else if ([systemType isEqualToString:@"101"])
                {
                    //“%@”
                    if ([content containsString:@"“”"] || [content containsString:@"“(null)”"]) {
                        NSString *remarkName = [userInfo valueForKey:@"remarkName"];
                        content = [NSString stringWithFormat:@"“%@”撤回了一条消息",remarkName];
                        NSString *loginName = [userInfo valueForKey:@"loginName"];
                        if ([loginName isEqualToString:[SWChatManage getUserName]]) {
                            content = @"你撤回了一条消息";
                        }
                    }
                    model.shouContent = content;
                }else if ([systemType isEqualToString:@"1"])
                {
                    if ([loginName isEqualToString:[SWChatManage getUserName]]) {
                        model.shouContent = content;
                    }else{
                        NSString *str = [NSString stringWithFormat:@"\"%@\"",[userInfo valueForKey:@"remarkName"]];
                        model.shouContent = [content stringByReplacingOccurrencesOfString:@"你" withString:str];
                    }
                }else if ([systemType isEqualToString:@"100"])
                {
                    model.shouContent = content;
                }
            }
            [messageArr addObject:model];
        }
        
        
    }
    [SWChatManage updateMessageCount:unCount];
    [[SWChatManage messageControll]updateCount:unCount];
   
    return messageArr;
}

#pragma mark -
#pragma mark - 获取好友列表
-(void)getFriendList
{
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        NSLog(@"获取好友列表成功%@ %@",aList,aError.debugDescription);
        __weak typeof(self) weakSelf = self;
        
        NSMutableArray *friendList = [[NSMutableArray alloc] initWithArray:aList];
        if (aError || aList.count==0) {
            //如果从服务端请求好友发生错误，那么从环信本地获取好友，如果没有则好友为空
            friendList = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
        }
         if (aList.count==0 && !aError)  {
            if (weakSelf.getDataBlock)weakSelf.getDataBlock(aList,nil, nil);
            [[ATFMDBTool shareDatabase] at_deleteAllDataFromTable:@"friendList"];
             //发送外部通知，列表发生该表
            [SWChatManage setFriendArr:[NSMutableDictionary dictionary]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:ATFRIENDLISTDIDCHANGE_NOTIFICATION object:nil];
        }else{
            
            NSMutableArray *addArr = [[NSMutableArray alloc] init];
            NSString *requestId = @"";
            for (int i = 0; i<aList.count; i++) {
                SWFriendInfoModel *model = [SWFriendInfoModel new];
                model.nickName = aList[i];
                model.remark = aList[i];
                model.isSystem = false;
                model.isFriend = true;
                [addArr addObject:model];
                requestId = requestId.length==0?model.nickName:[NSString stringWithFormat:@"%@,%@",requestId,model.nickName];
            }
            
            dispatch_async(dispatch_queue_create(0, 0), ^{
                NSMutableArray *index = [SWFriendSortManager IndexWithArray:addArr Key:@"remark"];
                NSMutableArray *letter = [SWFriendSortManager sortObjectArray:addArr Key:@"remark"];
                
                SWFriendInfoModel *model = [SWFriendInfoModel new];
                model.isSystem = true;
                model.nickName = [NSString stringWithFormat:@"%zd位好友",addArr.count];
                model.remark = [NSString stringWithFormat:@"%zd位好友",addArr.count];
                NSMutableArray *addArrr = [letter lastObject];
                [letter removeLastObject];
                [addArrr addObject:model];
                if (addArr.count != 0) {
                    [letter addObject:addArrr];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                    [info setObject:letter forKey:@"letter"];
                    [info setObject:index forKey:@"index"];
                    [SWChatManage setFriendArr:info];
                    if (weakSelf.getDataBlock) weakSelf.getDataBlock(letter, index, nil);
                    
                    if (requestId.length!=0) {
                        //走网络请求备注名称
//                        [self requestForfrienddetail:requestId];
                    }
                    
                });
            });
        }
    }];
}

-(void)accapectAddFriendPost:(NSString *)accapectLoginName
{
    [[EMClient sharedClient].contactManager approveFriendRequestFromUser:accapectLoginName
                                                              completion:^(NSString *aUsername, EMError *aError)
     {
         if (!aError)
         {
//             NSDictionary *parames = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                      accapectLoginName,@"imTokens", nil];
             //模拟后台返回的用户数据
                 SWFriendInfoModel *infoModel = [SWFriendInfoModel new];
             infoModel.nickName = aUsername;
             infoModel.remark = aUsername;
                 infoModel.userId = @"";
                 infoModel.headPic = @"";
                 infoModel.imToken = aUsername;
                 infoModel.isFriend = YES;
                 [[ATFMDBTool shareDatabase] at_insertTable:@"friendList" dicOrModelArray:@[infoModel]];
                 [SWChatManage updateFriendArr];
                  
                //加成功后直接发送一条数据给对方
                 NSDictionary *info = [SWChatManage sendInfoWithSing:infoModel];
                 NSDictionary *content = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"我是%@",[SWChatManage getUserName]],@"content", nil];
             
                 [[SWHXTool sharedManager] sendMessageToUser:infoModel.imToken
                                                 messageType:@"text"
                                                    chatType:1
                                                    userInfo:info
                                                     content:content
                                                   messageID:@""
                                                    isInsert:false
                                              isConversation:false
                                                      isJoin:YES];
   
         }
     }];
}
-(void)sendFriendPost:(NSString *)toUser post:(NSString *)post isShow:(BOOL)isShow
{
    if (post.length==0 || !post) {
        post = @"一起加个好友吧!";
    }
    [[EMClient sharedClient].contactManager addContact:toUser
                                               message:post
                                            completion:^(NSString *aUsername, EMError *aError)
     {
         if (!aError) {
             if (isShow) {
                 [SVProgressHUD showSuccessWithStatus:@"请求发送成功"];
                 if (_OperationBlock) {
                     _OperationBlock(nil,nil);
                 }
             }
         }else
         {
             if (isShow) {
                 [SVProgressHUD showErrorWithStatus:@"请求发送失败"];
             }
             
         }
     }];
}

-(NSString *)textContent:(EMMessage *)message
{
    EMMessageBody *msgBody = message.body;
    if (msgBody.type == EMMessageBodyTypeText) {
        EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
        return textBody.text;
    }
    if (msgBody.type == EMMessageBodyTypeVoice) {
        //没办法的办法，因为构造了消息，用的却是环信的，demo 只能这样吧～
        
        NSDictionary *  info = [SWChatManage sendInfoWithSing:nil];
        NSDictionary * data = @{@"state":@"1"};
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  data,@"data",
                                    @"id",@"id",
                                    @"voiceAud",@"type",
                                    info,@"sendUser",nil];
        return [jsonDict mj_JSONString];
    }
    return @"";
}
//删除会话
-(void)deleteByConversationID:(NSString *)toUser
{
    [[EMClient sharedClient].chatManager deleteConversation:toUser isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError){
        //code
    }];
}

#pragma mark - 进入聊天
-(void)gotoSingChatControllerWithLoginName:(NSString *)toUser
{
 
    EMConversation *conver = [[EMClient sharedClient].chatManager
                              getConversation:toUser
                              type:EMConversationTypeChat
                              createIfNotExist:YES];
    
    [conver markAllMessagesAsRead:nil];
     
    SWLog(@"剩余多少未读==%d",conver.unreadMessagesCount);
    
    SWMessageModel *model = [SWMessageModel new];
    model.touchUser = toUser;
    NSDictionary *draft = [SWPlaceTopTool getAllDraft];
    NSString *con = [draft valueForKey:model.touchUser];
     model.draft = (con && con.length!=0) ? con : @"";
    
    SWChatSingViewController *controller = [[SWChatSingViewController alloc] init];
    controller.messageModel = model;
    controller.drafrStr = model.draft;
    controller.conversation = conver;
    [[UIView getCurrentVC].navigationController pushViewController:controller animated:YES];
}

- (void)sendMessageToUser:(NSString *)toUser messageType:(NSString *)messtype chatType:(NSInteger)chatType userInfo:(NSDictionary *)info content:(NSDictionary *)content messageID:(NSString *)messageID isInsert:(BOOL)isInsert isConversation:(BOOL)isConversation isJoin:(BOOL)isJoin{
    
      if ([SWPlaceTopTool isPlaceAtTop:toUser]) {
           [SWPlaceTopTool removeFromTopArr:toUser];
           [SWPlaceTopTool addFromTopARR:toUser];
       }
    
     UIViewController *nowController = [UIView getCurrentVC];
    if (!isJoin) {
        if (chatType == 1) { //这边判断是否群聊 或者单聊 再判断是否为本地好友
              isJoin = [[ATFMDBTool shareDatabase]isFriendWithName:toUser];
        }
    }
    if (!isJoin && [messtype isEqualToString:@"system"]) {
        NSString *systemContent = [NSString stringWithFormat:@"%@开启了朋友验证，你还不是他(她)朋友。请先发送朋友验证请求，对方验证通过后，才能聊天。发送朋友验证。",[info valueForKey:@"singleReceiveRemark"]];
        if (chatType == 2) {
                   systemContent = @"您已退出群聊，无法发言。";
         }
        
         //发送此systemContent 消息
        if (chatType == 1) {
              [self insertSystemInfo:@"100"
                              toUser:[SWChatManage GetTouchUser]
                          systemInfo:nil
                            sendInfo:info
                             content:systemContent
                            chatType:1
                            isInsert:YES];
        }
        
        return;
    }
    
    NSString *pidStr = messageID.length==0?[NSString getRandomString]:messageID;
    //群聊另外判断
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                content,@"data",
                                pidStr,@"id",
                                messtype,@"type",
                                info,@"sendUser",nil];
      NSString *jsonStr = [SWChatManage toJSOStr:jsonDict];
   //是否静默推送。NO会正常推送。 YES是静默消息
         NSDictionary *exitDict = @{@"em_apns_ext":@{@"em_push_title":@"收到一条聊天信息"},@"em_ignore_notification":@NO};
         
         if ([messtype isEqualToString:@"system"]) {
             exitDict = @{@"em_apns_ext":@{@"em_push_title":@"收到一条聊天信息"},@"em_ignore_notification":@YES};

         }
    EMTextMessageBody *body = [[EMTextMessageBody alloc]initWithText:jsonStr];
    EMMessage *message;
    NSString *imToken = [SWChatManage getUserName];
    //正序 倒序
   message = [[EMMessage alloc] initWithConversationID:toUser from:imToken to:toUser body:body ext:nil];
   message.ext = exitDict;
   message.chatType = EMChatTypeChat;
    
    if (isInsert && isConversation) {
        //图片 位置 等
           //插入并且需要更新会话
           if (chatType==1) {
               EMConversation *conversation =  [[EMClient sharedClient].chatManager getConversation:message.conversationId type:EMConversationTypeChat createIfNotExist:YES];
               EMError *error;
               [conversation insertMessage:message error:&error];
               //图片上传的逻辑，提示外部图片上传，成功后更新此条会话内容
               if (self.sendImageInsertBlock) {
                   self.sendImageInsertBlock(message, error.errorDescription);
               }
               //插入消息
               if (self.messageInsertBlock) {
                   self.messageInsertBlock(message, error.errorDescription);
               }
           }
    }else if (isInsert && !isConversation)
    {
        //插入但是不需要更新会话
    }else{
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
              
          } completion:^(EMMessage *message, EMError *error) {
              if (!error)
              {
                  if (self.messageSendBlock) {
                      self.messageSendBlock(message, nil);
                  }
                  
                  //更新会话
                  if ([SWChatManage messageControll] !=nil) {
                       [[SWChatManage messageControll] loadData];
                  }
                   
              }else
                  [SVProgressHUD showErrorWithStatus:error.errorDescription];
          }];
    }
    
}

- (void)sendTouchVoiceToUser:(NSString *)toUser localPath:(NSString *)alocalPath displayName:(NSString *)aDisplayName duration:(int)duration{
    
    
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc]initWithLocalPath:alocalPath displayName:aDisplayName];
    body.duration = duration;
    NSString *form = [SWChatManage getUserName];//[[EMClient sharedClient]currentUsername];
    EMMessage *message = [[EMMessage alloc]initWithConversationID:toUser
                                                             from:form
                                                               to:toUser
                                                             body:body
                                                              ext:nil];
    
    message.chatType = EMChatTypeChat;//单聊
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
              
          } completion:^(EMMessage *message, EMError *error) {
              if (!error)
              {
                  if (self.messageSendBlock) {
                      self.messageSendBlock(message, nil);
                  }                   //更新会话
                  if ([SWChatManage messageControll] !=nil) {
                       [[SWChatManage messageControll] loadData];
                  }
              }else
                  [SVProgressHUD showErrorWithStatus:error.errorDescription];
          }];
    
    
    
    
}
-(SWChatTouchModel *)updateUploadState:(NSString *)state content:(NSString *)content touchModel:(SWChatTouchModel *)model conversation:(EMConversation *)conver
{
    EMMessage *mee = model.EMMessage;
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:[SWChatManage JsonToDict:[self textContent:mee]]];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[info valueForKey:@"data"]];
    
    if (content.length!=0) {
        model.content = content;
        model.isSuccess = @"success";
        if ([model.type isEqualToString:@"voiceAud"]){
            model.content = @"[语音]";
        }
        [data setValue:content forKey:@"content"];
    }else{
        if (state.length!=0) {
            model.isSuccess = state;
        }else
            model.isSuccess = @"failure";
    }
    [data setValue:model.isSuccess forKey:@"state"];
    [info setValue:data forKey:@"data"];
    NSString *bodyStr = [SWChatManage toJSOStr:info];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:bodyStr];
    mee.body =body;
    [conver updateMessageChange:mee error:nil];
    if (content.length!=0) {
        [self sendMessageToUser:mee touchModel:model];
    }
    return model;
}

#pragma mark - 重新发送
-(void)sendMessageToUser:(EMMessage *)message touchModel:(SWChatTouchModel *)model
{
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        if (!error)
        {
            NSLog(@"再次发送消息成功");
            model.messageId = message.messageId;
            model.EMMessage = message;
            UIViewController *nowController = [UIView getCurrentVC];
            if ([nowController isKindOfClass:[SWChatMessageViewController class]]) {
                SWChatMessageViewController *messageController = (SWChatMessageViewController *)nowController;
                [messageController loadData];
            }
        }else
        {
            [SVProgressHUD showErrorWithStatus:error.errorDescription];
            NSLog(@"消息发送失败 %@ %@",message.to,message.from);
        }
        if (_messageReSendBlock) {
            _messageReSendBlock(model);
        }
    }];
}
-(void)sendCMDMessageToUser:(NSString *)toUser content:(NSString *)content action:(NSString *)action group:(NSInteger)group sendRemarkName:(NSString *)sendRemarkName
{
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:action];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:nil];
    if (group ==1) {
        message.chatType = EMChatTypeChat;// 设置为单聊消息
    }else
        message.chatType = EMChatTypeGroupChat;// 设置为单聊消息
    if (content) {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:content,@"messageId",
                              sendRemarkName,@"sendRemarkName",nil];
        NSString *jsonStr = [SWChatManage toJSOStr:info];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:jsonStr,@"withDrawMessageId", nil];
        message.ext = data;
    }
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        if (!error)
        {
            NSLog(@"透传消息发送成功");
        }else
            NSLog(@"透传消息发送失败");
    }];
}
-(NSMutableDictionary *)insertSystemInfo:(NSString *)systemType toUser:(NSString *)toUser systemInfo:(NSDictionary *)systemInfo sendInfo:(NSDictionary *)sendInfo content:(NSString *)content chatType:(NSInteger)type isInsert:(BOOL)isInsert
{
    /*
     1. 群系统消息，删除和加入消息
     2. 群系统消息，红包消息--类是xxxxx领取了xxxx的红包
     3. 群系统消息，修改群名称--类是xxxxxx修改了群名
     4. 群系统消息，禁言或者解除禁言
     5. 单聊系统消息，领取红包详情
     */
    NSString *pid = [NSString getRandomString];
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] init];
    [contentDict setObject:systemType forKey:@"systemType"];
    [contentDict setObject:content forKey:@"content"];
    if ([systemType isEqualToString:@"2"] || [systemType isEqualToString:@"5"]) {
        //红包部分逻辑
//        [contentDict setObject:@"" forKey:@"content"];
//        [contentDict setObject:[SWChatManage JsonToDict:content] forKey:@"sysRedBag"];
    }else if ([systemType isEqualToString:@"7"] || [systemType isEqualToString:@"8"]) {
          //红包部分逻辑
//        [contentDict setObject:@"" forKey:@"content"];
//        [contentDict setObject:[SWChatManage JsonToDict:content] forKey:@"sysRedBag"];
    }
    if (systemInfo) {
        [contentDict setObject:sendInfo forKey:@"systemInfo"];
    }
    [self sendMessageToUser:toUser
                messageType:@"system"
                   chatType:type
                   userInfo:sendInfo
                    content:contentDict
                  messageID:pid
                   isInsert:isInsert
             isConversation:isInsert
                     isJoin:YES]; //YES 默认是好友
    return contentDict;
}

@end
