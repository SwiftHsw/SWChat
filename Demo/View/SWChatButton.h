//
//  SWCustomButton.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWChatButton : UIButton
/**
 聊天数据模型
 */
@property (nonatomic, strong) SWChatTouchModel *touchModel;

/**
 存储当前按钮对应的好友/本身数据模型
 */
@property (nonatomic, strong) id checkModel;


/**
 存储当前按钮对应的好友Im信息
 */
@property (nonatomic, strong) NSString *imToken;
/**
 存储当前按钮对应的好友信息
 */
@property (nonatomic, strong) NSString *userId;
/**
 当前所在的位置
 */
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIImageView *showImageView;

@property (nonatomic, assign) BOOL isUser;

@property (nonatomic, assign) BOOL isCell;

/**
 播放动画的view
 */
@property (nonatomic, strong) UIImageView *animationView;
@property (nonatomic, strong) NSString *oldUrl;
 
@end

NS_ASSUME_NONNULL_END
