//
//  SWChatRedBagCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/20.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWTouchBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWChatRedBagCell : SWTouchBaseCell

@property (nonatomic, assign) NSInteger index;

/**
 填充基类数据
 
 @param touchModel 聊天模型数据
 @param userModel 聊天模型数据
 @param isShow 聊天模型数据
 */
-(void)setRedBagCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel isShowName:(BOOL)isShow;

-(void)setRedBagInfo:(NSDictionary *)redBagInfo;

@end

NS_ASSUME_NONNULL_END
