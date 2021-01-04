//
//  SWFuncView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SWFuncViewDelegate <NSObject>
- (void)funcView:(NSString *)buttonName value:(NSString *)value;
@end


@interface SWFuncView : UIView

/* 单聊还是群聊 is*/
-(id)initWithFrame:(CGRect)frame isGroup:(NSInteger)is;

@property (nonatomic, assign) NSInteger isGroup;

@property (nonatomic, weak) id<SWFuncViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
