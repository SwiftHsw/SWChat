//
//  SWFriendListCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWFriendListCell.h"

 
@interface SWFriendListCell()

/*用户头像*/
@property (nonatomic, strong) UIImageView *headImage;
/*用户昵称*/
@property (nonatomic, strong) UILabel *nameLabel;
/*上分割线*/
@property (nonatomic, strong) UIView *TopLine;
/*下分割线*/
@property (nonatomic, strong) UIView *UnderLine;

@property (nonatomic, strong) UILabel *countLab;
@end

@implementation SWFriendListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        [self createCustomCell];
    }
    return self;
}

-(void)createCustomCell
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
    image.layer.cornerRadius = 4;
    image.clipsToBounds = YES;
    image.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:image];
    _headImage = image;
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(image.width+25, 10, SCREEN_WIDTH-image.width-25, 50)];
    name.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:name];
    _nameLabel = name;
    
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.3)];
    top.backgroundColor = [SWKit colorWithHexString:@"#ebebeb"];;
//    [self.contentView addSubview:top];
    _TopLine = top;
    
    UIView *under = [[UIView alloc] initWithFrame:CGRectMake(0, 70-0.3-0.1, SCREEN_WIDTH, 0.3)];
    under.backgroundColor = [SWKit colorWithHexString:@"#ebebeb"];;
    [self.contentView addSubview:under];
    _UnderLine = under;
    
    UILabel *countL = [[UILabel alloc] init];
    countL.hidden= YES;
    countL.textColor =[UIColor whiteColor];
    countL.backgroundColor = [UIColor redColor];
    countL.font = [UIFont systemFontOfSize:15];
    countL.textAlignment =NSTextAlignmentCenter;
    [self.contentView addSubview:countL];
    _countLab = countL;
}
-(void)setFriendListCellData:(SWFriendInfoModel *)model top:(BOOL)top last:(BOOL)last count:(NSInteger)count
{
    _nameLabel.text = [model.remark isEqualToString:@"-"]?model.nickName:model.remark;
    if (model.headImage) {
        _headImage.image = model.headImage;
    }else{
        [_headImage sd_setImageWithURL:[NSURL URLWithString:@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3531671336,3780835954&fm=26&gp=0.jpg"] placeholderImage:[UIImage new] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            model.headImage = image?image:[UIImage new];
        }];
    }
    if (top) {
        _UnderLine.frame = CGRectMake(15, 70-0.3-0.1, SCREEN_WIDTH, 0.3);
    }
    if (last) {
        _UnderLine.frame = CGRectMake(0, 70-0.3-0.1, SCREEN_WIDTH, 0.3);
    }
    if (model.isSystem) {
        _UnderLine.hidden = YES;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [SWKit colorWithHexString:@"#bababa"];
        _nameLabel.font =[UIFont systemFontOfSize:16];
        _nameLabel.frame = CGRectMake(25, 0, SCREEN_WIDTH-50, 50);
        _headImage.hidden = YES;

    }else {
        _headImage.hidden = NO;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [SWKit colorWithHexString:@"#2e2e2e"];
        _nameLabel.font =[UIFont systemFontOfSize:17];
        _nameLabel.frame = CGRectMake(_headImage.width+25, 10, SCREEN_WIDTH-_headImage.width-25, 50);
        
    }
    _countLab.hidden = YES;
    if (model.isDefault && count!=0) {
        CGFloat whith = count > 0 ? count > 10 ? count > 99 ? 30 : 25 :20 : 0 ;
        _countLab.hidden = NO;
        _countLab.text = count > 99 ? @"99+":[NSString stringWithFormat:@"%zd",count];
        _countLab.layer.cornerRadius = 10;
        _countLab.layer.masksToBounds = YES;
        _countLab.frame = CGRectMake(SCREEN_WIDTH-10-whith, 25, whith, 20);
    }
}
 
@end
