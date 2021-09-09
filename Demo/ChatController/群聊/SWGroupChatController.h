//
//  SWGroupChatController.h
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/6.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWGroupChatController : SWChatViewController
//收到对象发送的消息，进入的事件
-(void)addMessageToArr:(NSArray *)addArr;

@property (nonatomic, strong) NSString *drafrStr;

@property (strong, nonatomic) EMConversation *conversation;



-(void)groupStateDidChange:(BOOL)isJoin;

-(void)updateTitleState:(NSString *)state parames:(NSDictionary *)parames;

-(void)shouldUpdateData;
@end

NS_ASSUME_NONNULL_END
