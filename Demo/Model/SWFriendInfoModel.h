//
//  SWFriendInfoModel.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//
//模拟用户模型

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SWFriendInfoModel : NSObject
/**
 用户id
 */
@property (nonatomic, strong) NSString *userId;

/**
 昵称
 */
@property (nonatomic, strong) NSString *nickName;

@property (nonatomic, strong) NSString *remark;

@property (nonatomic, strong) NSString *headPic;

@property (nonatomic, strong) UIImage *headImage;

@property (nonatomic, strong) NSString *imToken;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, strong) NSString *mobile;

@property (nonatomic, strong) NSString *area;

@property (nonatomic, strong) NSString *pinYin;

@property (nonatomic, assign) BOOL isSystem;

@property (nonatomic, assign) BOOL isDefault;

@property (nonatomic, assign) BOOL isFriend;

@property (nonatomic,copy) NSString *icon;

@property (nonatomic,copy) NSString *loginName;
@end

NS_ASSUME_NONNULL_END
