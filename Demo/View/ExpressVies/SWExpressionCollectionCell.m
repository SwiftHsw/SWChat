//
//  SWExpressionCollectionCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWExpressionCollectionCell.h"
#import <SWKit.h>


@interface SWExpressionCollectionCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *lineView;
@end


@implementation SWExpressionCollectionCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 7.5, 25, 25)];
        [self.contentView addSubview:_imageView];
        
        _lineView =[[UIView alloc] initWithFrame:CGRectMake(39.6, 5, 0.4, 30)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#dadada"];
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}

-(void)setCollectViewData:(NSString *)image
{
    if ([image isEqualToString:@"expression"]) {//默认的，内置
        _imageView.image = [UIImage imageNamed:image];
    }else{
        //加载数据库的图片
//        NSString *indexImage = [NSString stringWithFormat:@"%@/%@/%@@2x.png",ATEmtionPath,image,image];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //回调或者说是通知主线程刷新，
//            [_imageView setImageURL:[NSURL fileURLWithPath:indexImage]];
//        });
        
    }
    
}

@end
