//
//  SWSearchBar.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWSearchBar : UISearchBar

+ (NSInteger)defaultSearchBarHeight;

+ (instancetype)defaultSearchBar;

+ (instancetype)defaultSearchBarWithFrame:(CGRect)frame;

- (UITextField *)searchTextField;

- (UIButton *)searchCancelButton;

- (void)resignFirstResponderWithCancelButtonRemainEnabled;

- (void)configCancelButton;
@end

NS_ASSUME_NONNULL_END
