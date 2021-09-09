
//
//  ATChatTitleView.m
//  yunFTProject
//
//  Created by 陈俏俊 on 2018/1/19.
//  Copyright © 2018年 陈俏俊. All rights reserved.
//

#import "ATChatTitleView.h" 
@interface ATChatTitleView()
{
    UILabel *namelabel;
    UILabel *countLabel;
    UIImageView *jinImage;
}

@end

@implementation ATChatTitleView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        namelabel = [[UILabel alloc] init];
        namelabel.textColor = [UIColor blackColor];
        namelabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [self addSubview:namelabel];
        
        countLabel = [[UILabel alloc] init];
        countLabel.textColor = [UIColor blackColor];
        countLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [self addSubview:countLabel];
        
        
        
        jinImage = [[UIImageView alloc] init];
        jinImage.image = [UIImage imageNamed:@"msg_icon_nodisturb"];
        [self addSubview:jinImage];
    }
    return self;
}

-(void)updateAllFrame:(float)width pointX:(float)pointx title:(NSString *)title count:(int)count isJin:(BOOL)isJin
{
//    self.backgroundColor = [UIColor redColor];
//    title = @"我我我我我我我我我我哦我我我我我我我wowowowowowowowowowoow";
    //是否显示消息通知
    float imageWidth = 20;
    jinImage.hidden = NO;
    if (isJin)
    {
        jinImage.hidden = YES;
        imageWidth = 0;
    }
    //标题
    namelabel.text = title;
    //群成员个数
    if (count==0)
    {
        countLabel.text = @"";
    }else
        countLabel.text = [NSString stringWithFormat:@"(%d)",count];
    
    //承载的最大宽度
    width = width - 50 - imageWidth;
    if (iOS10Later) {
        self.frame = CGRectMake(5, 0, width, 44);
    }else
        self.frame = CGRectMake(pointx, 0, width, 44);
    CGSize maximumLabelSize = CGSizeMake(width, 44);
    CGSize expectSize = [namelabel sizeThatFits:maximumLabelSize];
    CGSize expectSize2 = [countLabel sizeThatFits:maximumLabelSize];
    //控件的最大显示长度
    float totalWidth = expectSize.width+expectSize2.width+imageWidth+8;
    
    if (totalWidth>width) {
        float nameWidth = width-expectSize2.width - imageWidth+5;
        namelabel.frame = CGRectMake(0, 0, nameWidth, 44);
        countLabel.frame = CGRectMake(CGRectGetMaxX(namelabel.frame), 0, expectSize2.width, 44);
        jinImage.frame = CGRectMake(CGRectGetMaxX(countLabel.frame)+5, 16, 12, 12);

    }else
    {
        float naPointX = (width-totalWidth)/2+5;
        namelabel.frame = CGRectMake(naPointX, 0, expectSize.width, 44);
        countLabel.frame = CGRectMake(CGRectGetMaxX(namelabel.frame)+2, 0, expectSize2.width, 44);
        jinImage.frame = CGRectMake(CGRectGetMaxX(countLabel.frame)+5, 16, 12, 12);

    }
}
-(void)onlyLabel:(NSString *)title count:(int)count isJin:(BOOL)isJin
{
    float totalWidth = SCREEN_WIDTH-99-50;
    if (iOS10Later) {
        self.frame = CGRectMake(5, 0, totalWidth, 44);
    }else
        self.frame = CGRectMake(99, 0, totalWidth, 44);
    NSString *showContent = [NSString stringWithFormat:@"%@%@",title,[NSString stringWithFormat:@"(%d)",count]];
    CGSize maxSize = [SWChatManage sizeWithText:showContent font:[UIFont systemFontOfSize:18] maxSize:CGSizeMake(SCREEN_WIDTH, 44)];
    float contentWidth = maxSize.width+10;
    if (!isJin) {
        contentWidth = contentWidth + 16;
    }
    if (contentWidth<totalWidth) {
        namelabel.frame = CGRectMake(0, 0, self.frame.size.width, 44);
        namelabel.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:showContent];
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        if (!isJin) {
            NSLog(@"有免打扰");
            attch.image = [UIImage imageNamed:@"msg_icon_nodisturb"];
            attch.bounds = CGRectMake(0, -2, 14, 14);
            countLabel.hidden = NO;
        }else{
            NSLog(@"没有免打扰");
            attch.image = nil;
            attch.bounds = CGRectMake(0, 0, 0, 0);
            countLabel.hidden = YES;
        }
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
        [attri insertAttributedString:string atIndex:attri.length];
        
        namelabel.attributedText = attri;
    }else
    {
        showContent = [NSString stringWithFormat:@"(%d)",count];
        
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:showContent];
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        CGSize maxSize = [SWChatManage sizeWithText:showContent font:[UIFont systemFontOfSize:18] maxSize:CGSizeMake(SCREEN_WIDTH, 44)];
        contentWidth = maxSize.width+20;
        if (!isJin) {
            attch.image = [UIImage imageNamed:@"msg_icon_nodisturb"];
            attch.bounds = CGRectMake(0, -2, 14, 14);
            contentWidth = contentWidth + 16;
            countLabel.hidden = NO;
        }else{
            attch.image = nil;
            attch.bounds = CGRectMake(0, 0, 0, 0);
        }
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
        [attri insertAttributedString:string atIndex:attri.length];
        countLabel.attributedText = attri;
        countLabel.frame = CGRectMake(self.frame.size.width-contentWidth, 0, contentWidth, 44);
        namelabel.frame = CGRectMake(0, 0, totalWidth-contentWidth, 44);
        namelabel.text =  title;
    }
    
}
 

@end
