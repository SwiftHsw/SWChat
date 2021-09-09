//
//  SWChatViewController.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
// 单聊 、 群聊 父类


#import "SWTouchBarView.h"
@class SWMessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface SWChatViewController : SWSuperViewContoller  

@property (nonatomic, strong) SWMessageModel *messageModel;
 
/*底部工具栏*/
@property (nonatomic, strong) SWTouchBarView *touchBarView;

/*键盘高度*/
@property (nonatomic, assign) float keyBoardHeight;
 
/*模拟是否收到过消息 == YES*/
@property (nonatomic, assign) BOOL isReceived;

//是否是进入到@某人功能。关系到草稿输入框是否应该更新
@property (nonatomic, assign) BOOL isShouldUpdateDraft;

/*!
 @property
 @brief 聊天的会话对象
 */
@property (strong, nonatomic) EMConversation *baseConversation;

@property (nonatomic, assign) BOOL isJoin;
@property (nonatomic, assign) BOOL isMessageController;
@property (nonatomic, assign) BOOL touchBarHideen;

@property (nonatomic, strong) SWChatGroupModel *groupModel;

@property (nonatomic, strong) NSMutableDictionary *shouldShowNameDict;


//是否显示群成员昵称
@property (nonatomic, assign) BOOL isShowMemberName;

//添加消息到数据
-(void)baseAddMessageToData:(NSArray *)addArr;

//消息被撤回
-(void)withdrawWithTouchModel:(SWChatTouchModel *)model index:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
