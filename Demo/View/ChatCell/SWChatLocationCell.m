//
//  SWChatLocationCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/19.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatLocationCell.h"
 
@interface SWChatLocationCell ()

@property (nonatomic, strong) UIImageView *bgImage;

@property (nonatomic, strong) UIImageView *showImage;

@property (nonatomic, strong) SWChatButton *selectBtn;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) SWChatTouchModel *touchModel;

@property (nonatomic, assign) NSInteger chooseIndex;

@property (nonatomic, strong) UIView *whiteView;

@property (nonatomic,strong) UILabel *oneLab;

@property (nonatomic,strong) UILabel *twoLab;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGr;

@end

@implementation SWChatLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImageView *bgImage = [[UIImageView alloc] init];
        [self.contentView addSubview:bgImage];
        _bgImage = bgImage;
        
        UIImageView *showimage = [[UIImageView alloc] init];
        showimage.layer.cornerRadius = 6.0;
        showimage.layer.masksToBounds = YES;
        [_bgImage addSubview:showimage];
        _showImage = showimage;
        kImageContenMode(_showImage);
        
        
        SWChatButton *select = [SWChatButton buttonWithType:UIButtonTypeCustom];
        [select addTarget:self action:@selector(checkMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [select setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [self.contentView addSubview:select];
        _selectBtn =select;

        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];//指定进度轮的大小
        [activity setCenter:CGPointMake(55, 55)];//指定进度轮中心点
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
        activity.hidden = YES;
        [self.contentView addSubview:activity];
        _activityView = activity;

        UIView *white = [[UIView alloc] init];
        white.backgroundColor =[UIColor whiteColor];
        [_showImage addSubview:white];
        _whiteView=white;

        UILabel *one = [[UILabel alloc] init];
        one.font =[UIFont systemFontOfSize:16];
        one.backgroundColor =[UIColor clearColor];
        one.textColor =[SWKit colorWithHexString:@"#2e2e2e"];
        [_whiteView addSubview:one];
        _oneLab =one;

        UILabel *two = [[UILabel alloc] init];
        two.font =[UIFont systemFontOfSize:13];
        two.textColor = UIColorRGB(156, 156, 156);
        [_whiteView addSubview:two];
        _twoLab =two;

        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [SWKit colorWithHexString:@"#f5f5f5"];;
        [_whiteView addSubview:line];
        _lineView = line;
        
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.5;

        [_selectBtn addGestureRecognizer:longPressGr];
        _longPressGr = longPressGr;
    }
    return self;
}

-(void)setAddressCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel isShowName:(BOOL)isShow
{
    _touchModel = touchModel;
    [super setBaseCell:touchModel touchUserModel:userModel];
    float showName = 0;
    BOOL isSend = [touchModel.fromUser isEqual:[SWChatManage getUserName]];
    if (self.showName && !isSend) {
        showName = 20;
    }
    UIImage *immmmm;
    if (touchModel.pictImage) {
        immmmm = touchModel.pictImage;
    }else
        immmmm =  [[SWChatManage getTouchCache] imageFromCacheForKey:touchModel.pid];
    if ([touchModel.content isEqualToString:@"SD缓存"] && !immmmm) {
        //上传失败，并且缓存文件丢失
        immmmm = [UIImage imageNamed:@"PhotoDownloadfailed"];
    }
    float poinY = self.userBtn.y+showName;
    float width = 220;
    float height = 140;
    if ([touchModel.fromUser isEqualToString:[SWChatManage getUserName]]) {
        _bgImage.image = [UIImage imageNamed:@"card_ send_bg"];
        _bgImage.frame = CGRectMake(SCREEN_WIDTH-width-10-self.userBtn.width, poinY, width, height);
        _showImage.frame = CGRectMake(0, 0, _bgImage.width-10, _bgImage.height);
        _whiteView.frame = CGRectMake(0, 0, _showImage.width, 46);
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"conrRight"] forState:UIControlStateHighlighted];
        _selectBtn.x = _bgImage.x-1.5;
        _selectBtn.y = _bgImage.y-2;
        _selectBtn.height = _bgImage.height+3;
        _selectBtn.width = _bgImage.width+2;
    }else{
        _bgImage.image = [UIImage imageNamed:@"card_ receive_bg"];
        _bgImage.frame = CGRectMake(10+self.userBtn.width, poinY, width, height);
        _showImage.frame = CGRectMake(10, 10, _bgImage.width-12, _bgImage.height-10);
        _whiteView.frame = CGRectMake(0, 0, _showImage.width, 46);
         [_selectBtn setBackgroundImage:[UIImage imageNamed:@"conrLeft"] forState:UIControlStateHighlighted];
        _selectBtn.frame = _bgImage.frame;
        _selectBtn.x = _bgImage.x-0.3;
        _selectBtn.height = _bgImage.height+1.3;
    }
    if (immmmm)
    {
        UIImage *imm =immmmm;
        _showImage.image = imm;
        touchModel.pictImage = imm;
        _showImage.image = touchModel.pictImage;
    }else
    {
        weakSelf(self);
        [_showImage sd_setImageWithURL:[NSURL URLWithString:touchModel.content] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (image) {
                 touchModel.pictImage = weakSelf.showImage.image;
                 weakSelf.activityView.hidden = YES;
                 [weakSelf.activityView stopAnimating];
                 [[SWChatManage getTouchCache] storeImage:image forKey:touchModel.pid completion:nil];
             }else{
                 weakSelf.showImage.image =immmmm;
             }
         }];
        }
    _selectBtn.touchModel= touchModel;

    
    
    
    _lineView.frame = CGRectMake(0, 45.6, _showImage.width, 0.4);
    NSDictionary *info = touchModel.messageInfo;
    _oneLab.text = [info valueForKey:@"addressTitle"];
    _twoLab.text = [info valueForKey:@"addressDet"];
    _oneLab.frame= CGRectMake(8, 5, _whiteView.width-14, 18);
    _twoLab.frame= CGRectMake(8, 25, _whiteView.width-14, 20);
