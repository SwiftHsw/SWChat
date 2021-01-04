//
//  SWExpressionView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SWExpressionViewDelegate
/*
   buttonName 表情名称
   value
   imm
 GifName 是否gif图
 filePath 文件路径
 */
- (void)expressionView:(NSString *)buttonName
                 value:(NSString *)value
                 image:(UIImage *)imm
                 isGif:(NSString *)GifName
              filePath:(NSString *)filePath;

@end

@interface SWExpressionView : UIView

@property (nonatomic, weak) id<SWExpressionViewDelegate>delegate;

@property (nonatomic, assign) NSInteger showCount;

@property (nonatomic, assign) BOOL isHideenSend;

-(id)initWithFrame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
