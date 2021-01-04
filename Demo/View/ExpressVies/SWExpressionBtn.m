//
//  SWExpressionBtn.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWExpressionBtn.h"

@implementation SWExpressionBtn

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    if (self.tag==404) {
        return CGRectMake((CGRectGetWidth(self.frame)-25)/2, (CGRectGetHeight(self.frame)-18)/2, 25, 18);
    }
    if (_isDefault) {
        return CGRectMake((CGRectGetWidth(self.frame)-30)/2, (CGRectGetHeight(self.frame)-30)/2, 30, 30);
    }else
        return CGRectMake((CGRectGetWidth(self.frame)-70)/2, (CGRectGetHeight(self.frame)-70)/2, 70, 70);
    
}
@end
