//
//  SWNmberButton.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWNmberButton.h"
 
#define kBtnWidth self.bounds.size.width
#define kBtnHeight self.bounds.size.height

#import "SWNmberButton.h"

@implementation BtnMyView

@end


@interface SWNmberButton()

/** 绘制不规则图形 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation SWNmberButton


//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    [self setUp];
//}
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    [self setUp];
//}


#pragma mark - 懒加载
- (NSMutableArray *)images
{
    if (_images == nil) {
        _images = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
            [_images addObject:image];
        }
    }
    
    return _images;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    
    return _shapeLayer;
}

- (BtnMyView *)samllCircleView
{
    if (!_samllCircleView) {
        _samllCircleView = [[BtnMyView alloc] init];
        _samllCircleView.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:_samllCircleView belowSubview:self];
    }
    
    return _samllCircleView;
}


- (void)setTitleBtn:(NSString *) titleBtn {
    if (_titleBtn != titleBtn) {
        _titleBtn = titleBtn;
        [self setUp];
    }
}
- (void)setUp
{
    CGFloat cornerRadius = (kBtnHeight > kBtnWidth ? kBtnWidth / 2.0 : kBtnHeight / 2.0);
    [self setBackgroundColor:[UIColor redColor]];
    [self setTitle:_titleBtn forState:UIControlStateNormal];
    self.titleLabel.font =  [UIFont systemFontOfSize:13];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _maxDistance = cornerRadius * 4;

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    
    CGRect samllCireleRect = CGRectMake(0, 0, cornerRadius * (2 - 0.5) , cornerRadius * (2 - 0.5));
    self.samllCircleView.bounds = samllCireleRect;
    _samllCircleView.center = self.center;
    _samllCircleView.layer.cornerRadius = _samllCircleView.bounds.size.width / 2;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//    [self addGestureRecognizer:pan];
    
//    [self addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 手势
- (void)pan:(UIPanGestureRecognizer *)pan
{
    [self delegateisTo:QQBtnToucheBegan];

    
//    bringSubviewToFron
    [self.layer removeAnimationForKey:@"shake"];

    CGPoint panPoint = [pan translationInView:self];

    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    self.center = changeCenter;
    [pan setTranslation:CGPointZero inView:self];
    
    //俩个圆的中心点之间的距离
    CGFloat dist = [self pointToPoitnDistanceWithPoint:self.center potintB:self.samllCircleView.center];
    
    if (dist < _maxDistance) {
        
        CGFloat cornerRadius = (kBtnHeight > kBtnWidth ? kBtnWidth / 2 : kBtnHeight / 2);
        CGFloat samllCrecleRadius = cornerRadius - dist / 10;
        _samllCircleView.bounds = CGRectMake(0, 0, samllCrecleRadius * (2 - 0.5), samllCrecleRadius * (2 - 0.5));
       
        
        _samllCircleView.layer.cornerRadius = _samllCircleView.bounds.size.width / 2;
        
        if (_samllCircleView.hidden == NO && dist > 0) {
            //画不规则矩形
            self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:_samllCircleView].CGPath;
        }
    } else {
        
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        self.samllCircleView.hidden = YES;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (dist > _maxDistance) {
            
            //播放销毁动画
            [self startDestroyAnimations];
            
            //销毁全部控件
            [self killAll];
            
        } else {
           
            
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.samllCircleView.center;
            } completion:^(BOOL finished) {
                self.samllCircleView.hidden = NO;
            }];
             [self delegateisTo:QQBtnToucheEnded];
        }
    }
}
-(void)delegateisTo:(QQBtnTouche)touche{
    if([self.delegate respondsToSelector:@selector(isBtnDisappearTouch:)]){
        [self.delegate isBtnDisappearTouch:touche];
    }
}


#pragma mark - 俩个圆心之间的距离
- (CGFloat)pointToPoitnDistanceWithPoint:(CGPoint)pointA potintB:(CGPoint)pointB
{
    CGFloat offestX = pointA.x - pointB.x;
    CGFloat offestY = pointA.y - pointB.y;
    CGFloat dist = sqrtf(offestX * offestX + offestY * offestY);
    
    return dist;
}
//消失
- (void)killAll
{
//    [self removeFromSuperview];
//    [self.samllCircleView removeFromSuperview];
//    self.samllCircleView = nil;
//    [self.shapeLayer removeFromSuperlayer];
//    self.shapeLayer = nil;
//    [self delegateisTo:QQBtnToucheDisappear];
}

#pragma mark - 不规则路径
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView
{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCirCleView.bounds.size.height / 2;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCirCleView.bounds.size.height / 2;
    
    // 获取圆心距离
    CGFloat d = [self pointToPoitnDistanceWithPoint:self.samllCircleView.center potintB:self.center];
    CGFloat sinθ = (x2 - x1) / d;
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

#pragma mark - button消失动画
- (void)startDestroyAnimations
{
    UIImageView *ainmImageView = [[UIImageView alloc] initWithFrame:self.frame];
    ainmImageView.animationImages = self.images;
    ainmImageView.animationRepeatCount = 1;
    ainmImageView.animationDuration = 0.5;
    [ainmImageView startAnimating];
    
    [self.superview addSubview:ainmImageView];
}

- (void)btnClick
{
    [self startDestroyAnimations];
    [self killAll];
}

#pragma mark - 设置长按时候左右摇摆的动画
- (void)setHighlighted:(BOOL)highlighted
{
    [self.layer removeAnimationForKey:@"shake"];

//    //长按左右晃动的幅度大小
//    CGFloat shake = 10;
//
//    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
//    keyAnim.keyPath = @"transform.translation.x";
//    keyAnim.values = @[@(-shake), @(shake), @(-shake)];
//    keyAnim.removedOnCompletion = NO;
//    keyAnim.repeatCount = MAXFLOAT;
//    //左右晃动一次的时间
//    keyAnim.duration = 0.3;
//    [self.layer addAnimation:keyAnim forKey:@"shake"];
}

@end
