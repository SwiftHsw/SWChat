//
//  SWChatSystemCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/23.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatSystemCell.h"
#import "FMLinkLabel.h"

@interface SWChatSystemCell (){
    CGFloat _centenX;
    CGFloat _contentLabX;
    SWChatTouchModel *_model;
}

@property (nonatomic, strong) UILabel *timelab;

@property (nonatomic, strong) FMLinkLabel *contentLab;

@property (nonatomic, strong) UIView *bgView;

@end
@implementation SWChatSystemCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor colorWithHexString:@"#1cc3b1"];
        UIFont *font = [UIFont systemFontOfSize:14];
        UILabel *time = [[UILabel alloc] init];
        [time setTextColor:[UIColor whiteColor]];
        time.font = font;
        time.backgroundColor =[UIColor colorWithHexString:@"#cecece"];
        time.textAlignment = NSTextAlignmentCenter;
        time.layer.masksToBounds = YES;
        time.layer.cornerRadius = 4.0;
        [self.contentView addSubview:time];
        _timelab = time;
        
        UIView *view =[[UIView alloc] init];
        view.layer.cornerRadius = 4.0;
        view.layer.masksToBounds =YES;
        view.backgroundColor =[UIColor colorWithHexString:@"#cecece"];
        [self.contentView addSubview:view];
        _bgView = view;
        
        FMLinkLabel *content = [[FMLinkLabel alloc] init];
        content.backgroundColor =[UIColor clearColor];
        content.textColor = [UIColor whiteColor];
        content.numberOfLines = 0;
        content.lineBreakMode = NSLineBreakByCharWrapping;
        content.font = [UIFont systemFontOfSize:14];
        [_bgView addSubview:content];
        _contentLab = content;
        
        
    }
    return self;
}

-(void)setNoActionSystemCell:(SWChatTouchModel *)cellModel
{
    _model = cellModel;
    
    NSString *time = cellModel.showTime;
    NSString *content = cellModel.content;
    BOOL isTime = [time isEqualToString:@"0000"];
    int timeHeight = 0;
    if (!isTime) {
        _timelab.hidden = NO;
        _timelab.frame = CGRectMake((SCREEN_WIDTH-cellModel.timeWidth)/2, 8, cellModel.timeWidth, 20);
        _centenX = (SCREEN_WIDTH-cellModel.timeWidth)/2;
        _timelab.text = time;
        timeHeight = 28;
    }else
        _timelab.hidden = YES;
    _contentLab.text = content;
    
    CGSize expectSize;
    expectSize.width =cellModel.cellWidth;
    if (isTime) {
        expectSize.height = cellModel.cellHeight-12;
    }else
        expectSize.height = cellModel.cellHeight-37;
    float width = expectSize.width;
    _bgView.frame = CGRectMake((SCREEN_WIDTH-width-10)/2,5+timeHeight, width+10, expectSize.height);
    _contentLab.frame = CGRectMake(8,0, _bgView.frame.size.width-16, _bgView.height);
    if (_contentLab.height>25) {
        _contentLab.textAlignment = NSTextAlignmentLeft;
    }else
        _contentLab.textAlignment = NSTextAlignmentCenter;

   _contentLabX = (SCREEN_WIDTH-width-15)/2;

    if ([cellModel.messType isEqualToString:@"系统消息"]) {
        _bgView.backgroundColor =[UIColor clearColor];
        _contentLab.textColor = [UIColor colorWithHexString:@"#cecece"];
    }else{
        _bgView.backgroundColor =[UIColor colorWithHexString:@"#cecece"];
        _contentLab.textColor = [UIColor whiteColor];
        _contentLab.backgroundColor = [UIColor clearColor];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
