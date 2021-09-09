//
//  SWMessageModel.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//
//模拟消息Cell显示模型Model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWMessageModel : NSObject
/**
 消息id
 */
@property (nonatomic, strong) NSString *messageID;

/**
 在消息界面展示的字
 */
@property (nonatomic, strong) NSString *shouContent;


@property (nonatomic, strong) NSMutableAttributedString *showAttrContent;

/**
 消息类型
 */
@property (nonatomic, strong) NSString *messageType;

/**
 最后一条消息
 */
@property (nonatomic, strong) NSString *lastContent;

/**
 最后一条消息时间
 */
@property (nonatomic, strong) NSString *lastTime;

/**
 消息的对象
 */
@property (nonatomic, strong) NSString *touchUser;

/**
 消息对象的昵称
 单聊:如果有则为备注，没有备注为昵称，没有昵称为登陆名
 群聊:为群名
 */
@property (nonatomic, strong) NSString *shouName;

/**
 需要加载的头像
 */
@property (nonatomic, strong) NSString *headUrl;
/**
 显示的头像
 */
@property (nonatomic, strong) UIImage *image;

/**
 消息未读个数
 */
@property (nonatomic, assign) NSInteger messageCount;

/**
 消息草稿
 */
@property (nonatomic, strong) NSString *draft;

/**
 是否是发送方
 */
@property (nonatomic, assign) BOOL isSend;

/**
 消息是否置顶
 */
@property (nonatomic, assign) BOOL isTop;

/**
 是否是系统消息
 */
@property (nonatomic, assign) BOOL isSystem;

/**
 是否是群聊
 */
@property (nonatomic, assign) BOOL isGroupChat;

@property (nonatomic, strong) SWFriendInfoModel *friendModel;

//群聊数据
@property (nonatomic, strong) SWChatGroupModel *groupModel;

@property (nonatomic, strong) EMMessage *oldMessage;
/**
 环信IM消息所属的会话
 */
@property (nonatomic, strong) EMConversation *conversation;

/**
 yylabel的lay
 */
@property (nonatomic, strong) YYTextLayout *textLayout;

@end

NS_ASSUME_NONNULL_END
