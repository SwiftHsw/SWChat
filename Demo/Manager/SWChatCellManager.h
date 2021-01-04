//
//  SWChatCellManager.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTouchBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWChatCellManager : NSObject

+ (instancetype)sharedManager;

//当消息发送者是自己的时候，shareName无效
- (SWTouchBaseCell *)createMessageCellForMessageModel:(SWChatTouchModel *)messageModel
                                            userModle:(SWFriendInfoModel *)userModel
                                             showName:(BOOL)shareName
                                               reSend:(BOOL)reSend
                                                index:(NSInteger)index
                                  withReuseIdentifier:(NSString *)reuseId
                                            tableview:(UITableView *)tableview;

//主要事件的点击事件
@property (nonatomic, copy) void (^menuTouchActionBlock)(SWChatTouchModel *model, NSString *actionName, NSInteger index, SWChatButton *checkBtn);


@property (nonatomic, strong) NSMutableArray *loadArr;

/*!
 @property
 @brief 聊天的会话对象
 */
@property (strong, nonatomic) EMConversation *conversation;

@end

NS_ASSUME_NONNULL_END
