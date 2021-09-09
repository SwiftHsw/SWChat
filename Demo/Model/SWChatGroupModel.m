//
//  SWChatGroupModel.m
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/6.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWChatGroupModel.h"

@implementation SWChatGroupModel

-(id)initWithEmmGroup:(EMGroup *)group
{
    if (group) {
        self.groupId = group.groupId;
        self.subject = @"群聊";
        self.announcement = group.announcement;
        self.owner = group.owner;
        self.memberList = group.memberList;
        self.muteList = group.muteList;
        self.isPushNotificationEnabled = group.isPushNotificationEnabled;
        self.isPublic = group.isPublic;
        self.isBlocked = group.isBlocked;
        self.occupantsCount = group.occupantsCount;
    }
    return self;
}
@end
