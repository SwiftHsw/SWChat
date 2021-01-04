//
//  SWFriendListCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWFriendListCell : UITableViewCell
-(void)setFriendListCellData:(SWFriendInfoModel *)model top:(BOOL)top last:(BOOL)last count:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
