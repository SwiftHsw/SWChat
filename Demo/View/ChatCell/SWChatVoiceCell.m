//
//  SWVoiceCell.m
//  SWChatUI
//
//  Created by mac on 2021/1/15.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWChatVoiceCell.h"

#import <SWKit.h>

@interface SWChatVoiceCell()

//底图
@property (nonatomic, strong) UIImageView *bubbleImageView;

///点击播放
@property (nonatomic, strong) SWChatButton *playBtn;

///时长
@property (nonatomic, strong) UILabel *lenLab;

@property (nonatomic, strong) UIImageView *animalView;

@property (nonatomic, strong) SWChatTouchModel *touchModel;

@end

@implementation SWChatVoiceCell

 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //底图拉伸
        UIImageView *bubbleImageView = [UIImageView new];
        bubbleImageView.userInteractionEnabled = YES;
        bubbleImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        
        SWChatButton *button = [SWChatButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(playSoundAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [self.contentView addSubview:button];
        _playBtn = button;
        
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        [_bubbleImageView addSubview:label];
        _lenLab = label;
        
        UIImageView *animal =[[UIImageView alloc] init];
        animal.contentMode = UIViewContentModeScaleAspectFit;
        [_bubbleImageView addSubview:animal];
        _animalView = animal;
  
        
    }
 
    return self;
}
- (void)setSoundCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel isShowName:(BOOL)isShow{
    _touchModel = touchModel;
    [super setBaseCell:touchModel touchUserModel:userModel];
     
    float showName = 0;
    BOOL isSend = [touchModel.fromUser isEqual:[SWChatManage getUserName]];
    if (self.showName && !isSend) {
        showName = 20;
    }
  
    NSInteger btnWidth = 120;
    btnWidth = touchModel.audLength != 0 ? touchModel.audLength *2.5 +btnWidth:btnWidth;
    _lenLab.text = [self len:touchModel.audLength];
    
    if (isSend) {
        _bubbleImageView.frame = CGRectMake(SCREEN_WIDTH-btnWidth-10-self.userBtn.width, self.userBtn.y, btnWidth, 45);
        _lenLab.frame =CGRectMake(15, 6, 60, 35);
        _lenLab.textColor = [UIColor whiteColor];
        _animalView.frame = CGRectMake(btnWidth-50, 12, 25, 25);
        _animalView.image = [UIImage imageNamed:@"icon_voice_3"];
        [_bubbleImageView setImage:[SWChatManage soundRightImage]];
    }else
    {
        _bubbleImageView.frame = CGRectMake(10+self.userBtn.width, self.userBtn.y+showName, btnWidth, 45);
 
        if ([_lenLab.text floatValue]>10) {
            _lenLab.frame =CGRectMake(btnWidth-40, 6, 60, 35);
        }else
            _lenLab.frame =CGRectMake(btnWidth-35, 6, 60, 35);
        
        _lenLab.textColor = [UIColor colorWithHexString:@"#6e6e6e"];
        _animalView.frame = CGRectMake(20, 12, 25, 25);
        _animalView.image = [UIImage imageNamed:@"icon_voicel_3"];
        [_bubbleImageView setImage:[SWChatManage soundleftImage]];
    }
    _playBtn.touchModel = touchModel;
    _playBtn.frame = _bubbleImageView.frame;
    _playBtn.animationView = _animalView;
    if ([LVRecordTool sharedRecordTool].oldBtn) {
        if ([[LVRecordTool sharedRecordTool].oldBtn.touchModel isEqual:touchModel]) {
            
            if ([LVRecordTool sharedRecordTool].player.isPlaying) {
                [LVRecordTool sharedRecordTool].oldBtn = _playBtn;
                _playBtn.selected = true;
                if ([touchModel.fromUser isEqualToString:[SWChatManage getUserName]])
                {
                    [self playAnwions:_animalView count:touchModel.audLength right:YES];
                }else{
                    [self playAnwions:_animalView count:touchModel.audLength right:false];
                }
            }else{
                _playBtn.selected = false;
                [[LVRecordTool sharedRecordTool].oldBtn.animationView stopAnimating];
            }
        }
        
    }
    
}

-(NSString *)len:(float)aud
{
    NSString *str;
    if (aud<10) {
        str = [NSString stringWithFormat:@"%0.f \"",aud];
    }else if (aud<=60)
    {
        str = [NSString stringWithFormat:@"%0.f \"",aud];
    }else
        str = @"60 \"";
    return str;
}
-(void)playAnwions:(UIImageView *)image count:(NSInteger)count right:(BOOL)right
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (right)
    {
        [array addObject:[UIImage imageNamed:@"icon_voice_1"]];
        [array addObject:[UIImage imageNamed:@"icon_voice_2"]];
        [array addObject:[UIImage imageNamed:@"icon_voice_3"]];
    }else
    {
        [array addObject:[UIImage imageNamed:@"icon_voicel_1"]];
        [array addObject:[UIImage imageNamed:@"icon_voicel_2"]];
        [array addObject:[UIImage imageNamed:@"icon_voicel_3"]];
    }
    
    [image setAnimationImages:array];
    [image setAnimationRepeatCount:count];
    [image setAnimationDuration:1];
    [image startAnimating];
}

-(void)playSoundAction:(SWChatButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        LVRecordTool *playTool = [LVRecordTool sharedRecordTool];
       
        NSString * imToken = [SWChatManage getUserName];
        if ([sender.touchModel.fromUser isEqualToString:imToken]) {
            [self playAnwions:_animalView count:sender.touchModel.audLength right:YES];
        }else
            [self playAnwions:_animalView count:sender.touchModel.audLength right:false];
          
        EMVoiceMessageBody *body = (EMVoiceMessageBody*)sender.touchModel.EMMessage.body;
        EMDownloadStatus downloadStatus = [body downloadStatus];
        sender.oldUrl =  body.remotePath;
 
        //取消上一次记录的播放按钮
        if (playTool.player) {
            //正在播放 点击其他语音
            if (playTool.oldBtn) {
                //最后一次播放的语音地址 和 现在点击的如果不一样
                if (![sender.oldUrl isEqualToString:playTool.oldBtn.oldUrl]) {
                    //上次播放和这次播放是不同一个音频
                    SWChatButton *old = playTool.oldBtn;
                    [old.animationView stopAnimating];
                    [playTool stopPlaying];
                }
            }
        }
            //从新播放服务器地址
            [[LVRecordTool sharedRecordTool]playRecordingFile:[NSURL URLWithString:body.remotePath]];
 
        //记录点击的按钮
        playTool.oldBtn = sender;
        playTool.oldBtn.oldUrl = body.remotePath;
       
        
        if (downloadStatus == EMDownloadStatusSucceed ) {
            SWLog(@"%@", body.remotePath);
            
        }
    }else{
        //停止播放动画
        [_animalView stopAnimating];
        [[LVRecordTool sharedRecordTool]stopPlaying];
        [[LVRecordTool sharedRecordTool].oldBtn.animationView stopAnimating];
    }
   
     
}
@end
