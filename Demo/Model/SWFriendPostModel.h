//
//  SWFriendPostModel.h
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/7.
//  Copyright © 2021 sw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWFriendPostModel : NSObject
@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSString *fromUser;

@property (nonatomic, strong) NSString *postStr;

@property (nonatomic, strong) NSString *state;

@property (nonatomic, strong) NSString *toUser;

@property (nonatomic, assign) BOOL isFriend;

@property (nonatomic, strong) NSString *userInfo;

@property (nonatomic, strong) NSString *nickName;

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *headPic;
@end

NS_ASSUME_NONNULL_END
