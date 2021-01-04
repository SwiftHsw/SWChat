//
//  SWTouchBaseCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWTouchBaseCell.h"


@interface SWTouchBaseCell ()
{
    CGFloat _timeCenterX;
}
@property (nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UILabel *remarkName;

@property (nonatomic, strong) UILabel *timelab;

@property (nonatomic, strong) SWChatButton *reSendBtn; //重发按钮 !

@property (nonatomic,strong) SWChatTouchModel *touchModel;


@end
@implementation SWTouchBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
       if (self) {
           self.selectionStyle = UITableViewCellSelectionStyleNone;
           self.backgroundColor = [UIColor clearColor];
           self.tintColor = [SWKit colorWithHexString:@"#1cc3b1"];
           //时间
             UIFont *font = [UIFont systemFontOfSize:14];
                UILabel *time = [[UILabel alloc] init];
                [time setTextColor:[UIColor whiteColor]];
                time.font = font;
           time.backgroundColor =[SWKit colorWithHexString: @"#cecece"];
                time.textAlignment = NSTextAlignmentCenter;
                time.layer.masksToBounds = YES;
                time.layer.cornerRadius = 4.0;
                [self.contentView addSubview:time];
                _timelab = time;
           
           //昵称
           UILabel *name = [[UILabel alloc] init];
                name.font =font;
                [self.contentView addSubview:name];
                _nameLab = name;
           
              //头像
              SWChatButton *btn = [SWChatButton buttonWithType:UIButtonTypeCustom];
             [btn.layer setCornerRadius:4];
                btn.layer.masksToBounds=YES;
                [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
                [self.contentView addSubview:btn];
       
                _userBtn = btn;
           
           //已读
           UILabel *remarkName = [[UILabel alloc] init];
                 remarkName.font = [UIFont systemFontOfSize:14];
                 remarkName.hidden = NO;
                 remarkName.textColor = [SWKit colorWithHexString: @"#2e2e2e"];
                 [self.contentView addSubview:remarkName];
                 _remarkName = remarkName;
           
           //发送失败重发按钮
           SWChatButton *reUp = [SWChatButton buttonWithType:UIButtonTypeCustom];
           [reUp setImage:[UIImage imageNamed:@"system_icon_alert_inter"] forState:UIControlStateNormal];
           [reUp addTarget:self action:@selector(reUploadAction:) forControlEvents:UIControlEventTouchUpInside];
//           reUp.hidden = YES;
           [self.contentView addSubview:reUp];
           _reSendBtn = reUp;
           
       }
           return self;
}

-(void)reUploadAction:(SWChatButton *)sender
{
    SWLog(@"重新发送逻辑");
}

-(void)setBaseCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel{
    
//     SWLog(@"子视图 调用我啦！ 头像和昵称必不可少哦～");
    
    _touchModel = touchModel;
    _reSendBtn.hidden = YES;
    _reSendBtn.frame = CGRectMake(0, 0, 0, 0);
 
     BOOL isSend =[touchModel.fromUser isEqualToString:[SWChatManage getUserName]];
    
      _userBtn.isUser = isSend;
    if (![touchModel.showTime isEqualToString:@"0000"]) {
        //时间有值
         _timelab.hidden = NO;
         _timelab.frame = CGRectMake((SCREEN_WIDTH-touchModel.timeWidth)/2, 8, touchModel.timeWidth, 20);
         _timelab.text = touchModel.showTime;
         _timeCenterX = (SCREEN_WIDTH-touchModel.timeWidth)/2;
     }else{
         _timelab.hidden = YES;
         _timelab.height = 0;
         _timelab.y = 0;
     }
       _userBtn.frame = isSend?CGRectMake(SCREEN_WIDTH-50, _timelab.hidden?5:40,40, 40):CGRectMake(10, _timelab.hidden?5:35, 40, 40);
     
    //群聊和单聊 可以分开做逻辑，这边以单聊为demo
    
    if (isSend) {
        [_userBtn setImageWithURL:[NSURL URLWithString:@"http://b373.photo.store.qq.com/psb?/V12Kb7us1atDSD/wfGxOLMT7882PPqwVkJrSLcYmz53y2ljFeV.3Jk.DHM!/b/dHUBAAAAAAAA&bo=jgUgA4AHOAQFCTk!&rf=viewer_4"] forState:UIControlStateNormal options:YYWebImageOptionSetImageWithFadeAnimation];
         
    }else{
            [_userBtn setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1605946139171&di=df11437b35cd32d9d0866d2de3c561b0&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201409%2F11%2F20140911211243_3rT4u.jpeg"] forState:UIControlStateNormal options:YYWebImageOptionSetImageWithFadeAnimation];
                 
           _userBtn.imToken =touchModel.fromUser;
           _userBtn.userId = [touchModel.sendUserInfo valueForKey:@"loginName"];
            
            //模拟是否显示群昵称
              _remarkName.hidden = kStringIsEmpty(_shouldShowName);
           if (_shouldShowName) {
                _remarkName.frame = CGRectMake(60,CGRectGetMaxY(_timelab.frame)+5, SCREEN_WIDTH-70, 20);
                _remarkName.text = _shouldShowName;
               
            }
           
       }
   
    //这边统一设置重发按钮的中心点坐标
    //是否有系统时间提示 0000 Y从-3开始否则32 开始,目测~
    BOOL isShowTime = [touchModel.showTime isEqualToString:@"0000"];
    float pointX = 0;
    float pointY = isShowTime ?0:32;
    
    if ([touchModel.type isEqualToString:@"text"]) {//文字信息
        CGSize rectsize = touchModel.textLayout.textBoundingSize;
        pointY = ((touchModel.cellHeight+35-pointY)-20)/2+pointY-5;
        pointX = isSend ?SCREEN_WIDTH-rectsize.width-55-20:rectsize.width+85;
    } else if ([touchModel.type isEqualToString:@"img"])
    {
        pointY +=  (touchModel.cellHeight - 10)/2 ;
        pointX = isSend?SCREEN_WIDTH-touchModel.cellWidth-30  :touchModel.cellWidth+65;
        
    }else if ([touchModel.type isEqualToString:@"location"])
    {
        pointY +=  (touchModel.cellHeight - 10)/2 ;
        
        pointX = isSend?SCREEN_WIDTH-235-20-25:55+180+25;
    }
    
    if (!_reSend) {
        _reSendBtn.frame = CGRectMake(0, 0, 0, 0);
        _reSendBtn.hidden = YES;
    }else{
        _reSendBtn.frame = CGRectMake(pointX - (self.userBtn.width + 15) , pointY, 20, 20);
        _reSendBtn.tag = _cellIndex;
        _reSendBtn.hidden = NO;
    }
    _userBtn.touchModel = touchModel;
      
}
@end
