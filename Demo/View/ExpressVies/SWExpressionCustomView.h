//
//  SWExpressionCustomView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWExpressionCustomView : UIView
@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) NSInteger nowPage;

@property (nonatomic, assign) NSInteger section;
@end

NS_ASSUME_NONNULL_END
