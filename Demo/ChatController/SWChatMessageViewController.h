//
//  SWChatMessageViewController.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//  好友会话界面

#import <SWKit/SWKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWChatMessageViewController : SWSuperViewContoller

@property (nonatomic, assign) NSInteger unCount;

-(void)updateCount:(NSInteger)count;

- (void)loadData;

@end

NS_ASSUME_NONNULL_END
