//
//  SWMessageCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWMessageCell.h"
#import "SWNmberButton.h"


@interface SWMessageCell ()
/*用户头像*/
@property (nonatomic, strong) UIImageView *userImage;
/*用户昵称*/
@property (nonatomic, strong) UILabel *nameLabel;
/*最后一条记录*/
@property (nonatomic, strong) YYLabel *contentLabel;
/*时间*/
@property (nonatomic, strong) UILabel *timeLabel;
/*是否免打扰*/
@property (nonatomic, strong) UIImageView *promptImage;
/*上分割线*/
@property (nonatomic, strong) UIView *TopLine;
/*发送失败图标*/
@property (nonatomic, strong) UIImageView *failureImage;
/*免打扰图标*/
@property (nonatomic, strong) UIImageView *disturbImage;


@end
@implementation SWMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatCell];
    }
    return self;
}
-(void)creatCell
{
    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, (80-50)/2, 50, 50)];
    userImage.layer.cornerRadius = 25;
    userImage.clipsToBounds = YES;
    userImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:userImage];
    _userImage = userImage;
    
    UIImageView *failureImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 42, 16, 16)];
    failureImage.image = [UIImage imageNamed:@"system_icon_alert"];
    failureImage.hidden = YES;
    [self.contentView addSubview:failureImage];
    _failureImage = failureImage;
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 13, 40, 25)];
    time.textColor = [UIColor colorWithHexString:@"#b2b2b2"];
    time.font = [UIFont systemFontOfSize:12];
    time.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:time];
    _timeLabel = time;
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 13, SCREEN_WIDTH-150, 25)];
    name.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:name];
    [name setTextColor:[UIColor colorWithHexString:@"#333333"]];
    _nameLabel = name;
    
    
//    UILabel *content = [UILabel new];
//    content.font = [UIFont systemFontOfSize:14];
//    content.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
//    content.numberOfLines = 1;
//    content.frame = CGRectMake(75, 38, SCREEN_WIDTH-130, 24);
//    [self.contentView addSubview:content];
//
    
    // 开启异步绘制
    YYLabel *content = [YYLabel new];
    content.displaysAsynchronously = YES;
    content.ignoreCommonProperties = YES;
    content.lineBreakMode = NSLineBreakByCharWrapping;
    content.numberOfLines = 1;
    content.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    content.font = [UIFont systemFontOfSize:12];
    content.frame = CGRectMake(75, 38, SCREEN_WIDTH-130, 24);
    _contentLabel = content;
    [self.contentView addSubview:content];
    
    
