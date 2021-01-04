//
//  SWReadTextView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWReadTextView : UIView
@property (nonatomic, strong) SWChatTouchModel *touchModel;

-(id)initWithFrame:(CGRect)frame showText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
