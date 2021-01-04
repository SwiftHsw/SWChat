//
//  SWExpressionScrollView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWExpressionCustomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWExpressionScrollView : UIScrollView
@property (nonatomic, strong) SWExpressionCustomView *customView;

@end

NS_ASSUME_NONNULL_END