//    disturbImage
    UIImageView *disturb = [[UIImageView alloc] init];
    disturb.image = [UIImage imageNamed:@"msg_icon_nodisturb"];
    disturb.frame =CGRectMake(SCREEN_WIDTH-30, 0, 14, 31/2);
    disturb.hidden = YES;
    [self.contentView addSubview:disturb];
    _disturbImage = disturb;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15+50+10, 79.8, SCREEN_WIDTH, 0.3)];
    line.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
    [self addSubview:line];
    _TopLine = line;
    
    
    SWChatButton *longTouchButton = [SWChatButton buttonWithType:UIButtonTypeCustom];
    longTouchButton.hidden = YES;
    [longTouchButton setFrame:CGRectMake(SCREEN_WIDTH-50, 35, 60, 30)];
    [self addSubview:longTouchButton];
    _longTouchBtn = longTouchButton;
}
-(void)setMessageLsitCellData:(SWMessageModel *)model top:(BOOL)top last:(BOOL)last unCount:(NSInteger)count isVoice:(BOOL)isVoice isSearch:(BOOL)isSearch{
    
    _disturbImage.hidden = YES;
    //每次清空重建
    for(UIView *myQQBtnview in [self.contentView subviews])
       {
           if ([myQQBtnview isKindOfClass:[BtnMyView class]] || [myQQBtnview isKindOfClass:[SWNmberButton class]]) {
               [myQQBtnview removeFromSuperview];
           }
       }
       SWNmberButton *qqBtn;
       if (model.messageCount!=0) {
           qqBtn =[SWNmberButton buttonWithType:UIButtonTypeCustom];
           [self.contentView addSubview:qqBtn];
           if (model.isSystem) {
               
               qqBtn.frame = CGRectMake(103/2+(11/2), _userImage.y, 12, 12);
               qqBtn.backgroundColor =[UIColor redColor];
               qqBtn.titleBtn = @" ";
               ATViewBorderRadius(qqBtn, 12/2, 1, [UIColor whiteColor]);
           }else{
               CGFloat whith = model.messageCount > 0 ? model.messageCount > 10 ? model.messageCount > 99 ? 30 : 25 :20 : 0 ;
               qqBtn.titleBtn = model.messageCount > 99 ? @"99+":[NSString stringWithFormat:@"%zd",model.messageCount];
               if (model.messageCount>99) {
                   qqBtn.frame = CGRectMake(45, 7, whith, 20);
               }else
                   qqBtn.frame = CGRectMake(50, 7, whith, 20);
               ATViewBorderRadius(qqBtn, 20/2, 1, [UIColor whiteColor]);
           }
           
       }
    if (model.image) {
        _userImage.image = model.image;
    }else{
        //从缓存找
        UIImage *old = [[SWChatManage getTouchCache] imageFromCacheForKey:model.headUrl];
        if (!old) {
            //加载网络图片 再通过url 为key 保存
            [_userImage sd_setImageWithURL:[NSURL URLWithString:[model.headUrl stringByAppendingString:@"拼接OSS地址"]] placeholderImage:[UIImage new] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                model.image =image?image:[UIImage new];
                if (image) {
                    [[SWChatManage getTouchCache] storeImage:image forKey:model.headUrl completion:nil];
                }
            }];
        }else{
            _userImage.image = old;
            model.image= old;
        }
    }
    _longTouchBtn.hidden=NO;
       _nameLabel.text = model.shouName;
     _timeLabel.text = model.lastTime;
    if (model.isSystem) {
        _longTouchBtn.hidden = YES;
        _nameLabel.frame = CGRectMake(75, (80-25)/2, SCREEN_WIDTH-150, 25);
    }else
        _nameLabel.frame = CGRectMake(75, 13, SCREEN_WIDTH-150, 25);
    if (last) {
        _TopLine.frame =  CGRectMake(0, 79.8, SCREEN_WIDTH, 0.3);
    }else
        _TopLine.frame = CGRectMake(15+50+10, 79.8, SCREEN_WIDTH, 0.3);
    _contentLabel.frame = CGRectMake(75, 38, SCREEN_WIDTH-130, 35);
    _failureImage.hidden = YES;
    if (isSearch) {
        _longTouchBtn.hidden = YES;
    }
 
        _contentLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
        if (model.lastContent && model.lastContent.length>0) {
            _contentLabel.text = model.lastContent;
            NSDictionary *info = [SWChatManage JsonToDict:model.lastContent];
            NSString *type = [info valueForKey:@"type"];
            if ([type isEqualToString:@"text"]) {
                if (model.messageCount>0 && model.showAttrContent.length!=0) {
                    _contentLabel.attributedText = model.showAttrContent;
                }else
                _contentLabel.textLayout = model.textLayout;
                    
            }else
            {
                _contentLabel.textLayout = model.textLayout;
            }
            NSDictionary *data = [info valueForKey:@"data"];
            NSString *state = [data valueForKey:@"state"];
            if ([state isEqualToString:@"failure"]) {
                _failureImage.hidden = NO;
                _failureImage.frame = CGRectMake(75, 42, 16, 16);
                _contentLabel.frame = CGRectMake(98, 38, SCREEN_WIDTH-155, 24);
                _failureImage.image = [UIImage imageNamed:@"system_icon_alert"];
            }else if ([state isEqualToString:@"upload"]){
                _contentLabel.frame = CGRectMake(98, 38, SCREEN_WIDTH-155, 24);
                _failureImage.hidden = NO;
                _failureImage.frame = CGRectMake(75, 44, 16, 12);
                _failureImage.image = [UIImage imageNamed:@"chat_icon_arrows"];
            }
        }else{
            _contentLabel.text = @"";
        }
       
    //模拟数据
    [_userImage sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1605946139171&di=df11437b35cd32d9d0866d2de3c561b0&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201409%2F11%2F20140911211243_3rT4u.jpeg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
        NSDictionary *draft = [SWPlaceTopTool getAllDraft];
        NSString *con = [draft valueForKey:model.touchUser];
        if (con && con.length!=0) {
            _contentLabel.textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREEN_WIDTH-140, 5000)
                                                                        text:[SWChatManage setMaattiEmoMessageList:[NSString stringWithFormat:@"[草稿]%@",con]]];
            model.draft = con;
        } 
}
- (NSMutableAttributedString *)labelWithString:(NSString *)str oldStr:(NSString *)old
{
    str = [NSString stringWithFormat:@"[%@] ",str];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[str stringByAppendingString:old]];
    [attrStr addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(0,str.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0,str.length)];
    return attrStr;
}

@end
