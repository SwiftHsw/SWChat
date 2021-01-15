//
//  SWVoiceCell.h
//  SWChatUI
//
//  Created by mac on 2021/1/15.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWTouchBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWChatVoiceCell : SWTouchBaseCell

/**
 填充基类数据

 @param touchModel 聊天模型
 @param userModel 用户模型
 @param isShow 是否显示昵称
 */
-(void)setSoundCell:(SWChatTouchModel *)touchModel
     touchUserModel:(SWFriendInfoModel *)userModel
         isShowName:(BOOL)isShow;
@end

NS_ASSUME_NONNULL_END
