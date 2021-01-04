//
//  SWChatTextCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatTextCell.h"
#import "SWReadTextView.h"


@interface SWChatTextCell ()

@property (nonatomic, strong) UIImage *bubble;

@property (nonatomic, strong) UIImageView *bubbleImageView;

@property (nonatomic, strong) YYLabel * bubbleText;

@property (nonatomic, strong) SWChatTouchModel *touchModel;

@property (nonatomic, assign) NSInteger chooseIndex;

@end

@implementation SWChatTextCell

 - (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
 {
     self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
     if (self) {
          
         UIImageView *bubbleImageView = [[UIImageView alloc] init];
         bubbleImageView.backgroundColor = [UIColor clearColor];
         bubbleImageView.userInteractionEnabled = YES;
         [self.contentView addSubview:bubbleImageView];
         _bubbleImageView = bubbleImageView;
          
         
         _bubbleText = [YYLabel new];
         // 开启异步绘制
         _bubbleText.displaysAsynchronously = YES;
         _bubbleText.ignoreCommonProperties = YES;
         _bubbleText.lineBreakMode = NSLineBreakByCharWrapping;
         _bubbleText.numberOfLines = 0;
         _bubbleText.font = [UIFont systemFontOfSize:16];
         [_bubbleImageView addSubview:_bubbleText];
         
         //双击手势
         UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
         doubleTapGesture.numberOfTapsRequired =2;
         doubleTapGesture.numberOfTouchesRequired =1;
         [_bubbleImageView addGestureRecognizer:doubleTapGesture];
     }
     return self;
 }
//双击手势
-(void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap
{
//    NSLog(@"双击查看大屏幕文字逻辑");
    self.menuTouchActionBlock(_touchModel, @"键盘消失", _index, nil);
 
    UIViewController *controller = [UIView getCurrentVC];
       [controller.navigationController setNavigationBarHidden:YES animated:YES];
       UIView *view = controller.view;
       SWReadTextView *textView = [[SWReadTextView alloc] initWithFrame:view.frame showText:_touchModel.content];
       textView.alpha =1;
       textView.touchModel = _touchModel;
       [view addSubview:textView];
    
}
- (void)setTextCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel isShowName:(BOOL)isShow{
     
       [super setBaseCell:touchModel touchUserModel:userModel];
    // 从textLayout文本获取尺寸
     CGSize rectsize = touchModel.textLayout.textBoundingSize;
     _bubbleText.frame = CGRectMake(15, 0.0f, rectsize.width, MAX(rectsize.height, 24));
  
    
    if ([touchModel.fromUser isEqualToString:[SWChatManage getUserName]] ) {
        //表示我发送的
        float width = _bubbleText.frame.size.width+32;
        if (width<60) {
            width =60;
            _bubbleText.textAlignment = NSTextAlignmentCenter;
        }
        if (width>SCREEN_WIDTH-108) {
            width = SCREEN_WIDTH-108;
        }
        _bubbleImageView.frame = CGRectMake(SCREEN_WIDTH-width-50, self.userBtn.y, width, _bubbleText.frame.size.height+18);
        _bubbleText.frame = CGRectMake(12, 10, width-30, _bubbleText.frame.size.height);
        [_bubbleImageView setImage:[SWChatManage touchRightImage]];
    }else
    {
        //接收方
        float width = _bubbleText.frame.size.width+32;
        if (width<60) {
            width =60;
            _bubbleText.textAlignment = NSTextAlignmentCenter;
        }
        if (width>SCREEN_WIDTH-108) {
            width = SCREEN_WIDTH-108;
        }
        float poinY = self.userBtn.y;
        _bubbleImageView.frame = CGRectMake(50, self.showName==1?poinY+20:poinY, width, _bubbleText.frame.size.height+18);
        _bubbleText.frame = CGRectMake(18, 10, width-30, _bubbleText.frame.size.height);
        [_bubbleImageView setImage:[SWChatManage touchleftImage]];
    }
    
    //设置文本赋值
    _bubbleText.textLayout = touchModel.textLayout;
      __weak typeof(self) weakSelf = self;
      [_bubbleText setTextLongPressAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
          [weakSelf longAction];
      }];
      _touchModel = touchModel;
      _chooseIndex =_index;
      _isLoad = true;
    

    
}

#pragma mark 长按事件
-(void)longAction{
    
    SWLog(@"长按功能");
     [[GMenuController sharedMenuController] setMenuVisible:NO];
        GMenuItem *item1 = [[GMenuItem alloc] initWithTitle:@"复制" target:self action:@selector(copyAction)];
        GMenuItem *item2 = [[GMenuItem alloc] initWithTitle:@"转发" target:self action:@selector(forwardingAction)];
        GMenuItem *item3 = [[GMenuItem alloc] initWithTitle:@"收藏" target:self action:@selector(collectionAction)];
        GMenuItem *item4 = [[GMenuItem alloc] initWithTitle:@"删除" target:self action:@selector(deleteAction)];
        GMenuItem *item5 = [[GMenuItem alloc] initWithTitle:@"撤回" target:self action:@selector(withdrawAction)];
    
    NSMutableArray *itemArr = [[NSMutableArray alloc] init];
        [itemArr addObject:item2];
        [itemArr addObject:item3];
        [itemArr addObject:item1];
        [itemArr addObject:item4];
    
   // 这边的逻辑是：如果是登陆用户发送的，在2-3分钟内是属于可以撤回的，加入撤回功能
        if ([SWChatManage withdrawWithOldTime:_touchModel.oldTime]) {
            if ([_touchModel.fromUser isEqualToString:[SWChatManage getUserName]]) {
                [itemArr insertObject:item5 atIndex:3];
            }
         }
        [[GMenuController sharedMenuController] setMenuItems:itemArr];
        CGRect rect = _bubbleImageView.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        [[GMenuController sharedMenuController] setTargetRect:rect inView:_bubbleImageView];
        [[GMenuController sharedMenuController] setMenuVisible:YES];
        [GMenuController sharedMenuController].menuViewContainer.hasAutoHide = YES;
}

-(void)withdrawAction
{
    self.menuTouchActionBlock(nil, @"键盘消失",0,nil);
    __weak typeof(self) weakSelf = self;
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    [SWAlertViewController showInController:[UIView getCurrentVC] title:@"是否撤回该条消息?" message:@"" cancelButton:@"取消" other:@"确定" completionHandler:^(SWAlertButtonStyle buttonStyle) {
        if (buttonStyle == SWAlertButtonStyleOK) {
            if ([SWChatManage withdrawWithOldTime:_touchModel.oldTime]) {
                    weakSelf.menuTouchActionBlock(weakSelf.touchModel, @"撤回",weakSelf.chooseIndex,nil);
                }else{
                    [SVProgressHUD showErrorWithStatus:@"消息已超过三分钟，不能被撤回"];
                }
           
        }
    }];
    
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
-(void)copyAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string =_touchModel.content;
}
-(void)forwardingAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"转发",_chooseIndex,nil);
    }
}
-(void)collectionAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"收藏",_chooseIndex,nil);
    }
    NSLog(@"收藏");
}
-(void)deleteAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"删除",_chooseIndex,nil);
    }
}

@end
