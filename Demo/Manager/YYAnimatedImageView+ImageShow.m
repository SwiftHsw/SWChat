//
//  YYAnimatedImageView+ImageShow.m
//  SWChatUI
//
//  Created by mac on 2020/12/29.
//  Copyright © 2020 sw. All rights reserved.
//

#import "YYAnimatedImageView+ImageShow.h"
#import <objc/message.h>

@implementation YYAnimatedImageView (ImageShow)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 获取系统的方法
            Method displayLayerMethod = class_getInstanceMethod(self, @selector(displayLayer:));
            // 获取更新的方法
            Method displayLayerNewMethod = class_getInstanceMethod(self, @selector(displayLayerNew:));
            // 方法交换
            method_exchangeImplementations(displayLayerMethod, displayLayerNewMethod);

    });
    
    
}

- (void)displayLayerNew:(CALayer *)layer{
    Ivar imageIvar = class_getInstanceVariable([self class], "_curFrame");
    UIImage *image = object_getIvar(self, imageIvar);
    if (image) {
        layer.contents = (__bridge  id)image.CGImage;
        
    }
    else{
        if (@available(iOS 14.0,*)) {
            [super displayLayer:layer];
        }
    }
}

@end
