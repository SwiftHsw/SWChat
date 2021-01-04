//
//  FMLinkLabel.m
//  算高度
//
//  Created by 周发明 on 16/9/23.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "FMLinkLabel.h"

@interface FMLinkLabel ()<UITextViewDelegate>
/**
 *  存储点击事件的数组
 */
@property(nonatomic, strong)NSMutableArray *clickItems;
/**
 *  存储点击图片的字典
 */
@property(nonatomic, strong)NSMutableDictionary *clickAttachmentItems;
/**
 *  属性textView
 */
@property(nonatomic, weak)UITextView *textView;

@end

@implementation FMLinkLabel

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib{
    [self setUp];
}
/**
 *  初始化
 */
- (void)setUp{
    self.clickItems = [NSMutableArray array];
    self.clickAttachmentItems = [NSMutableDictionary dictionary];
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.textView.font = self.font;
    self.textView.frame = CGRectMake(-5, -8, self.bounds.size.width + 10,  self.bounds.size.height + 18);
}
/**
 *  添加一个点击事件
 *
 *  @param item 传入点击事件
 */
- (void)addClickItem:(FMLinkLabelClickItem *)item{
    // 循环遍历每一个字符的范围, 防止换行导致的部分不能响应
    for (int i = 0; i < item.range.length; i++) {
        
        NSRange range = NSMakeRange(item.range.location + i, 1);
        // 设置TextView的选中范围
        self.textView.selectedRange = range;
        // 获取选中范围在textView上的尺寸
        CGRect rect = [self.textView firstRectForRange:self.textView.selectedTextRange];
        // 将选中范围清空
        self.textView.selectedRange = NSMakeRange(0, 0);
        // 转换坐标系到本身上来
        CGRect textRect = [self.textView convertRect:rect toView:self];
        
        // 有点不准确, textView设置内容的时候container有偏移量吧  具体不太清楚
        NSInteger remainder = (NSInteger)textRect.origin.y % (NSInteger)self.font.lineHeight;
        
        if (remainder > 0) {
            textRect.origin.y += (self.font.lineHeight - remainder);
        }
        // 加入这个尺寸到数组 方便判断
        [item.textRects addObject:[NSValue valueWithCGRect:textRect]];
        
    }
    
    [self.clickItems addObject:item];
}

- (void)addClickText:(NSString *)text attributeds:(NSDictionary *)attributeds transmitBody:(id)transmitBody clickItemBlock:(FMLinkLabelClickItemBlock)clickBlock{
    // 根据现有的文本生成可变的富文本
    NSMutableAttributedString *attr = nil;
    if (self.attributedText) {
        attr = [self.attributedText mutableCopy];
    } else {
        attr = [[[NSAttributedString alloc] initWithString:self.text] mutableCopy];
    }
    // 锁定可以点击文字的范围
    NSRange range = [[attr string] rangeOfString:text];
    
    if (range.location != NSNotFound) {
        [attr setAttributes:attributeds range:range];
        self.attributedText = attr;
        FMLinkLabelClickItem *item = [FMLinkLabelClickItem itemWithText:text range:range transmitBody:transmitBody];
        item.clickBlock = clickBlock;
        [self addClickItem:item];
        [attr setAttributes:@{NSFontAttributeName : self.font} range:NSMakeRange(0, attr.length)];
        self.textView.text = [attr string];
    }
}

- (void)addClickTextAttachmentName:(NSString *)attachmentName TransmitBody:(id)transmitBody clickItemBlock:(FMLinkLabelClickItemBlock)clickBlock{
    FMLinkLabelClickItem *item = [FMLinkLabelClickItem itemWithTransmitBody:transmitBody];
    item.clickBlock = clickBlock;
    [self.clickAttachmentItems setValue:item forKey:attachmentName];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
   
    __block BOOL isClickText = NO;
    // 遍历所有的点击事件
    [self.clickItems enumerateObjectsUsingBlock:^(FMLinkLabelClickItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 遍历点击事件里的点击范围
        [obj.textRects enumerateObjectsUsingBlock:^(NSValue *rectValue, NSUInteger idx, BOOL * _Nonnull stop1) {
            if (CGRectContainsPoint([rectValue CGRectValue], point)) {
                if (obj.clickBlock) {
                    obj.clickBlock(obj.transmitBody);
                    isClickText = YES;
                    *stop = YES;
                    *stop1 = YES;
                }
            }
        }];
    }];
    // 遍历点击图片  有待完善
    if (!isClickText) {
        if (self.attributedText) {
            __weak typeof(self)weakSelf = self;
            [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(FMTextAttachment* value, NSRange range, BOOL * _Nonnull stop) {
                if (value && CGRectEqualToRect(value.bounds, CGRectMake(0, 0, 23, 23))) {
                    weakSelf.textView.selectedRange = range;
                    CGRect rect = [weakSelf.textView firstRectForRange:weakSelf.textView.selectedTextRange];
                    weakSelf.textView.selectedRange = NSMakeRange(0, 0);
                    if (CGRectContainsPoint(rect, point)) {
                        FMLinkLabelClickItem *item = [self.clickAttachmentItems valueForKey:value.attachmentName];
                        if (item) {
                            if (item.clickBlock) {
                                item.clickBlock(item.transmitBody);
                            }
                        }
                    }
                }
            }];
        }
    }
    
}

- (void)setFont:(UIFont *)font{
    self.textView.font = font;
    [super setFont:font];
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.textView.frame = CGRectMake(-5, -8, size.width + 10, size.height + 16);
    self.textView.text = [attributedText string];
    [super setAttributedText:attributedText];
}

- (void)setText:(NSString *)text{
    self.textView.text = text;
    [super setText:text];
}

- (void)layoutSubviews{
    self.textView.frame = CGRectMake(-5, -8, self.bounds.size.width + 10,  self.bounds.size.height + 18);
}

- (UITextView *)textView{
    
    if (_textView == nil) {
      
        UITextView *textView = [[UITextView alloc] init];
        
        textView.userInteractionEnabled = NO;
        
        textView.editable = NO;
        
        textView.delegate = self;
        
        [self addSubview:textView];
        
        textView.textColor = [UIColor clearColor];
        
        textView.backgroundColor = [UIColor clearColor];
        
        textView.font = self.font;
        
        textView.text = self.text;
        
        _textView = textView;
    }
    return _textView;
}

@end

@implementation FMLinkLabelClickItem

+ (instancetype)itemWithText:(NSString *)text range:(NSRange)range transmitBody:(id)transmitBody{
    
    FMLinkLabelClickItem *item = [[FMLinkLabelClickItem alloc] init];
    
    item.text = text;
    
    item.range = range;
    
    item.transmitBody = transmitBody;
    
    item.textRects = [NSMutableArray array];
    
    return item;
}

+ (instancetype)itemWithTransmitBody:(id)transmitBody{
    return [self itemWithText:nil range:NSMakeRange(0, 0) transmitBody:transmitBody];
}

@end

@implementation FMTextAttachment



@end
