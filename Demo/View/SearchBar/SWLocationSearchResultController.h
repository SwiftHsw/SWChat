//
//  SWLocationSearchResultController.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/19.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWSearchResultDelegate.h"
#import "SWChatLocationViewController.h"
#import "SWSearchViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface SWLocationSearchResultController : UIViewController<SWSearchResultDelegate>
@property (nonatomic, weak) SWChatLocationViewController *gaodeViewController;
@property (nonatomic, weak) SWSearchViewController *searchViewController;

@end

NS_ASSUME_NONNULL_END
