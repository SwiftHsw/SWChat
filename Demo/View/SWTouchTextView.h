//
//  SWTouchTextView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SWTouchTextView;

typedef enum
{
    ExtendUp,
    ExtendDown
}ExtendDirection;

@protocol SWTouchTextViewDelegate <UITextViewDelegate>

// 监听输入框内的行数变化
- (void)sw_TextView:(SWTouchTextView *)textview textDidChanged:(NSString *)text textRow:(NSUInteger)textRow;
 
@end

@interface SWTouchTextView : UITextView
/** 占位文字 */
@property (nonatomic, copy) NSString *placeholder;

/** 占位文字颜色 */
@property (nonatomic, strong) UIColor *placeholderColor;

/** 占位文字的起始位置 */
@property (nonatomic, assign) CGPoint placeholderLocation;

/** textView是否可伸长 */
@property (nonatomic, assign) BOOL isCanExtend;

/** 伸长方向 */
@property (nonatomic, assign) ExtendDirection extendDirection;

/** 伸长限制行数 */
@property (nonatomic, assign) NSUInteger extendLimitRow;

/** 当前行数 */
@property (nonatomic, assign) NSUInteger textRow;

@property (nonatomic, assign) CGFloat borderW;

@property (nonatomic, assign) id<SWTouchTextViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
