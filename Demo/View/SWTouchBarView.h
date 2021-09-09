//
//  SWTouchBarView.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import <UIKit/UIKit.h>
 
#import "SWTouchTextView.h"
#import "SWFuncView.h"
#import "MOKORecordButton.h"
#import "SWExpressionView.h"

NS_ASSUME_NONNULL_BEGIN

/*发送等操作回调*/
typedef void(^touchBarBlock)(
                             NSString *btnName,
                             NSString *blcokContent,
                             NSString *index,
                             NSMutableArray *moderArr
                             );


@interface SWTouchBarView : UIView
<
SWFuncViewDelegate,
SWTouchTextViewDelegate,
SWExpressionViewDelegate, 
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

/*初始化方法*/
-(UIView *)initTouchBarView:(touchBarBlock)blcok;

/* 输入框 */
@property (nonatomic,strong) SWTouchTextView *sw_TextView;
/* 功能按钮模块 */
@property (nonatomic, strong) SWFuncView *funcView;
/* 按住说话按钮 */
@property (nonatomic, strong) MOKORecordButton *startSoundBtn;
/*单聊 用户数据*/
@property (nonatomic, strong) SWFriendInfoModel *userInfoModel;
//UITextField载图
@property (nonatomic,strong) UITextField *soundField;
@property (nonatomic,strong) UITextField *imageField;

@property (nonatomic, strong) UIView *lastLineView;
@property (nonatomic, assign) BOOL isJoin;
//1 是单聊，2是群聊
@property (nonatomic,assign) NSInteger isGroup;
@property (nonatomic, copy) NSString *isFrom;

@property (nonatomic, strong) SWChatGroupModel *groupModel;

/**
 动态刷新高度
 */
-(void)updataLastView;

@end

NS_ASSUME_NONNULL_END
