//
//  SWChatTextCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWTouchBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWChatTextCell : SWTouchBaseCell
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isLoad;
  
/**
 填充基类数据
 
 @param touchModel 聊天模型数据
 */
-(void)setTextCell:(SWChatTouchModel *)touchModel
    touchUserModel:(SWFriendInfoModel *)userModel
        isShowName:(BOOL)isShow;
 
@end

NS_ASSUME_NONNULL_END
