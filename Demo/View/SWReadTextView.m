//
//  SWReadTextView.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWReadTextView.h"

@implementation SWReadTextView

-(id)initWithFrame:(CGRect)frame showText:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI:text];
    }
    return self;
}
-(void)creatUI:(NSString *)text
{
    self.backgroundColor = [UIColor whiteColor];
    UIScrollView *scr  = [[UIScrollView alloc]init];
    scr.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50 - SAFEBOTTOM_HEIGHT);
    
    [self addSubview:scr];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, SAFEBOTTOM_HEIGHT, SCREEN_WIDTH-20, scr.height - SAFEBOTTOM_HEIGHT)];
    label.text = text;
    label.numberOfLines = 0;
    label.font =[UIFont systemFontOfSize:22];
    label.textAlignment =NSTextAlignmentCenter;
    [scr addSubview:label];
    
    scr.contentSize = CGSizeMake(0, label.maxY+20);
    
    
    CGSize size = [text sizeForFont:label.font size:CGSizeMake(SCREEN_WIDTH-20, 99999) mode:NSLineBreakByCharWrapping];
    if (size.height>27 && size.height < scr.height) {
        label.textAlignment =NSTextAlignmentLeft;
    }else if (size.height>scr.height){
        label.textAlignment =NSTextAlignmentLeft;
        scr.contentSize = CGSizeMake(0, size.height+20);
        label.height = size.height;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50-SAFEBOTTOM_HEIGHT, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [self addSubview:line];
    NSArray *arr =@[@"分享",@"收藏"];
    float width=SCREEN_WIDTH/2;
    for (int i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:arr[i] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(i*width, SCREEN_HEIGHT-50-SAFEBOTTOM_HEIGHT, width, 50)];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired =1;
    singleTapGesture.numberOfTouchesRequired  =1;
    [self addGestureRecognizer:singleTapGesture];
}
-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    //    [self makes]
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIViewController *controller = [UIView getCurrentVC];
    [controller.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}
-(void)buttonAction:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"分享"]) {
        
    }else if ([sender.titleLabel.text isEqualToString:@"收藏"]){
  
    }
}
@end
