//
//  SWChatRedBagCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/20.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatRedBagCell.h"
 
@interface SWChatRedBagCell ()

@property (nonatomic, strong) UIImageView *redBagView;

@property (nonatomic, strong) UILabel *remarkLab;

@property (nonatomic, strong) UILabel *checkLab;

@property (nonatomic, strong) SWChatButton *checkBtn;

@property (nonatomic, strong) SWChatTouchModel *touchModel;

@property (nonatomic, assign) NSInteger chooseIndex;

@property (nonatomic, strong) UILabel *statLab;

@property (nonatomic, assign) NSInteger centerX;

//@property (nonatomic, weak) ATRedPackedShowView *showView;

@property (nonatomic, strong) SWFriendInfoModel *friendModel;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGr;

@end

@implementation SWChatRedBagCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *bgView = [[UIImageView alloc] init];
        [self.contentView addSubview:bgView];
        _redBagView = bgView;
        
        UILabel *stat = [[UILabel alloc] init];
        stat.textColor = [UIColor grayColor];
        stat.font = [UIFont systemFontOfSize:13];
        stat.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:stat];
        _statLab = stat;
        
        UILabel *remark = [[UILabel alloc] initWithFrame:CGRectMake(65, 13, 160, 25)];
        remark.font = [UIFont systemFontOfSize:16];
        remark.textColor = [UIColor whiteColor];
        [_redBagView addSubview:remark];
        _remarkLab = remark;
        
        UILabel *check = [[UILabel alloc] initWithFrame:CGRectMake(65, 38, 160, 25)];
        check.font = [UIFont systemFontOfSize:14];
        check.text = @"点击拆开红包";
        check.textColor = [UIColor whiteColor];
        [_redBagView addSubview:check];
        _checkLab= check;
        
        SWChatButton *checkBtn = [SWChatButton buttonWithType:UIButtonTypeCustom];
        [checkBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:checkBtn];
        checkBtn.tag = _index;
        _checkBtn = checkBtn;
        
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.5;

        [_checkBtn addGestureRecognizer:longPressGr];
        _longPressGr = longPressGr;
    }
    return self;
}

-(void)setRedBagCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel isShowName:(BOOL)isShow
{
    [super setBaseCell:touchModel touchUserModel:userModel];
    
    _touchModel = touchModel;
    
//    NSInteger stats = [[touchModel.messageInfo valueForKey:@"stats"] integerValue];
 
    NSInteger stats = [touchModel.messageInfoString integerValue];
    
    float width = 240;
    float showName = 0;
    BOOL isSend = [touchModel.fromUser isEqualToString:[SWChatManage getUserName] ];
    if (self.showName && !isSend) {
        showName = 20;
    }
    float poinY = self.userBtn.y+showName;
    
    NSInteger pointX = isSend?SCREEN_WIDTH-width-10-self.userBtn.width:10+self.userBtn.width;
    
    _redBagView.frame = CGRectMake(pointX, poinY, width, 80);
    _redBagView.userInteractionEnabled = YES;
    _statLab.frame = CGRectMake(0, CGRectGetMaxY(_redBagView.frame)+5, SCREEN_WIDTH, 20);
    
    
    _remarkLab.text = @"恭喜发财";
    _checkBtn.frame = _redBagView.frame;
    _checkBtn.touchModel =touchModel;
    _checkBtn.index = _index;
   
    if (isSend) {
        _centerX = _redBagView.x;
        _redBagView.image = [UIImage imageNamed:@"icon_redbagself_n"];
        _remarkLab.x = 67;
        _checkLab.x = 67;
    }else{
        _redBagView.image = [UIImage imageNamed:@"icon_redbag_n"];
        _remarkLab.x = 80;
        _checkLab.x = 80;
    }
    _remarkLab.width = 240-_remarkLab.x-10;
    _friendModel = userModel;
        if (stats==1) {
 
            if (isSend) {
                _checkLab.text = @"红包已被领取";
                _redBagView.image = [UIImage imageNamed:@"icon_redbagself_s"];
            }else{
                _checkLab.text = @"红包已领取";
                _redBagView.image = [UIImage imageNamed:@"icon_redbag_s"];
            }
        }else if (stats == 3){
            if (isSend) {
                _redBagView.image = [UIImage imageNamed:@"icon_redbagself_s"];
            }else{
                _redBagView.image = [UIImage imageNamed:@"icon_redbag_s"];
            }
            _checkLab.text = @"红包已被领完";
        }else if (stats == 2){
            if (isSend) {
                _redBagView.image = [UIImage imageNamed:@"icon_redbagself_s"];
            }else{
                _redBagView.image = [UIImage imageNamed:@"icon_redbag_s"];
            }
            _checkLab.text = @"红包已过期";
        }else{
            if (isSend) {
                _checkLab.text = @"点击查看";
            }else
                _checkLab.text = @"点击拆开红包";
        }
   
    
}

#pragma mark 长按事件
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        GMenuItem *item3 = [[GMenuItem alloc] initWithTitle:@"删除" target:self action:@selector(deleteAction)];
        [[GMenuController sharedMenuController] setMenuItems:@[item3]];
        CGRect rect = _redBagView.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        [[GMenuController sharedMenuController] setTargetRect:rect inView:_redBagView];
        [[GMenuController sharedMenuController] setMenuVisible:YES];
        [GMenuController sharedMenuController].menuViewContainer.hasAutoHide = YES;
   
    }
}
-(void)deleteAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"删除", _chooseIndex,nil);
    }
}
-(void)chooseAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"多选",_chooseIndex,nil);
    }
}
#pragma mark 按钮的点击事件
-(void)checkAction:(SWChatButton *)sender
{
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(sender.touchModel, @"键盘消失", sender.index,nil);
    }
 
    //模拟点击红包
    self.touchModel.messageInfoString = @"1";
    [self requestForRedBagunweave:self.touchModel];
 
}
#pragma mark 长按事件
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)deleteOne:(UIMenuItem *)item
{
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"删除", _chooseIndex,nil);
    }
}
//编辑状态
//-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
//    [super setEditing:editing animated:animated];
//    CGFloat moveSpace = 38;
//    if ([_touchModel.fromUser isEqualToString: [ATUserHelper shareInstance].user.imToken]) {
//        if (editing && [_touchModel.fromUser isEqualToString: [ATUserHelper shareInstance].user.imToken] ){
//            _redBagView.x -= moveSpace;
//        } else{
//            _redBagView.x = _centerX;
//        }
//    }
//}
//
 
#pragma mark - 单聊开红包
-(void)requestForRedBagunweave:(SWChatTouchModel *)touchModel
{
    
//    NSMutableDictionary *new = [[NSMutableDictionary alloc] initWithDictionary:touchModel.messageInfo];
//        [new setObject:@"1" forKey:@"stats"];
//        touchModel.messageInfo = new;
 
        self.menuTouchActionBlock(touchModel, @"刷新红包状态", _index, _checkBtn);
}

 
@end
