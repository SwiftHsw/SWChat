//
//  SWChatTouchInfoController.h
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/7.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWBaseSettingViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWChatTouchInfoController : SWBaseSettingViewController

//本地群组model
@property (nonatomic, strong) SWChatGroupModel *groupModel;
//服务端详情model
@property (nonatomic, strong) SWGroupServerModel *serverModel;
//会话对象
@property (strong, nonatomic) EMConversation *baseConversation;

@property (nonatomic, copy) void (^operationAction)(NSString *actionName,id object);

//添加群成员
-(void)addMemberArrWithAddArr:(NSMutableArray *)add;

//删除群成员
-(void)removeMemberArrWithAddArr:(NSMutableArray *)remove;

@end

NS_ASSUME_NONNULL_END
