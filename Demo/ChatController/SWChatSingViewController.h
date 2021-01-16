//
//  SWChatSingViewController.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
// 单聊界面

#import "SWChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWChatSingViewController : SWChatViewController

//草稿箱
@property (nonatomic, strong) NSString *drafrStr;

/*!
 @property
 @brief 聊天的会话对象
 */
@property (strong, nonatomic) EMConversation *conversation;

@property (nonatomic, strong) NSDictionary *lastInfo;

/// 收到对象发送的消息
-(void)addMessageToArr:(NSArray *)addArr;
/// 更新状态栏标题
-(void)updateTitleState:(NSString *)state parames:(NSDictionary *)parames;
   


@end

NS_ASSUME_NONNULL_END
