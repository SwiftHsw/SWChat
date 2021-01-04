//
//  SWSearchControllerDelegate.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/19.
//  Copyright © 2020 sw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWSearchViewController;
 
@protocol SWSearchControllerDelegate <NSObject>

@optional

- (void)willDismissSearchController:(SWSearchViewController *)searchController;

- (void)didDismissSearchController:(SWSearchViewController *)searchController;

- (void)willPresentSearchController:(SWSearchViewController *)searchController;

- (void)didPresentSearchController:(SWSearchViewController *)searchController;

@end