//    _longPressGr.index = _index;
//    _longPressGr.touchModel = touchModel;
}

-(void)checkMapAction:(SWChatButton *)sender
{
    if ([_touchModel.fromUser isEqualToString:[SWChatManage getUserName]]) {
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"conrRight"] forState:UIControlStateNormal];
    }else{
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"conrLeft"] forState:UIControlStateNormal];
    }
//   [sender setBackgroundImage:[UIImage imageWithColor:defaultSelctColor] forState:UIControlStateNormal];
    [self performSelector:@selector(senderClearColor) withObject:nil afterDelay:0.5];
 
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(sender.touchModel, @"查看地图", _chooseIndex,nil);
    }
}

- (void)senderClearColor{
   [_selectBtn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
}
#pragma mark 长按事件
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
//        _touchModel = gesture.touchModel;
//        _chooseIndex = gesture.index;
        [[GMenuController sharedMenuController] setMenuVisible:NO];
        GMenuItem *item1 = [[GMenuItem alloc] initWithTitle:@"删除" target:self action:@selector(deleteOne)];
//        GMenuItem *item3 = [[GMenuItem alloc] initWithTitle:@"多选" target:self action:@selector(chooseAction)];
        GMenuItem *item4 = [[GMenuItem alloc] initWithTitle:@"撤回" target:self action:@selector(withdrawAction)];
        GMenuItem *item5 = [[GMenuItem alloc] initWithTitle:@"转发" target:self action:@selector(forwardingAction)];
        
        NSMutableArray *itemArr = [[NSMutableArray alloc] init];
        [itemArr addObject:item5];
        [itemArr addObject:item1];
        
//        if ([ATGeneralFuncUtil withdrawWithOldTime:_touchModel.oldTime]) {
//            if ([_touchModel.fromUser isEqualToString: [ATUserHelper shareInstance].user.imToken]) {
//                [itemArr addObject:item4];
//            }
//        }
        [[GMenuController sharedMenuController] setMenuItems:itemArr];
        CGRect rect = _bgImage.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        [[GMenuController sharedMenuController] setTargetRect:rect inView:_bgImage];
        [[GMenuController sharedMenuController] setMenuVisible:YES];
        [GMenuController sharedMenuController].menuViewContainer.hasAutoHide = YES;
    }
}


-(void)deleteOne
{
//    NSLog(@"删除");
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"删除", _chooseIndex,nil);
    }
}
-(void)withdrawAction
{
    self.menuTouchActionBlock(nil, @"键盘消失",0,nil);
    weakSelf(self);
    [[GMenuController sharedMenuController] setMenuVisible:NO];
//    [LPActionSheet showActionSheetWithTitle:@"是否撤回该条消息?"
//                          cancelButtonTitle:@"取消"
//                     destructiveButtonTitle:@"确定"
//                          otherButtonTitles:nil
//                                    handler:^(LPActionSheet *actionSheet, NSInteger index) {
//                                        NSLog(@"%ld", index);
//                                        if (index == -1) {
//                                            if ([ATGeneralFuncUtil withdrawWithOldTime:_touchModel.oldTime]) {
//                                                weakSelf.menuTouchActionBlock(weakSelf.touchModel, @"撤回",weakSelf.chooseIndex,nil);
//                                            }else{
//                                                [MBProgressHUD showError:withdrawError];
//                                            }
//                                        }else{
//
//                                        }
//                                    }];
}
-(void)celleditAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    NSLog(@"编辑");
}
-(void)chooseAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"多选",_chooseIndex,nil);
    }
}
-(void)forwardingAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"转发", _chooseIndex,nil);
    }
}

//进入编辑状态
//-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
//    [super setEditing:editing animated:animated];
//
//    for (UIControl *control in self.subviews){
//        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
//            for (UIView *v in control.subviews){
//                if ([v isKindOfClass: [UIImageView class]]) {
//                    UIImageView *img=(UIImageView *)v;
//                    img.frame = CGRectMake(0, img.frame.origin.y+20, 50, 50);
//                }
//            }
//        }
//    }
//    CGFloat moveSpace = 38;
//    if ([_touchModel.fromUser isEqualToString: [SWChatManage getUserName]]) {
//        if (editing && [_touchModel.fromUser isEqualToString: [SWChatManage getUserName]] ){
//            _bgImage.x = SCREEN_WIDTH-220-10 - moveSpace- self.userBtn.width;
//        } else{
//            _bgImage.x = SCREEN_WIDTH-220-10 - self.userBtn.width;
//        }
//    }
//}
////处理选中背景色问题
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    if (!self.editing) {
//        return;
//    }
//    [super setSelected:selected animated:animated];
//
//    if (self.editing) {
//        self.contentView.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor clearColor];
//        _whiteView.backgroundColor =  [UIColor whiteColor] ;
//    }
//}
@end
