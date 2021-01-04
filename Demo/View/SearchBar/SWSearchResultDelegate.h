//
//  SWSearchResultDelegate.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/19.
//  Copyright © 2020 sw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol  SWSearchResultDelegate <NSObject>

- (void)searchTextDidChange:(NSString *)searchText;

- (void)searchButtonDidTapped:(NSString *)searchText;

- (void)searchCancelButtonDidTapped;
 

@optional

//是否在SearchController动画前显示搜索结果Controller，默认为YES
- (BOOL)shouldShowSearchResultControllerBeforePresentation;

//当没有执行搜索时，是否隐藏搜索结果Controller，默认为NO
//注意：不是指没有搜索结果，而是指取消当前搜索，比如用户清空搜索字符串
- (BOOL)shouldHideSearchResultControllerWhenNoSearch;

//搜索结果控制器，需要和搜索转场动画同时执行的动画，比如内容淡入
- (void (^)(void))animationForPresentation;

//搜索结果控制器，需要和搜索转场动画同时执行的动画，比如内容淡出
- (void (^)(void))animationForDismiss;


@end

NS_ASSUME_NONNULL_END
