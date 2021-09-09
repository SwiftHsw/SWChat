//
//  SWChatGroupModel.h
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/6.
//  Copyright © 2021 sw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HyphenateLite/HyphenateLite.h>//环信SDK

NS_ASSUME_NONNULL_BEGIN

@interface SWChatGroupModel : NSObject

/*!
 *  \~chinese
 *  群组ID
 *
 *  \~english
 *  Group id
 */
@property (nonatomic, copy) NSString *groupId;

/*!
 *  \~chinese
 *  群组的主题，需要获取群详情
 *
 *  \~english
 *  Subject of the group
 */
@property (nonatomic, copy) NSString *subject;


/*!
 *  \~chinese
 *  群组的公告，需要获取群公告
 *
 *  \~english
 *  Announcement of the group
 */
@property (nonatomic, copy) NSString *announcement;



/*!
 *  \~chinese
 *  群组的所有者，拥有群的最高权限，需要获取群详情
 *
 *  群组的所有者只有一人
 *
 *  \~english
 *  Owner of the group
 *
 *  Each group only has one owner
 */
@property (nonatomic, copy) NSString *owner;



/*!
 *  \~chinese
 *  群组的成员列表，需要获取群详情
 *
 *  \~english
 *  Member list of the group
 */
@property (nonatomic, copy) NSArray *memberList;
@property (nonatomic, strong) NSString *memberString;

@property (nonatomic, copy) NSArray *occupants;
@property (nonatomic, strong) NSString *occupantsString;
/*!
 *  \~chinese
 *  群组的被禁言列表
 *
 *  需要owner权限才能查看，非owner返回nil
 *
 *  \~english
 *  List of muted members
 *
 *  Need owner's authority to access, return nil if user is not the group owner.
 */
@property (nonatomic, strong) NSArray *muteList;

@property (nonatomic, strong) NSString *muteString;
/*!
 *  \~chinese
 *  此群组是否接收消息推送通知
 *
 *  \~english
 *  Is Apple Push Notification Service enabled for group
 */
@property (nonatomic, assign) BOOL isPushNotificationEnabled;

/*!
 *  \~chinese
 *  此群是否为公开群，需要获取群详情
 *
 *  \~english
 *  Whether is a public group
 */
@property (nonatomic, assign) BOOL isPublic;

/*!
 *  \~chinese
 *  是否屏蔽群消息
 *
 *  \~english
 *  Whether block the current group‘s messages
 */
@property (nonatomic, assign) BOOL isBlocked;



/*!
 *  \~chinese
 *  群组当前的成员数量，需要获取群详情, 包括owner, admins, members
 *
 *  \~english
 *  The total number of group occupants, include owner, admins, members
 */
@property (nonatomic, assign) NSInteger occupantsCount;

//我在本群的昵称
@property (nonatomic, strong) NSString *userGroupName;

//是否显示群成员名称
@property (nonatomic, assign) BOOL isShowMemberName;

//是否已经被踢出
@property (nonatomic, assign) BOOL isJoin;
/*!
 *  \~chinese
 *  获取群组实例，如果不存在则创建
 *
 *  @param aGroupId    群组ID
 *
 *  @result 群组实例
 *
 *  \~english
 *  Get group instance, create a instance if it does not exist
 *
 *  @param aGroupId  Group id
 *
 *  @result Group instance
 */
+ (instancetype)groupWithId:(NSString *)aGroupId;

-(id)initWithEmmGroup:(EMGroup *)group;


@end

NS_ASSUME_NONNULL_END
