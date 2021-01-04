//
//  SWTouchBaseCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWChatButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWTouchBaseCell : UITableViewCell

@property (nonatomic, assign) NSInteger showName;

@property (nonatomic, assign) BOOL reSend;

@property (nonatomic, assign) NSInteger cellIndex;

@property (nonatomic, strong) SWChatButton *playButton;

@property (nonatomic, strong) NSString *shouldShowName;

@property (nonatomic, strong) SWChatButton *userBtn;

/**
 填充基类数据

 @param touchModel 聊天模型数据
 */
-(void)setBaseCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel;

@property (nonatomic, copy) void (^menuTouchActionBlock)(SWChatTouchModel *model, NSString *actionName, NSInteger index, SWChatButton *checkBtn);

@property (nonatomic, copy) void (^longTouchActionBlock)(NSString *loginName, NSString *markName, NSString *actionName);

@end

NS_ASSUME_NONNULL_END
