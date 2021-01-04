//
//  SWFriendInfoModel.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWFriendInfoModel.h"

@implementation SWFriendInfoModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"nickName" : @"nickname",@"isFriend" : @"friend"};
}

@end
