//
//  UIView+YDExplode.h
//  SportsBar
//
//  Created by Luo on 2017/8/10.
//  Copyright © 2017年 yuedong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TXExplodeAnimDelegate <NSObject>

- (void)txExplodeAnimDidStartView:(UIView *)view;//爆炸开始回调
- (void)txExplodeAnimDidEndView:(UIView *)view;//爆炸结束回调

@end


@interface UIView (YDExplode)

/**
 代理
 */
@property (weak, nonatomic) id<TXExplodeAnimDelegate> txExDelegate;


/**
 图片粉碎效果
 */
- (void)explodeWithPartsNum:(NSInteger)partNum timeInterval:(NSTimeInterval)timeInterval;


@end
