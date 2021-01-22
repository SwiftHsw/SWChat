//
//  UIView+YDExplode.m
//  SportsBar
//
//  Created by Luo on 2017/8/10.
//  Copyright © 2017年 yuedong. All rights reserved.
//

#import "UIView+YDExplode.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


static NSString *const kTXExplodeDelegateKeyString = @"kTXExplodeDelegateKeyString";
static NSString *const kOutExplodeDelegateKeyString = @"kOutExplodeDelegateKeyString";

static NSString *const kTXExplodeAnimFirstKey = @"kTXExplodeAnimFirstKey";
static NSString *const kTXExplodeAnimFirstValue = @"kTXExplodeAnimFirstValue";

static NSString *const kTXExplodeAnimLastKey = @"kTXExplodeAnimLastKey";
static NSString *const kTXExplodeAnimLastValue = @"kTXExplodeAnimLastValue";

static NSString *const kTXExplodeAnimLayerKey = @"kTXExplodeAnimLayerKey";


#pragma mark - 碎片类

/**
 微粒层
 */
@interface YDParticleLayer : CALayer
@property (nonatomic, strong) UIBezierPath *particlePath;
@property (nonatomic, weak) UIView *superView;
@end

@implementation YDParticleLayer
@end


#pragma mark - 代理类

/**
 真实的代理，将繁杂的动画回调处理后传给外部代理
 */
@interface TXExplodeDelegate : NSObject<CAAnimationDelegate>

@property (weak, nonatomic) UIView *txSuperView;

@end

@implementation TXExplodeDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if ([[anim valueForKey:kTXExplodeAnimFirstKey] isEqualToString:kTXExplodeAnimFirstValue]) {
        
        if ([self.txSuperView.txExDelegate respondsToSelector:@selector(txExplodeAnimDidStartView:)])
        {
            [self.txSuperView.txExDelegate txExplodeAnimDidStartView:self.txSuperView];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //获取到layer
    YDParticleLayer *layer = [anim valueForKey:kTXExplodeAnimLayerKey];
    if ([layer isKindOfClass:[YDParticleLayer class]]) {
        [layer removeFromSuperlayer];
    }
    
    if ([[anim valueForKey:kTXExplodeAnimLastKey] isEqualToString:kTXExplodeAnimLastValue]) {
        
        if ([self.txSuperView.txExDelegate respondsToSelector:@selector(txExplodeAnimDidEndView:)]) {
            
            [self.txSuperView.txExDelegate txExplodeAnimDidEndView:self.txSuperView];
        }
    }
}
@end




#pragma mark - 匿名类

@interface UIView ()

@property (strong, nonatomic)TXExplodeDelegate *txExplodeDelegate;

@end


#pragma mark - 爆炸实现

/**
 实现爆炸效果
 */
@implementation UIView (YDExplode)



// 将CALayer转换成图片
- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext(layer.frame.size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImg;
}


- (void)explodeWithPartsNum:(NSInteger)partNum timeInterval:(NSTimeInterval)timeInterval
{
    
    //生成一个代理
    TXExplodeDelegate *txExplodeDelegate = [[TXExplodeDelegate alloc] init];
    self.txExplodeDelegate = txExplodeDelegate;
    txExplodeDelegate.txSuperView = self;
    
    
    float particleW = self.frame.size.width / partNum;
    CGSize imageSize = CGSizeMake(particleW, particleW);
    
    CGFloat cols = self.frame.size.width / imageSize.width;
    CGFloat rows = self.frame.size.height / imageSize.height;
    
    int fullColums = floorf(cols);
    int fullRows = floorf(rows);
    
    //剩余的部分
    CGFloat remainderWidth = self.frame.size.width - (fullColums * imageSize.width);
    CGFloat remainderHeight = self.frame.size.height - (fullRows * imageSize.height);
    
    //记录原始的尺寸
    CGRect originalFrame = self.layer.frame;
    CGRect originalBounds = self.layer.bounds;
    
    CGImageRef fullImage = [self imageFromLayer:self.layer].CGImage;
    
    if ([self isKindOfClass:[UIImageView class]])
    {
        [(UIImageView *)self setImage:nil];
    }
    
    //所以的子层
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (int y = 0; y < fullRows; y++)
    {
        for (int x = 0; x < fullColums; x++)
        {
            CGSize tileSize = imageSize;
            
            if (x + 1 == fullColums && remainderWidth > 0)
            {
                tileSize.width = remainderWidth;
            }
            if (y + 1 == fullColums && remainderHeight > 0)
            {
                tileSize.height = remainderHeight;
            }
            
            
            CGRect layerRect = (CGRect){{x*imageSize.width, y*imageSize.height},
                tileSize};
            
            CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage,layerRect);
            
            YDParticleLayer *layer = [YDParticleLayer layer];
            layer.frame = layerRect;
            layer.contents = (__bridge id)(tileImage);
            layer.borderWidth = 0.0f;
            layer.borderColor = [UIColor blackColor].CGColor;
            layer.particlePath = [self pathForLayer:layer parentRect:originalFrame];
            [self.layer addSublayer:layer];
            
            CGImageRelease(fullImage);
        }
    }
    
    self.layer.frame = originalFrame;
    self.layer.bounds = originalBounds;
    
    self.layer.backgroundColor = [UIColor clearColor].CGColor;

    NSArray *sublayersArray = self.layer.sublayers;
    [sublayersArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        YDParticleLayer *layer = (YDParticleLayer *)obj;
        layer.superView = self;
        
        //路径
        CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnim.path = layer.particlePath.CGPath;
        moveAnim.removedOnCompletion = YES;
        moveAnim.fillMode=kCAFillModeForwards;
        NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
        [moveAnim setTimingFunctions:timingFunctions];
        
        
        float r = [self randomFloat];
        
        NSTimeInterval speed = timeInterval * r;//2.35
        
        CAKeyframeAnimation *transformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D startingScale = layer.transform;
        CATransform3D endingScale = CATransform3DConcat(CATransform3DMakeScale([self randomFloat], [self randomFloat], [self randomFloat]),
                                                        CATransform3DMakeRotation(M_PI*(1+[self randomFloat]), [self randomFloat], [self randomFloat], [self randomFloat]));
        
        NSArray *boundsValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:startingScale],
                                 
                                 [NSValue valueWithCATransform3D:endingScale], nil];
        [transformAnim setValues:boundsValues];
        
        NSArray *times = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:speed*.25], nil];
        [transformAnim setKeyTimes:times];
        
        
        timingFunctions = [NSArray arrayWithObjects:
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                           nil];
        [transformAnim setTimingFunctions:timingFunctions];
        transformAnim.fillMode = kCAFillModeForwards;
        transformAnim.removedOnCompletion = NO;
        
        //alpha
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
        opacityAnim.toValue = [NSNumber numberWithFloat:0.f];
        opacityAnim.removedOnCompletion = NO;
        opacityAnim.fillMode =kCAFillModeForwards;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:moveAnim,transformAnim,opacityAnim, nil];
        animGroup.duration =  speed;//speed;
        animGroup.fillMode =kCAFillModeForwards;
        
        //一组动画的标识
        
        //第一个碎片
        if (idx == 0) {
            [animGroup setValue:kTXExplodeAnimFirstValue forKey:kTXExplodeAnimFirstKey];
        }
        
        //最后一个
        else if (idx == sublayersArray.count - 1)
        {
            [animGroup setValue:kTXExplodeAnimLastValue forKey:kTXExplodeAnimLastKey];
        }
        
        animGroup.delegate = self.txExplodeDelegate;
        
        [animGroup setValue:layer forKey:kTXExplodeAnimLayerKey];
        [layer addAnimation:animGroup forKey:nil];
        //移除
        [layer setPosition:CGPointMake(-100, -100)];
        
        //设置代理
        animGroup.delegate = self.txExplodeDelegate;
        
    }];
}


