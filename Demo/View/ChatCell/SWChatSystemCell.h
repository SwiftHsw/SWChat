//
//  SWChatSystemCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/23.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWChatSystemCell : UITableViewCell
-(void)setFriendActionSystemCell:(SWChatTouchModel *)cellModel friendInfo:(SWFriendInfoModel *)infoModel;

-(void)setNoActionSystemCell:(SWChatTouchModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
