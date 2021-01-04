//
//  SWChatImageCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/17.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWChatImageCell : SWTouchBaseCell

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) SWLabel *pressLab;


/**
 填充基类数据
 
 @param touchModel 聊天模型数据
 */
-(void)setImageCell:(SWChatTouchModel *)touchModel
     touchUserModel:(SWFriendInfoModel *)userModel
         isShowName:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
