//
//  SWSearchBar.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWSearchBar.h"
 

#define BAR_TINT_COLOR [UIColor colorWithRed:240/255.0 green:239/255.0 blue:245/255.0 alpha:1]
 

@implementation SWSearchBar

+ (void)initialize {
    if (self == [SWSearchBar class]) {
     [[UIBarButtonItem appearanceWhenContainedIn: [SWSearchBar class], nil] setTintColor:UIColor.greenColor];
        [[UIBarButtonItem appearanceWhenContainedIn: [SWSearchBar class], nil] setTitle:@"取消"];
    }
    
}

+ (instancetype)defaultSearchBar {
    return [self defaultSearchBarWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self defaultSearchBarHeight])];
}

+ (instancetype)defaultSearchBarWithFrame:(CGRect)frame {
    SWSearchBar *searchBar = [[SWSearchBar alloc] initWithFrame:frame];
    searchBar.placeholder = @"搜索";
    searchBar.showsCancelButton = NO;
    searchBar.barStyle = UISearchBarStyleMinimal;
    searchBar.backgroundColor = BAR_TINT_COLOR;
    
    searchBar.barTintColor = BAR_TINT_COLOR;
    searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    searchBar.tintColor = UIColor.greenColor;
    
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.enablesReturnKeyAutomatically = YES;
    
    UITextField *searchTextField = searchBar.searchTextField;
    
    searchTextField.backgroundColor = [UIColor whiteColor];
    searchTextField.textColor = [UIColor blackColor];
    
    return searchBar;
}
#define SEARCH_TEXT_FIELD_HEIGHT 28
+ (NSInteger)defaultSearchBarHeight {
    return SEARCH_TEXT_FIELD_HEIGHT + 16;
}

//- (UITextField *)searchTextField {
//    UITextField *searchTextField = nil;
//    for (UIView* subview in self.subviews[0].subviews) {
//        if ([subview isKindOfClass:[UITextField class]]) {
//            searchTextField = (UITextField*)subview;
//            break;
//        }
//    }
//    NSAssert(searchTextField, @"UISearchBar结构改变");
//
//    return searchTextField;
//}

- (UIButton *)searchCancelButton {
    UIButton *btn;
    
    NSArray<UIView *> *subviews = self.subviews[0].subviews;
    for(UIView *view in subviews) {
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            btn = (UIButton *)view;
            break;
        }
    }
    
    return btn;
}

- (void)resignFirstResponderWithCancelButtonRemainEnabled {
    [self resignFirstResponder];
    
    UIButton *cancelButton = [self searchCancelButton];
    [cancelButton setEnabled:YES];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    [super setShowsCancelButton:showsCancelButton animated:animated];
    
    [self configCancelButton];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    [self setShowsCancelButton:showsCancelButton animated:NO];
}

- (void)configCancelButton {
    UIButton *cancelButton = [self searchCancelButton];
    if (cancelButton) {
        UIColor *color = [cancelButton titleColorForState:UIControlStateNormal];
        [cancelButton setTitleColor:color forState:UIControlStateDisabled];
    }
}


@end
