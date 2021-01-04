//
//  SWMessageCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWMessageCell : UITableViewCell

@property (nonatomic, strong) SWChatButton *longTouchBtn;

/*
  model 消息模型
  top 是否置顶
  last 是否最后一条
  count  未读数据
  isVoice 是否语音
  isSearch 是否搜索
 */
-(void)setMessageLsitCellData:(SWMessageModel *)model
                          top:(BOOL)top
                         last:(BOOL)last
                      unCount:(NSInteger)count
                      isVoice:(BOOL)isVoice
                     isSearch:(BOOL)isSearch;

@end

NS_ASSUME_NONNULL_END
