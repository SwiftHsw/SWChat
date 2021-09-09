//
//  AppDelegate.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "AppDelegate.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "SWLoginViewController.h"
#import "SWChatTabbarViewController.h"
#import "SWChatAdressBookController.h"
#import "SWGroupChatController.h"
#import "SWFriendPostModel.h"

#define  FMDB_CREATTABLE(a,b)   [[ATFMDBTool shareDatabase] at_createTable:a dicOrModel:b]

@interface AppDelegate ()

<
 EMContactManagerDelegate,
 EMChatManagerDelegate,
 EMClientDelegate,
 EMGroupManagerDelegate

>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSObject setMainColor:@"#333333"];
    
    
    //初始化图片缓存
    [SWChatManage initTouchCache];
    //创建聊天缓存文件夹
    [NSObject creatFile:[NSString stringWithFormat:@"SWChatUI/%@",@"chat"] filePath:SWDocumentPath];
    //语音文件夹
    [NSObject creatFile:@"SWChatUI/chat/touchVoice" filePath:SWDocumentPath];
     
    //好友列表
    FMDB_CREATTABLE(@"friendList", [SWFriendInfoModel new]);
    //群列表
    FMDB_CREATTABLE(@"chatGroupList", [SWChatGroupModel new]);
    //好友请求
    FMDB_CREATTABLE(@"friendPost", [SWFriendPostModel new]);
    //服务端的群详情
    FMDB_CREATTABLE(@"chatGroupInfo", [SWGroupServerModel new]);
    
    
   
    
    //配置高德
     [AMapServices sharedServices].apiKey = @"195770cba72df26f0f8de2f46fcf7a9a";
 
    
       // appkey替换成自己在环信管理后台注册应用中的appkey
    EMOptions *options = [EMOptions optionsWithAppkey:@"1152161013178489#xmg1chat"];
    // apnsCertName是证书名称，可以先传nil，等后期配置apns推送时在传入证书名称
     options.apnsCertName = nil;
     [options setIsAutoLogin:false];
     [[EMClient sharedClient] initializeSDKWithOptions:options];
     [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
     [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
     [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    self.window = [[UIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [SWLoginViewController new];
    [self.window makeKeyAndVisible];
        
    [self setupTabbar];
    
    
    return YES;
}

- (void)setupTabbar{
    // 默认
          NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
          attrs[NSForegroundColorAttributeName] = [UIColor grayColor];
          attrs[NSFontAttributeName] = kBoldFontWithSize(18);
          // 选中
          NSMutableDictionary *attrSelected = [NSMutableDictionary dictionary];
          attrSelected[NSForegroundColorAttributeName] = [[UIColor redColor] colorWithAlphaComponent:.4];
         attrSelected[NSFontAttributeName] = kBoldFontWithSize(18);
        UITabBarItem *item = [UITabBarItem appearance] ;
          [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
          [item setTitleTextAttributes:attrSelected forState:UIControlStateSelected];
                               
       //设置文字位置
        [item setTitlePositionAdjustment:UIOffsetMake(0, -2.5)];
 
}
#pragma mark 好友操作区

 - (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                 message:(NSString *)aMessage{
     
     SWFriendInfoModel *info = [[ATFMDBTool shareDatabase] isFriendWithName:aUsername];
     if (info) {//已经是好友了无需再写入数据
         return;
     }
               
     [SWAlertViewController showInController:[UIView getCurrentVC] title:[NSString stringWithFormat:@"收到%@的好友请求，请求信息:%@",aUsername,aMessage] message:@"是否接受?" cancelButton:@"拒绝" other:@"同意" completionHandler:^(SWAlertButtonStyle buttonStyle) {
         if (buttonStyle == SWAlertButtonStyleOK) {
             //发送同意请求
                 [[SWHXTool sharedManager] accapectAddFriendPost:aUsername];
         }
     }];
      
 }
//同意
/*!
@method
@brief 用户A发送加用户B为好友的申请，用户B同意后，用户A会收到这个回调
*/
- (void)friendRequestDidApproveByUser:(NSString *)aUsername{
    NSLog(@"已同意添加申请:%@",aUsername);
    
    
     SWFriendInfoModel *infoModel = [SWFriendInfoModel new];
            infoModel.nickName = aUsername;
            infoModel.remark = aUsername;
            infoModel.userId = aUsername;
            infoModel.headPic = @"";
            infoModel.imToken = aUsername;
            infoModel.isFriend = YES;
    [[ATFMDBTool shareDatabase] at_insertTable:@"friendList" dicOrModelArray:@[infoModel]];
       
    
     BOOL isHave = false;
            UIViewController *controller = [UIView getCurrentVC];
            NSArray *oldControllerArr =controller.navigationController.viewControllers;
            for (int i = 0; i<oldControllerArr.count; i++) {
                UIViewController *old = oldControllerArr[i];
                if ([old isKindOfClass:[SWChatAdressBookController class]]) {
                    isHave = true;
                    SWChatAdressBookController *address = (SWChatAdressBookController *)old;
                    [address uploadData:@"同意好友申请"];
                }
            }
    
            if (!isHave) {
                [SWChatManage updateFriendArr];
            }
             
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B拒绝后，用户A会收到这个回调
 */
- (void)friendRequestDidDeclineByUser:(NSString *)aUsername{
    
     NSLog(@"已拒绝添加申请:%@",aUsername);
}
 
 #pragma mark 消息通讯
 /*!
  *  \~chinese
  *  收到消息
  *
  *  @param aMessages  消息列表<EMMessage>
  *
  *  \~english
  *  Invoked when receiving new messages
  *
  *  @param aMessages  Receivecd message list<EMMessage>
  */
- (void)messagesDidReceive:(NSArray *)aMessages{
        NSLog(@"收到了聊天信息");
        if (aMessages.count!=0) {
             [self parsingMessageArr:aMessages index:0];
        }
}

/*!
 @method
 @brief 接收到一条及以上cmd消息
 */
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages{
    
    NSLog(@"接收到一条及以上cmd消息");
    UIViewController *controller = [UIView getCurrentVC];
    if (aCmdMessages.count!=0) {
        [aCmdMessages enumerateObjectsUsingBlock:^(EMMessage *cmdMessage, NSUInteger idx, BOOL * _Nonnull stop) {
               EMCmdMessageBody *body = (EMCmdMessageBody *)cmdMessage.body;
            if ([controller isKindOfClass:[SWChatSingViewController class]]) {
                if ([cmdMessage.from isEqualToString:[SWChatManage GetTouchUser]]) {
                    SWChatSingViewController *singChat = (SWChatSingViewController *)controller;
                    //正在输入逻辑
                    [singChat updateTitleState:body.action parames:@{}];
                }
            }
            if ([body.action isEqualToString:@"withdrawMessage"]) {
                //消息撤回
                NSDictionary *info = [SWChatManage JsonToDict:[cmdMessage.ext valueForKey:@"withDrawMessageId"]];
                                   EMConversationType type = cmdMessage.chatType==EMChatTypeGroupChat?EMConversationTypeGroupChat:EMConversationTypeChat;
                if (type==EMConversationTypeGroupChat) {
                   
                }else{
                    EMConversation *conver = [[EMClient sharedClient].chatManager getConversation:cmdMessage.from type:type createIfNotExist:YES];
                    EMError *error;
                    [conver deleteMessageWithId:[info valueForKey:@"messageId"] error:&error];
                    
                    SWFriendInfoModel *infoModel = [[ATFMDBTool shareDatabase] isFriendWithName:cmdMessage.from];
                                         NSString *name = [infoModel.remark isEqualToString:@"-"]?infoModel.nickName:infoModel.remark;
                    if (kStringIsEmpty(name)) {
                        name =  info[@"sendRemarkName"];
                    }
                                         NSString *con = [NSString stringWithFormat:@"“%@”撤回了一条信息",name];
                                         if ([cmdMessage.from isEqualToString:[SWChatManage getUserName]]) {
                                             con = @"你撤回了一条信息";
                                         }
                    [[SWHXTool sharedManager] insertSystemInfo:@"101" toUser:cmdMessage.from systemInfo:@{} sendInfo:[SWChatManage sendInfoWithSing:infoModel] content:con chatType:1 isInsert:YES];
                    
                }
                
                if ([controller isKindOfClass:[SWChatMessageViewController class]]) {
                    SWChatMessageViewController *message = (SWChatMessageViewController *)controller;
                    [message loadData];
                }
                
            }
        }];
    }
}
/*!
 *  收到消息撤回
 *
 *  @param aMessages  撤回消息列表<EMMessage>
 */
- (void)messagesDidRecall:(NSArray *)aMessages{
    NSLog(@"收到消息撤回"); 
}
 -(void)parsingMessageArr:(NSArray *)messageArr index:(NSInteger)index
 {
     __block NSInteger bIndex = index;
     if (index<messageArr.count) {
         EMMessage *message = messageArr[index];
         EMMessageBody *msgBody = message.body;
         if (msgBody.type == EMMessageBodyTypeText) {
             //文本类型 包含自定义的构造消息体
             EMConversationType type = message.chatType==EMChatTypeGroupChat?EMConversationTypeGroupChat:EMConversationTypeChat;
             EMConversation *conver = [[EMClient sharedClient].chatManager getConversation:message.conversationId type:type createIfNotExist:YES];
             EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
             EMError *errr;
             NSString *txt = textBody.text;
             if (txt.length==0) {
                 //删除
                 [conver deleteMessageWithId:message.messageId error:&errr];
                 bIndex = bIndex+1;
                 [self parsingMessageArr:messageArr index:bIndex];
             }else{
                 NSDictionary *contentJson = [SWChatManage JsonToDict:txt];
                 NSString *type = [contentJson valueForKey:@"type"];
                 if ([type isEqualToString:@"system"]) {//系统消息不计入已读未读消息
                     //当作为收红包的对象。只能看到自己的领取详情。看不到别人的领取详情
                     NSDictionary *content = [contentJson valueForKey:@"data"];
                     NSString *systemType = [content valueForKey:@"systemType"];
                     if ([systemType isEqualToString:@"2"]) {//群聊的红包
                     }else if ([systemType isEqualToString:@"8"]) {//群聊的红包
 
                     }
                     [conver markMessageAsReadWithId:message.messageId error:&errr];
                     bIndex = bIndex+1;
                     [self parsingMessageArr:messageArr index:bIndex];
                 }else{
                     //是否置顶
                     if ([SWPlaceTopTool isPlaceAtTop:message.conversationId]) {
                         [SWPlaceTopTool removeFromTopArr:message.conversationId];
                         [SWPlaceTopTool addFromTopARR:message.conversationId];
                     }
                     bIndex = bIndex+1;
                     [self parsingMessageArr:messageArr index:bIndex];
                     UIViewController *controller = [UIView getCurrentVC];
                     if (![controller isKindOfClass:[SWChatSingViewController class]]) {
                         //如果不在聊天界面 发出消息提示音
                         // //判断用户是否开启了震动
                         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                         // //判断用户是否打开了消息提示音
                         [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
                         /////兼容其他音乐播放器
                         
                     }
                 }
             }
             
         }else if (msgBody.type == EMMessageBodyTypeVoice){
              
             [self getVersi:messageArr];
         }
     }else{
         [self getVersi:messageArr];
     }
 }

- (void)getVersi:(NSArray *)messageArr{
    //获取更新会话列表 或者 直接加载
   UIViewController *controller = [UIView getCurrentVC];
   if ([controller isKindOfClass:[SWChatMessageViewController  class]]) {
       [[NSNotificationCenter defaultCenter] postNotificationName:ATDIDRECEIVENEWMESSAGE_NOTIFICATION object:nil];
   }else{
       [[SWHXTool sharedManager] getConversations];
   }
   for (int i = 0; i<controller.navigationController.viewControllers.count; i++) {
         UIViewController *old = controller.navigationController.viewControllers[i];
         if ([old isKindOfClass:[SWChatSingViewController class]]) {
             SWChatSingViewController *singChat = (SWChatSingViewController *)old;
             //单聊插入
             [singChat addMessageToArr:messageArr];
         }else if ([old isKindOfClass:[SWGroupChatController class]]){
             //群聊插入
             SWGroupChatController *groupChat = (SWGroupChatController *)old;
             [groupChat addMessageToArr:messageArr];
         }
    }
  //更新会话界面
   [[SWChatManage messageControll] loadData];
}
#pragma mark - 网络连接
/*!
 *  有以下几种情况, 会引起该方法的调用:
 *  1. 登录成功后, 手机无法上网时, 会调用该回调
 *  2. 登录成功后, 网络状态变化时, 会调用该回调
 *  @param aConnectionState 当前状态
 */
- (void)connectionStateDidChange:(EMConnectionState)aConnectionState{
    NSLog(@"连接状态  =============== %d",aConnectionState);
      NSArray *navArr = [UIView getCurrentVC].navigationController.viewControllers;
      SWChatMessageViewController *now;
      for (int i = 0; i<navArr.count; i++) {
          UIViewController *controller = navArr[i];
          if ([controller isKindOfClass:[SWChatMessageViewController class]]) {
              now = (SWChatMessageViewController *)controller;
          }
      }
      if (aConnectionState==EMConnectionDisconnected) {
          now.navigationItem.title = @"连接中";
          [[SWHXTool sharedManager] loginWithUsername:[SWChatManage getUserName]
                                            isReLogin:true
                                              didGoon:true];
      }
     
}

/*! 
 *  自动登录完成时的回调
 */
- (void)autoLoginDidCompleteWithError:(EMError *)aError{
        NSLog(@"自动登录成功");
       if (!aError) {
           [[SWHXTool sharedManager] didLoginSuccess];
       }
}

#pragma mark 群组操作区
/*!
 @method
 @brief 用户B设置了自动同意，用户A邀请用户B入群，SDK 内部进行同意操作之后，用户B接收到该回调
 */
 
- (void)didJoinGroup:(EMGroup *)aGroup inviter:(NSString *)aInviter message:(NSString *)aMessage{
    NSLog(@"群:%@邀请您进入  邀请信息:%@",aGroup.subject,aMessage);
    //    //写入用户数据到本地数据库
    SWChatGroupModel *model = [[SWChatGroupModel alloc] initWithEmmGroup:aGroup];
   
    SWChatGroupModel *old =[[ATFMDBTool shareDatabase] getGroupModelWithGroupId:aGroup.groupId];
    if (old) {
        NSString *str = [NSString stringWithFormat:@"where groupId = '%@'",aGroup.groupId];
        [[ATFMDBTool shareDatabase] at_deleteTable:@"chatGroupList" whereFormat:str];
    }
    [[ATFMDBTool shareDatabase] at_insertTable:@"chatGroupList" dicOrModel:model];
    UIViewController *controller =[UIView getCurrentVC];
    NSString *nowTouch = [SWChatManage GetTouchUser];
    if (nowTouch.length>0) {//当前又在进行聊天操作
        if ([nowTouch isEqualToString:aGroup.groupId]) {//当前聊天对象和被邀请对象是同一个
            NSArray *navArr = controller.navigationController.viewControllers;
            for (int i = 0; i<navArr.count; i++) {
                UIViewController *old = navArr[i];
                if ([old isKindOfClass:[SWGroupChatController class]]) {
                    SWGroupChatController *group = (SWGroupChatController *)old;
                    [group groupStateDidChange:true];
                }
            }
        }
    }
}


@end
