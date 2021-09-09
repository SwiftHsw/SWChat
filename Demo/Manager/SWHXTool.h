//
//  SWHXTool.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWChatTouchModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWHXTool : NSObject


#pragma mark 回调
@property (nonatomic, copy) void (^OperationBlock)(NSDictionary *info,EMError *error);

@property (nonatomic, copy) void(^getDataBlock)(id data,id otherData,NSError *error);
//发送回调
@property (nonatomic, copy) void(^messageSendBlock)(EMMessage *message,NSString *error);
//插入并且需要更新会话
@property (nonatomic, copy) void(^messageInsertBlock)(EMMessage *message,NSString *error);
@property (nonatomic, copy) void(^sendImageInsertBlock)(EMMessage *message,NSString *error);
//重发
@property (nonatomic, copy) void(^messageReSendBlock)(SWChatTouchModel *model);
@property (nonatomic, copy) void(^leverFromGroupBlock)(NSDictionary *info,EMError *error);

//单例
+ (instancetype)sharedManager;
//1. 正序。2. 倒序
@property (nonatomic, copy) NSString *action;
#pragma mark 账号操作
//账号注册
-(void)registerWithUsername:(NSString *)name isReLogin:(BOOL)isReLogin didGoon:(BOOL)goon;
//账号登陆
-(void)loginWithUsername:(NSString *)name isReLogin:(BOOL)isReLogin didGoon:(BOOL)goon;
//推出登陆
-(void)logout;
//登录成功
-(void)didLoginSuccess;

#pragma mark 好友操作
//同意好友请求
-(void)accapectAddFriendPost:(NSString *)accapectLoginName;
//发送好友请求
-(void)sendFriendPost:(NSString *)toUser post:(NSString *)post isShow:(BOOL)isShow;


#pragma mark 消息操作
//解析消息体
-(NSString *)textContent:(EMMessage *)message;
//获取会话列表
-(NSMutableArray *)getConversations;
//删除会话
-(void)deleteByConversationID:(NSString *)toUse;

//发送消息
/*
 发送消息
 @param toUser 接收方的ID
 @param messtype 聊天类型
 @param chatType 会话类型 1单聊 2群聊
 @param info 接收方的信息
 @param content 会话内容
 @param messageID 会话ID
 **/
-(void)sendMessageToUser:(NSString *)toUser
             messageType:(NSString *)messtype
                chatType:(NSInteger)chatType
                userInfo:(NSDictionary *)info
                 content:(NSDictionary *)content
               messageID:(NSString *)messageID
                isInsert:(BOOL)isInsert
          isConversation:(BOOL)isConversation
                  isJoin:(BOOL)isJoin;

//发送语音消息 走环信～
- (void)sendTouchVoiceToUser:(NSString *)toUser
                   localPath:(NSString *)alocalPath
                 displayName:(NSString *)aDisplayName
                    duration:(int)duration;

-(void)getFriendList;
 //文件上传完成后重新发送
-(void)sendMessageToUser:(EMMessage *)message touchModel:(SWChatTouchModel *)model;

//发送透传信息
-(void)sendCMDMessageToUser:(NSString *)toUser
                content:(NSString *)content
                     action:(NSString *)action
                      group:(NSInteger)group
             sendRemarkName:(NSString *)sendRemarkName;

//更新上传状态 图片
-(SWChatTouchModel *)updateUploadState:(NSString *)state
                               content:(NSString *)content
                            touchModel:(SWChatTouchModel *)model
                          conversation:(EMConversation *)conver;

#pragma 群操作
//获取群列表
-(void)getChatGroupList;
/**
 创建群聊
 
 @param invitees 被邀请的人
 @param type
 1为消息转发/分享创建群聊
 2为单聊界面--详情--创建群聊
 3为群聊列表界面--创建群聊
 4为添加人员至群聊
 5为消息转发创建群聊需要回调群对象
 6为分享创建群聊需要回调的对象
 7为邀请打开创建群聊需要回调的对象
 8为分享链接创建群聊
 9为邀请圈子成员创建群聊
 10为推荐好友创建群聊
 
 @param object type对应的实体信息
 */
-(void)createGroup:(NSArray *)invitees
        actionType:(NSInteger)type
            object:(id)object
         friendArr:(NSArray *)friendArr
     invitationArr:(NSArray *)invitationArr;

//异步发送群邀请
-(void)sendGroupInvitationMessage:(NSArray *)invitationArr index:(NSInteger)index groupId:(NSString *)name groupModel:(SWChatGroupModel *)groupModel;


/*
 退出群聊
 @param groupID 被邀请的人
 @param isOwner 是否是群主，如果是群主是解散群聊，不然是退出群聊
 */
-(void)exitChatGroupWithGroupId:(NSString *)groupID isOwner:(BOOL)is;


#pragma mark 其他
//进入单聊控制器
-(void)gotoSingChatControllerWithLoginName:(NSString *)toUser;
 
//插入/发送一条系统消息
/**
 1. 1为群系统消息，删除和加入消息
 2. 2为群系统消息，红包消息--类是xxxxx领取了xxxx的红包
 3. 3为群系统消息，修改群名称--类是xxxxxx修改了群名
 4. 4为群系统消息，禁言或者解除禁言
 5. 5为单聊系统消息，领取红包详情
 6. 6为群聊接收邀请
 7. 7为新的单聊领取红包系统消息
 8. 8为新的群聊领取红包系统消息
 6. 100为本地的被删除好友，好友验证消息
 7. 101为消息撤回
 8. 102为被移除群聊
 9. 103为视频/语音的系统消息
 10. 999为抱抱--消息盒子系统消息
 */
-(NSMutableDictionary *)insertSystemInfo:(NSString *)systemType
                                  toUser:(NSString *)toUser
                              systemInfo:(NSDictionary *)systemInfo
                                sendInfo:(NSDictionary *)sendInfo
                                 content:(NSString *)content
                                chatType:(NSInteger)type
                                isInsert:(BOOL)isInsert;

@end

NS_ASSUME_NONNULL_END
