//
//  SWChatCellManager.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatCellManager.h"
#import "SWChatTextCell.h"
#import "SWChatImageCell.h"
#import "SWChatLocationCell.h"
#import "SWChatRedBagCell.h"
#import "SWChatSystemCell.h"

@implementation SWChatCellManager

CREATE_SHARED_MANAGER(SWChatCellManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadArr = [[NSMutableArray alloc] init];
    }
    return self;
}
#pragma mark - 返回 SWTouchBaseCell
- (SWTouchBaseCell *)createMessageCellForMessageModel:(SWChatTouchModel *)messageModel
          userModle:(SWFriendInfoModel *)userModel
           showName:(BOOL)shareName
             reSend:(BOOL)reSend
              index:(NSInteger)index
withReuseIdentifier:(NSString *)reuseId
                                            tableview:(UITableView *)tableview{
    
    __weak typeof(self) weakSelf = self;
    Class cellClass = [self tableViewCellClassForMessegeModel:messageModel];
    SWTouchBaseCell * _cell;
    //注册Cell
    if ([messageModel.type isEqualToString:@"text"]) {
        _cell = [tableview dequeueReusableCellWithIdentifier:reuseId];
        if (!_cell) {
            _cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        }
    }else{
      _cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
 
   if ([_cell isKindOfClass:[SWTouchBaseCell class]] ) {
       
       _cell.showName = shareName;
       if ([messageModel.fromUser isEqualToString: [SWChatManage getUserName]]) {
           _cell.showName = 0; //自己都不会显示名字
       }
//       _cell.shouldShowName = @"我是小开发";
   }
     
#pragma mark - Cell 操作
    if ([_cell isKindOfClass:[SWChatTextCell class]] ) {   //文本
        SWChatTextCell *textCell = (SWChatTextCell *)_cell;
        if ([_loadArr containsObject:textCell]) {
            return textCell;
        }
        textCell.index = index;
        textCell.reSend = false;
        //赋值
        [textCell setTextCell:messageModel touchUserModel:userModel isShowName:shareName];
        [_loadArr addObject:textCell];
        //文本操作
        [textCell setMenuTouchActionBlock:^(SWChatTouchModel * _Nonnull model, NSString * _Nonnull actionName, NSInteger index, SWChatButton * _Nonnull checkBtn) {
            weakSelf.menuTouchActionBlock(model, actionName, index, checkBtn);
        }];
      
        
    }else if ([_cell isKindOfClass:[SWChatImageCell class]]){  //图片
        SWChatImageCell *imageCell = (SWChatImageCell *)_cell;
        imageCell.index = index;
        //赋值
//        imageCell.reSend = NO;// [messageModel.isSuccess isEqualToString:@"failure"];
       [imageCell setImageCell:messageModel touchUserModel:userModel isShowName:shareName];
        [imageCell setMenuTouchActionBlock:^(SWChatTouchModel * _Nonnull model, NSString * _Nonnull actionName, NSInteger index, SWChatButton * _Nonnull checkBtn) {
           //Cell 的操作
            if ([actionName isEqualToString:@"查看图片"]) {
                [weakSelf checkTouchImage:model index:index showView:checkBtn];
            }
        }];
    }
    else if ([_cell isKindOfClass:[SWChatLocationCell class]]){  //位置
        SWChatLocationCell *imageCell = (SWChatLocationCell *)_cell;
        imageCell.index = index;
        //赋值
       [imageCell setAddressCell:messageModel touchUserModel:userModel isShowName:shareName];
        [imageCell setMenuTouchActionBlock:^(SWChatTouchModel * _Nonnull model, NSString * _Nonnull actionName, NSInteger index, SWChatButton * _Nonnull checkBtn) {
           //Cell 的操作
            if ([actionName isEqualToString:@"查看地图"]) {
            
            }
        }];
    }else if ([_cell isKindOfClass:[SWChatRedBagCell class]]){
        SWChatRedBagCell *redBagCell = (SWChatRedBagCell *)_cell;
        redBagCell.index = index;
        [redBagCell setRedBagCell:messageModel touchUserModel:userModel isShowName:shareName];
        [redBagCell setMenuTouchActionBlock:^(SWChatTouchModel * _Nonnull model, NSString * _Nonnull actionName, NSInteger index, SWChatButton * _Nonnull checkBtn) {
            weakSelf.menuTouchActionBlock(model, actionName, index, checkBtn);
        }];
    }else if ([_cell isKindOfClass:[SWChatSystemCell class]])
    {
        SWChatSystemCell *systemCell = (SWChatSystemCell *)_cell;
//        if ([messageModel.messType isEqualToString:@"100"]) {
//            [systemCell setFriendActionSystemCell:messageModel friendInfo:userModel];
//        }else
            [systemCell setNoActionSystemCell:messageModel];
    }
    
        return _cell;
}

- (Class)tableViewCellClassForMessegeModel:(SWChatTouchModel *)model {
    if ([model.type isEqualToString:@"text"]) {
        return [SWChatTextCell class];
    }
     else   if ([model.type isEqualToString:@"img"]) {
        return [SWChatImageCell class];
    }
     else   if ([model.type isEqualToString:@"location"]) {
           return [SWChatLocationCell class];
    }
       else if ([model.type isEqualToString:@"envelope"]) {
     return [SWChatRedBagCell class];
       }
    else if ([model.type isEqualToString:@"system"]) {
      return [SWChatSystemCell  class];
      }
    //这边的逻辑:
    //根据不一样的消息类型加载不一样的cell video location system 等
 
    return [SWTouchBaseCell class];
}
#pragma mark 查看聊天图片大图
-(void)checkTouchImage:(SWChatTouchModel *)touchModel index:(NSInteger)index showView:(SWChatButton *)sender
{
       self.menuTouchActionBlock(touchModel, @"键盘消失", index, sender);
      
    
}
@end
