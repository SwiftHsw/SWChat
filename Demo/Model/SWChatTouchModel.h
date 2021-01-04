//
//  SWChatTouchModel.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//
//模拟聊天Cell显示模型Model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWChatTouchModel : NSObject

/**
 世文加的(收藏用)
 */
@property (nonatomic, strong) NSString *userID,*videoFristFrameW,*videoFristFrameH;

/**
 是否是分享
 */
@property (nonatomic, assign) BOOL isShare;
/**
 消息id
 */
@property (nonatomic, strong) NSString *messageId;

/**
 来自谁
 */
@property (nonatomic, copy) NSString *fromUser;

/**
 来自群聊的对象。群聊比较特殊，无论是谁发，from为用户，to为群聊对象，是固定的
 */
@property (nonatomic, copy) NSString *groupFrom;

/**
 发送给谁的对象
 */
@property (nonatomic, copy) NSString *toUser;

/**
 聊天内容
 */
@property (nonatomic, copy) NSString *content;

/**
  需要的聊天内容
 */
@property (nonatomic, copy) NSString *needContent;

/**
聊天类型
 */
@property (nonatomic, copy) NSString *type;

/**
 显示时间
  */
@property (nonatomic, copy) NSString *showTime;
@property (nonatomic, copy) NSString *jl_showTime;
/**
 未经过处理的时间
*/
@property (nonatomic, copy) NSString *oldTime;
 
/**
 文件名
  */
@property (nonatomic, copy) NSString *fileName;
 
 /**
  消息唯一值
   */
@property (nonatomic, copy) NSString *pid;

/**
 是否成功
 */
@property (nonatomic, copy) NSString *isSuccess;

/**
 消息类型
 */
@property (nonatomic, copy) NSString *messType;

/**
 文件路径
 */
@property (nonatomic, copy) NSString *filePath;

/**
 是否已读
 */
@property (nonatomic, copy) NSString *isRead;

/**
是否显示群成员名称
 */
@property (nonatomic, copy) NSString *isShow;

/**
 cell高
 */
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellFinalHeight;

/**
 cell宽
 */
@property (nonatomic, assign) CGFloat cellWidth;

//图片高
@property (nonatomic, assign) CGFloat imageHeight;
//图片宽
@property (nonatomic, assign) CGFloat imageWight;
/**
 时间宽
 */
@property (nonatomic, assign) CGFloat timeWidth;

/**
 时间数组
 */
@property (nonatomic, copy) NSMutableArray *timeArr;

/**
 已加载的图片
 */
@property (nonatomic, strong) UIImage *pictImage;

/**
 点击的图片
 */
@property (nonatomic, strong) UIImage *chickImage;

/**
 上传进度
 */
@property (nonatomic, assign) float uploadProgress;

/**
 语言长度
 */
@property (nonatomic, assign) float audLength;

/**
 是否是表情
 */
@property (nonatomic, strong) NSString *isExpression;

@property (nonatomic, assign) BOOL isGIF;

@property (nonatomic, strong) NSDictionary *messageInfo;

@property (nonatomic, copy) NSString *messageInfoString ; //由于数据库不支持字典类型，这边用字符串转换做缓存用

@property (nonatomic, strong) NSDictionary *redBagInfo;

@property (nonatomic, strong) NSDictionary *sendUserInfo;

@property (nonatomic, assign) NSInteger playProgress;

//@property (nonatomic, strong) SWTouchSlider *showSlider;

@property (nonatomic, assign) BOOL isShowSlider;

@property (nonatomic, strong) UIImageView *voiceImage;
/**
 消息对应的message对象
 */
@property (nonatomic, strong) EMMessage *EMMessage;

//
@property (nonatomic, strong) EMConversation *conversation;
/**
 yylabel的lay
 */
@property (nonatomic, strong) YYTextLayout *textLayout;
 
//传入IM给的数据模型转换本地模型
-(SWChatTouchModel *)EMMToChatModel:(EMMessage *)message timeArr:(NSMutableArray *)timeArr;
 
-(SWChatTouchModel *)configLayoutForModel:(SWChatTouchModel *)model;
 

@end

NS_ASSUME_NONNULL_END
