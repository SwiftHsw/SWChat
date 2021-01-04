//
//  SWTouchTextView.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWTouchTextView.h"
#define TextStartX 5
#define TextStartY 8
#define ExtendAnimateDuration 0

@implementation SWTouchTextView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self preSettings];
        //KVO动态监听text的值变化
        [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        self.layer.borderWidth = 0.8;
        self.layer.borderColor =[UIColor colorWithRed: 0xdd/255.0 green: 0xdd/255.0 blue: 0xdd/255.0 alpha: 1].CGColor;
        self.layer.masksToBounds = YES;
        self.inputView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)setBorderW:(CGFloat)borderW
{
    _borderW = borderW;
    self.layer.borderWidth = _borderW;
}
- (void)preSettings
{
    _placeholderLocation = CGPointMake(TextStartX, TextStartY);
//    _placeholderColor = [UIColor lightGrayColor];
    _extendDirection = ExtendDown;                      // 默认向下伸长
    _isCanExtend = YES;                                 // 默认可以伸长
    _extendLimitRow = 80;                             // 默认没有限制
//    self.text = _placeholder;
//    self.textColor = [UIColor redColor];
}
-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
}
#pragma mark - 实现KVO回调方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"text"])
    {
        NSString *text= [object valueForKey:@"text"];
        if (text.length>0&&![text isEqualToString:@""]) {
            [self scrollRangeToVisible:NSMakeRange(text.length, 1)];
        }
        [self textChanged];
    }
}

- (void)textChanged
{
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(sw_TextView:textDidChanged:textRow:)]) {
        [self.delegate sw_TextView:self
                    textDidChanged:self.text
                           textRow:_textRow];
        
    }
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    // 文字行数
    CGRect textFrame = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width - 2 * TextStartX, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.font,NSFontAttributeName, nil] context:nil];
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
    textSize.height = 19.09;
    _textRow = (NSUInteger)(textFrame.size.height / textSize.height);
    
    if (_extendLimitRow>= _textRow)
    {
        if (self.contentSize.height > self.frame.size.height && self.isCanExtend) {                   // 伸长
            [self extendFrame];
         } else if (self.contentSize.height + 8 < self.frame.size.height && self.isCanExtend) {        // 收回
            [self extendFrame];
        }
    }else
    {
        [UIView animateWithDuration:ExtendAnimateDuration animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 93);
           [self.delegate sw_TextView:self
                              textDidChanged:self.text
                                     textRow:_textRow];
        }];
    }
}
- (void)extendFrame
{
    if (_extendDirection == ExtendUp) {     // 向上伸长
        CGFloat offset = self.contentSize.height  - self.frame.size.height;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - offset, self.frame.size.width, self.contentSize.height);
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.contentSize.height);
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }
   [self.delegate sw_TextView:self
                      textDidChanged:self.text
                             textRow:_textRow];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    [self setNeedsDisplay];
}


/** 去除holder */
- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
    [self textChanged];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    [self removeObserver:self forKeyPath:@"text"];
}
@end
