//
//  SWLocationTableViewCell.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWLocationTableViewCell : UITableViewCell
@property (nonatomic) AMapPOI *poiModel;
@end

NS_ASSUME_NONNULL_END