#pragma mark - 算出贝尔曲线

-(UIBezierPath *)pathForLayer:(CALayer *)layer parentRect:(CGRect)rect
{
    UIBezierPath *particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:layer.position];
    
    float r = ((float)rand()/(float)RAND_MAX) + 0.3f;
    float r2 = ((float)rand()/(float)RAND_MAX)+ 0.4f;
    float r3 = r*r2;
    
    int upOrDown = (r <= 0.5) ? 1 : -1;
    
    CGPoint curvePoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    float maxLeftRightShift = 1.f * [self randomFloat];
    
    CGFloat layerYPosAndHeight = (self.superview.frame.size.height-((layer.position.y+layer.frame.size.height))) * [self randomFloat];
    CGFloat layerXPosAndHeight = (self.superview.frame.size.width-((layer.position.x+layer.frame.size.width)))*r3;
    
    float endY = self.superview.frame.size.height-self.frame.origin.y;
    
    if (layer.position.x <= rect.size.width*0.5)
    {
        //going left
        endPoint = CGPointMake(-layerXPosAndHeight, endY);
        curvePoint= CGPointMake((((layer.position.x*0.5)*r3)*upOrDown)*maxLeftRightShift,-layerYPosAndHeight);
    }
    else
    {
        endPoint = CGPointMake(layerXPosAndHeight, endY);
        curvePoint= CGPointMake((((layer.position.x*0.5)*r3)*upOrDown+rect.size.width)*maxLeftRightShift, -layerYPosAndHeight);
    }
    
    [particlePath addQuadCurveToPoint:endPoint
                         controlPoint:curvePoint];
    
    return particlePath;
    
}


#pragma mark - 真实的代理

- (void)setTxExplodeDelegate:(TXExplodeDelegate *)txExplodeDelegate
{
    objc_setAssociatedObject(self, &kTXExplodeDelegateKeyString, txExplodeDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (TXExplodeDelegate *)txExplodeDelegate
{
    TXExplodeDelegate *txExplodeDelegate = objc_getAssociatedObject(self, &kTXExplodeDelegateKeyString);
    return txExplodeDelegate;
}


#pragma mark - 外部代理

- (void)setTxExDelegate:(id<TXExplodeAnimDelegate>)txExDelegate
{

    objc_setAssociatedObject(self, &kOutExplodeDelegateKeyString, txExDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (id<TXExplodeAnimDelegate>)txExDelegate
{
    id<TXExplodeAnimDelegate> x = objc_getAssociatedObject(self, &kOutExplodeDelegateKeyString);
    return x;
}


#pragma mark - 随机数

- (float)randomFloat
{
    return (float)rand()/(float)RAND_MAX;
}

@end
