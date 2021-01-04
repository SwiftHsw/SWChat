//
//  SWNmberButton.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QQBtnTouche) {
    QQBtnToucheDisappear,    //btn 移除
    QQBtnToucheBegan,         //btn 手指按下
    QQBtnToucheEnded,          //  手指抬起（未实现）
};

@class BtnMyView;

@protocol SWNmberButtonDelegate <NSObject>

- (void)isBtnDisappearTouch:(QQBtnTouche)btnType;


@end

@interface SWNmberButton : UIButton
/** 大圆脱离小圆的最大距离 */
@property (nonatomic, assign) CGFloat        maxDistance;

/** 小圆 */
@property (nonatomic, strong) BtnMyView         *samllCircleView;

/** 按钮消失的动画图片组 */
@property (nonatomic, strong) NSMutableArray *images;
/**
 *  添加按钮文字
 */
@property (nonatomic, copy) NSString *titleBtn;

@property (nonatomic, weak, nullable) id <SWNmberButtonDelegate> delegate;

@end


@interface BtnMyView : UIView


@end


NS_ASSUME_NONNULL_END
