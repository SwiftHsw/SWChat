//
//  ATChatTitleView.h
//  yunFTProject
//
//  Created by 陈俏俊 on 2018/1/19.
//  Copyright © 2018年 陈俏俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATChatTitleView : UIView

-(id)initWithFrame:(CGRect)frame;


-(void)updateAllFrame:(float)width pointX:(float)pointx title:(NSString *)title count:(int)count isJin:(BOOL)isJin;

-(void)onlyLabel:(NSString *)title count:(int)count isJin:(BOOL)isJin;
@end
