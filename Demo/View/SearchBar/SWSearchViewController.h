//
//  SWSearchViewController.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/19.
//  Copyright © 2020 sw. All rights reserved.
//

#import <SWKit/SWKit.h>
#import "SWSearchBar.h"
#import "SWSearchResultDelegate.h"
#import "SWSearchControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#define HIDE_ANIMATION_DURATION 0.3
#define SHOW_ANIMATION_DURATION 0.3


@interface SWSearchViewController : SWSuperViewContoller

@property (nonatomic) SWSearchBar *searchBar;

@property (nonatomic) UIViewController<SWSearchResultDelegate>* searchResultController;

@property (nonatomic, weak) id<SWSearchControllerDelegate> delegate;

+ (instancetype)sharedInstance;

+ (void)destoryInstance;

- (void)showInViewController:(SWSuperViewContoller *)controller fromSearchBar:(SWSearchBar *)fromSearchBar ;

- (void)dismissSearchController;

- (void)dismissKeyboard;
@end

NS_ASSUME_NONNULL_END
