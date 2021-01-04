//
//  SWTouchBarView.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWTouchBarView.h"

#import "SWChatManage.h"
#import "MOKORecordHeaderDefine.h"
#import "MOKORecorderTool.h"
#import "MOKORecordShowManager.h"
#import "SWChatLocationViewController.h"


#define kFakeTimerDuration       1
#define kMaxRecordDuration       60     //最长录音时长
#define kRemainCountingDuration  10     //剩余多少秒开始倒计时
#define viewWidth self.frame.size.width

@interface SWTouchBarView ()

@property (nonatomic, copy) touchBarBlock touchBarBlcok;
@property (nonatomic, assign) BOOL isRecord;
@property (nonatomic, assign) BOOL isOut;
@property (nonatomic, assign) float duration;
//录音相关属性
@property (nonatomic, strong) MOKORecorderTool *recorder;
@property (nonatomic, assign) MOKORecordState currentRecordState;
@property (nonatomic, strong) NSTimer *fakeTimer;
@property (nonatomic, strong) MOKORecordShowManager *voiceRecordCtrl;
@property (nonatomic, strong) SDImageCache *picCache;
@end

@implementation SWTouchBarView{
       UIButton *soundBtn;  // 语音/键盘 切换按钮
       UIButton *imageBtn; //  表情/键盘 切换按钮
       UIButton *addBtn; //     + 更多
       UIView *alphaView;
}

- (UIView *)initTouchBarView:(touchBarBlock)blcok{
    self.touchBarBlcok = blcok;
      _picCache = [SWChatManage getTouchCache];
     self.backgroundColor = [UIColor colorWithHexString:@"#f5f5f9"];
    
    UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 0.5)];
    lineview.backgroundColor=[UIColor colorWithHexString:@"#d9d9d9"];
    [self addSubview:lineview];
    
   //最左边
     soundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
       [soundBtn setImage:[UIImage imageNamed:@"tool_voice_1"] forState:UIControlStateNormal];
       [soundBtn setImage:[UIImage imageNamed:@"tool_keyboard_1"] forState:UIControlStateSelected];
       soundBtn.selected = NO;
       [soundBtn setFrame:CGRectMake(8, 8, 34, 34)];
       soundBtn.tag = 1;
       [soundBtn addTarget:self action:@selector(lastBtnAction:) forControlEvents:UIControlEventTouchUpInside];
       [self addSubview:soundBtn];
    
    //中间按住说话
    _startSoundBtn = [MOKORecordButton buttonWithType:UIButtonTypeCustom];
      [_startSoundBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
      [_startSoundBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
      [_startSoundBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateSelected];
      [_startSoundBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
      _startSoundBtn.hidden = YES;
      _startSoundBtn.selected = NO;
      [_startSoundBtn setFrame:CGRectMake(45, 7, SCREEN_WIDTH-120, 35)];
      [self addSubview:_startSoundBtn];
    
    //录音回调
       [self toDoRecord];
    
    imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [imageBtn setImage:[UIImage imageNamed:@"tool_emotion_1"] forState:UIControlStateNormal];
     [imageBtn setImage:[UIImage imageNamed:@"tool_keyboard_1"] forState:UIControlStateSelected];
     [imageBtn setFrame:CGRectMake(SCREEN_WIDTH-70, 8, 34, 34)];
     imageBtn.selected = false;
     imageBtn.tag = 5;
     [imageBtn addTarget:self action:@selector(lastBtnAction:) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:imageBtn];
    
    
    addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [addBtn setImage:[UIImage imageNamed:@"tool_share_1"] forState:UIControlStateNormal];
     [addBtn setImage:[UIImage imageNamed:@"tool_share_2"] forState:UIControlStateHighlighted];
     [addBtn setFrame:CGRectMake(SCREEN_WIDTH-35, 8, 34, 34)];
     addBtn.tag = 0;
     [addBtn addTarget:self action:@selector(lastBtnAction:) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:addBtn];
    
    
    [self setupInputViews];
    [self setupTextView];
    
     _lastLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, SCREEN_WIDTH, 0.4)];
       _lastLineView.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
       _lastLineView.hidden = YES;
       [self addSubview:_lastLineView];
 
    
//    [[SWHXTool sharedManager]setSendImageInsertBlock:^(EMMessage * _Nonnull message, NSString * _Nonnull error) {
//
//        SWLog(@"上传图片");
//        if (message) {
//            //如果原数组个数为0，那么开启上传，不为0则为上传中
////        模拟上传成功 因为没有服务器
//            NSString *Str = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1605946139171&di=df11437b35cd32d9d0866d2de3c561b0&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201409%2F11%2F20140911211243_3rT4u.jpeg";
//
//          SWChatTouchModel *touchModel = [[SWChatTouchModel alloc] EMMToChatModel:message timeArr:nil];
//                            //上传成功 逻辑可以用一套静态数组来存储图片，如果多张照片 可以上传成功进行下一章
//                             if ([SWChatManage GetTouchUser].length==0) {
//                                 EMConversation *conver = [[EMClient sharedClient].chatManager getConversation:touchModel.pid type:EMConversationTypeChat createIfNotExist:YES];
//                                 if (conver) {
//                                     //已退出界面，后台继续上传
////                                     [_hxTool updateUploadState:@"" content:ossTouchUrl(fileName) touchModel:touchModel conversation:conver];
//                                 }
//                             }else{
//                                 self.touchBarBlcok(@"上传状态", Str, touchModel.pid, nil);
//                             }
//
//        }
//
//    }];
    return self;
}
#pragma mark - 表情视图 + 功能视图
- (void) setupInputViews{
    
      _imageField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
         _imageField.borderStyle = UITextBorderStyleRoundedRect;
         _imageField.returnKeyType = UIReturnKeySend;
         [self addSubview:_imageField];
        
    //表情view
        SWExpressionView *express = [[SWExpressionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 240)];
        express.backgroundColor = UIColor.whiteColor;
        express.delegate = self;
        _imageField.inputView = express;
        
    
        _soundField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _soundField.borderStyle = UITextBorderStyleRoundedRect;
        _soundField.returnKeyType = UIReturnKeySend;
        [self addSubview:_soundField];
        
       //功能区域view
        _funcView = [[SWFuncView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 210+SafeBottomHeight) isGroup:1];
          _funcView.delegate = self;
          _soundField.inputView = _funcView;
        
}
//输入框，实现自动换行，自动高度
- (void)setupTextView{
    _sw_TextView = [[SWTouchTextView alloc] initWithFrame:CGRectMake(45, 7, SCREEN_WIDTH-120, 35)];
     _sw_TextView.font = [UIFont systemFontOfSize:16];
     _sw_TextView.layer.cornerRadius = 5.0;
     _sw_TextView.returnKeyType = UIReturnKeySend;
     _sw_TextView.backgroundColor = [UIColor whiteColor];
     _sw_TextView.isCanExtend = YES;
     _sw_TextView.extendLimitRow = 4;
     _sw_TextView.extendDirection = ExtendDown;
     _sw_TextView.delegate = self;
     [self addSubview:_sw_TextView];
}
#pragma mark 按钮的点击事件－－－－－－－－
#pragma mark 底部按钮的点击事件
-(void)lastBtnAction:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    
    imageBtn.selected = NO;
    if (tag == 0) {
        //点击的是+
       [self hideTool];
        if (!_soundField.isEditing) {
            [_soundField becomeFirstResponder];
        }else {
             [_soundField resignFirstResponder];
        }
    }else if (tag == 5){
        //点击的是表情按钮
        [self hideTool];
        if (!_imageField.isEditing) {
            [_imageField becomeFirstResponder];
             sender.selected = YES;
        }else {
             [_imageField resignFirstResponder];
             sender.selected = NO;
        }
        
    }else if (tag == 1){
        [_soundField resignFirstResponder];
        [_imageField resignFirstResponder];
        [_sw_TextView resignFirstResponder];
        _sw_TextView.text = @"";
        
         if (sender.selected)
              {
                  _sw_TextView.hidden = NO;
                  _startSoundBtn.hidden = YES;
              }else
              {
                  _sw_TextView.hidden = YES;
                  _startSoundBtn.hidden = NO;
              }
        sender.selected= !sender.selected;
        [self updataLastView];
    }
     
    
}

- (void)hideTool{
    soundBtn.selected = NO;
           _sw_TextView.hidden = NO;
           _startSoundBtn.hidden = YES;
           
}
-(void)resgFirst
{
    [self updataLastView];
    [self.soundField resignFirstResponder];
    [self.imageField resignFirstResponder];
    [self.sw_TextView resignFirstResponder];
}
#pragma mark - 功能区回调
- (void)funcView:(NSString *)buttonName value:(NSString *)value{
    SWLog(@"按钮名字：%@",buttonName);
    
    [self resgFirst];
    
    if ([buttonName isEqualToString:@"拍摄"]) {
         
    }else if([buttonName isEqualToString:@"照片"]){
   
        UIImagePickerController *pictureVC = [[UIImagePickerController alloc] init];
        pictureVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pictureVC.allowsEditing = YES;
        pictureVC.delegate = self;
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
        }
        pictureVC.modalPresentationStyle =  UIModalPresentationOverFullScreen;
        [[UIView getCurrentVC] presentViewController:pictureVC animated:YES completion:^{}];
 
    }else if ([buttonName isEqualToString:@"位置"]){
        
        SWChatLocationViewController *vc = [SWChatLocationViewController new];
        SWNavigationViewController *nav = [[SWNavigationViewController alloc]initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [vc setGetLoactionBlock:^(double latitude, double longitude, NSString * _Nonnull address, NSString * _Nonnull title, NSData * _Nonnull image) {
            [self sendLocationMessage:latitude longitude:longitude address:address title:title mageData:image];
            
        }];
        [[UIView getCurrentVC] presentViewController:nav animated:YES completion:nil];
        
    }else if ([buttonName isEqualToString:@"红包"]){
       //具体逻辑不做处理，这边实现发送自定义红包cell 并且点击后则被领取
        
        [self sendRedCardBack];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [[UIView getCurrentVC] dismissViewControllerAnimated:YES completion:^{
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }];
}

#pragma mark - 输入框回调
- (void)sw_TextView:(SWTouchTextView *)textview textDidChanged:(NSString *)text textRow:(NSUInteger)textRow{
//      SWLog(@"%@===文本内容%@====第几%ld行",textview,text,textRow);
        [self updataLastView];
    
}
 
-(void)updataLastView
{
    imageBtn.selected = NO;
    CGSize size = _sw_TextView.contentSize;
    if (size.height <= 40 || _sw_TextView.text.length == 0)
    {
        size.height = 40;
    }else if (size.height >=80)
    {
        size.height = 95;
    }
    float height = size.height+10;
 
        self.frame = CGRectMake(0, SCREEN_HEIGHT-height- NavBarHeight-SafeBottomHeight, SCREEN_WIDTH, height+SafeBottomHeight);
        _lastLineView.frame = CGRectMake(0, height-0.5, SCREEN_WIDTH, 0.5);
        soundBtn.frame = CGRectMake(8, height-40-2, 34, 34);
        addBtn.frame = CGRectMake(SCREEN_WIDTH-35, height-40-2, 34, 34);
        imageBtn.frame = CGRectMake(SCREEN_WIDTH-70, height-40-2, 34, 34);
 
      _touchBarBlcok(@"刷新界面高度",@"",@"",nil);
}


#pragma mark 录音功能区 －－－－－－－－－－－－
#pragma mark ---- 录音全部状态的监听 以及视图的构建 切换

-(void)toDoRecord
{
    __weak typeof(self) weak_self = self;
      //手指按下
    _startSoundBtn.recordTouchDownAction = ^(MOKORecordButton *recordButton) {
        NSLog(@"开始录音");
      //如果用户没有开启麦克风权限,不能让其录音
        if ([weak_self canRecord:true]) {
                  if (recordButton.highlighted) {
                      recordButton.highlighted = YES;
                      [recordButton setButtonStateWithRecording];
                  }
                  [weak_self.recorder startRecording];
                  weak_self.currentRecordState = MOKORecordState_Recording;
                  [weak_self dispatchVoiceState];
        }
    };
      //手指抬起
    _startSoundBtn.recordTouchUpInsideAction = ^(MOKORecordButton *recordButton) {
        weak_self.isOut = true;
        NSLog(@"录音完成");
         [recordButton setButtonStateWithNormal];
               [weak_self.recorder stopRecording];
               weak_self.currentRecordState = MOKORecordState_Normal;
               [weak_self dispatchVoiceState];
        
    };
   //手指滑出按钮
    _startSoundBtn.recordTouchUpOutsideAction = ^(MOKORecordButton *sender){
        NSLog(@"手指滑出按钮,取消录音");
          [weak_self.recorder stopRecording];
        [sender setButtonStateWithNormal];
        weak_self.currentRecordState = MOKORecordState_Normal;
        [weak_self dispatchVoiceState];
        
    };
    
    //中间状态  从 TouchDragInside ---> TouchDragOutside
       _startSoundBtn.recordTouchDragExitAction = ^(MOKORecordButton *sender){
           weak_self.currentRecordState = MOKORecordState_ReleaseToCancel;
           [weak_self dispatchVoiceState];
       };
       
       //中间状态  从 TouchDragOutside ---> TouchDragInside
       _startSoundBtn.recordTouchDragEnterAction = ^(MOKORecordButton *sender){
           NSLog(@"继续录音");
           weak_self.currentRecordState = MOKORecordState_Recording;
           [weak_self dispatchVoiceState];
       };
    
    
}
- (void)dispatchVoiceState
{
    if (_currentRecordState == MOKORecordState_Recording) {
        self.isRecord = NO;
        [self startFakeTimer];
    }
    else if (_currentRecordState == MOKORecordState_Normal)
    {
        [self resetState];
    }
    [self.voiceRecordCtrl updateUIWithRecordState:_currentRecordState];
}
- (MOKORecordShowManager *)voiceRecordCtrl
{
    if (_voiceRecordCtrl == nil) {
        _voiceRecordCtrl = [MOKORecordShowManager new];
    }
    return _voiceRecordCtrl;
}

- (void)startFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
    self.fakeTimer = [NSTimer scheduledTimerWithTimeInterval:kFakeTimerDuration target:self selector:@selector(onFakeTimerTimeOut) userInfo:nil repeats:YES];
    [_fakeTimer fire];
}
- (void)resetState
{
    [self stopFakeTimer];
    self.duration = 0;
    self.isRecord = YES;
}

- (void)stopFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
}

- (void)onFakeTimerTimeOut
{
    self.duration += kFakeTimerDuration;
    NSLog(@"+++duration+++ %f",self.duration);
    float remainTime = kMaxRecordDuration - self.duration;
    if ((int)remainTime == 0) {
        self.currentRecordState = MOKORecordState_Normal;
        [self dispatchVoiceState];
    }
    else if ([self shouldShowCounting]) {
        self.currentRecordState = MOKORecordState_RecordCounting;
        [self dispatchVoiceState];
        [self.voiceRecordCtrl showRecordCounting:remainTime];
    }
    else
    {
        [self.recorder.recorder updateMeters];
        float   level = 0.0f;                // The linear 0.0 .. 1.0 value we need.
        
        float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
        float decibels = [self.recorder.recorder peakPowerForChannel:0];
        if (decibels < minDecibels)
        {
            level = 0.0f;
        }
        else if (decibels >= 0.0f)
        {
            level = 1.0f;
        }
        else
        {
            float   root            = 2.0f;
            float   minAmp          = powf(10.0f, 0.05f * minDecibels);
            float   inverseAmpRange = 1.0f / (1.0f - minAmp);
            float   amp             = powf(10.0f, 0.05f * decibels);
            float   adjAmp          = (amp - minAmp) * inverseAmpRange;
            level = powf(adjAmp, 1.0f / root);
        }
        
        [self.voiceRecordCtrl updatePower:level];
    }
}
- (BOOL)shouldShowCounting
{
    if (self.duration >= (kMaxRecordDuration - kRemainCountingDuration) && self.duration < kMaxRecordDuration && self.currentRecordState != MOKORecordState_ReleaseToCancel) {
        return YES;
    }
    return NO;
}


- (BOOL)canRecord:(BOOL)isShow
{
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                if (isShow) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"权限不足"
                                                    message:@"请在iphone的\"设置-隐私-麦克风\"选项中，允许抱抱圈访问你的手机麦克风"
                                                   delegate:nil
                                          cancelButtonTitle:@"好"
                                          otherButtonTitles:nil] show];
                    });
                    
                }
            }
        }];
    }
    return bCanRecord;
}
#pragma mark - 按钮操作区域

- (void)expressionView:(NSString *)buttonName value:(NSString *)value image:(UIImage *)imm isGif:(NSString *)GifName filePath:(NSString *)filePath{
    
     if ([buttonName isEqualToString:@"发送"]) {
            if (_sw_TextView.text.length == 0) return;
            [_soundField resignFirstResponder];
            _touchBarBlcok(@"发送消息",_sw_TextView.text,@"",nil);
            _sw_TextView.text = @"";
        }else if ([buttonName isEqualToString:@"删除"])
        {
            //删除表情
            [self deleteSmile];
        }else if ([buttonName isEqualToString:@"添加"])
        {
            //添加表情
            NSString *str = [_sw_TextView.text stringByAppendingString:value];
            _sw_TextView.text = str;
        }else if ([buttonName isEqualToString:@"发送表情包"])
        {
        //发送表情包 逻辑
        }else if ([buttonName isEqualToString:@"发送gif"])
        {
         // 发送发送gif 逻辑
        }
    
    
}
#pragma mark - 输入框代理
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    __weak __typeof(&*self)    weakSelf  = self;
    
    if ([text isEqualToString:@"\n"]) {
        //未输入禁止换行
        if ([textView.text isEqual:@""]) return NO;
        if([SWChatManage isEmpty:textView.text]) {
            weakSelf.touchBarBlcok(@"键盘消失",textView.text,@"",nil);
            [SWAlertViewController showInController:[UIView getCurrentVC] title:nil message:@"不能发送空白消息" cancelButton: nil other:@"确定" completionHandler:^(SWAlertButtonStyle buttonStyle) {
                          textView.text = @"";
                          dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2/*延迟执行时间*/ * NSEC_PER_SEC));
                          dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                              [weakSelf.sw_TextView becomeFirstResponder];
                              weakSelf.touchBarBlcok(@"弹出文字键盘",@"",@"",nil);
                          });
                          
                      }];
                      return NO;
        }
        
        _touchBarBlcok(@"发送消息",textView.text,@"",nil);
             _sw_TextView.text = @"";
             [self updataLastView];
             return NO;
        
    }
    
    if ([text isEqual:@""]) {
         
        //这边做 如果有@人或者@多人的时候，删除下面的静态存储数组
//        NSMutableArray *arr = [ATStaticDataTool GetAtArr];
//              if (textView.text.length ==0 || textView.text.length == 1 || ![textView.text containsString:@"@"])
//              {
//                  [arr removeAllObjects];
//              }else
    //{
    //    for (int i = 0; i<arr.count; i++)
    //    {
    //        NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:arr[i]];
    //        int start = [[info valueForKey:@"start"] intValue];
    //        int end = [[info valueForKey:@"end"] intValue];
    //        int deleLocation = (int)range.location+1;
    //        if (deleLocation==start+end)
    //        {
    //            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(start, end-1) withString:@""];
    //            [arr removeObject:info];
    //        }else if (deleLocation>=start && deleLocation<=end)
    //        {
    //            end = end-1;
    //            [info setObject:@(end) forKey:@"end"];
    //            [arr setObject:info atIndexedSubscript:i];
    //        }
    //    }
    //}
    //return [self deleteSmile];
        
    }else if ([text isEqual:@"@"]){
        // 确认群聊界面 进入@某人逻辑处理
        UIViewController *vc = [[UIViewController alloc]init];
        vc.title = @"@群成员";
        vc.view.backgroundColor = UIColor.whiteColor;
      weakSelf.touchBarBlcok(@"进入@某人",@"进入@某人",nil,nil);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [[UIView getCurrentVC].navigationController pushViewController:vc animated:YES];
        });
        
        //模拟 vc 回调
        /*
         //构造一条发送@的消息
         NSString *atStr = [NSString stringWithFormat:@"%@ ",remarkName];
         NSString *start = [NSString stringWithFormat:@"%d",(int)_at_TextView.text.length-1];
         NSString *end = [NSString stringWithFormat:@"%d",(int)atStr.length+1];
         NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                               start,@"start",
                               end,@"end",
                               remarkName,@"name",
                               loginName,@"loginName", nil];
         //静态存储
         [ATStaticDataTool addInfoToAtArr:info];
           block =  ^{
          _at_TextView.text = [_at_TextView.text stringByAppendingString:@"群主"];
         }
         */
        
    }
    double delayInSecondss = 0.1;
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSecondss * NSEC_PER_SEC));
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         weakSelf.touchBarBlcok(@"发送输入状态消息",self.sw_TextView.text,@"",nil);
     });
    
    return  YES;
    
}
//删除表情
-(BOOL)deleteSmile
{
    if (_sw_TextView.text.length == 0) return YES;
    if ([_sw_TextView.text rangeOfString:@"["].location != NSNotFound)
    {
        NSArray *arr = [_sw_TextView.text componentsSeparatedByString:@"["];
        NSString *last = [NSString stringWithFormat:@"[%@",[arr lastObject]];
        NSString *b = [last substringFromIndex:last.length-1];
        if ([b isEqual:@"]"])
        {
            int length = (int)_sw_TextView.text.length;
            NSRange range = NSMakeRange(length-last.length, last.length);
            NSMutableString *sttt  = [NSMutableString stringWithString:_sw_TextView.text];
            [sttt deleteCharactersInRange:range];
            _sw_TextView.text = [NSString stringWithString:sttt];
            _touchBarBlcok(@"发送输入状态消息",_sw_TextView.text,@"",nil);
            return NO;
        }
    } 
    return YES;
}
#pragma mark - 相册选择

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [[UIView getCurrentVC] dismissViewControllerAnimated:YES completion:^{
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }];
    UIImage *originImage = [[UIImage alloc] init];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        originImage = [info objectForKey:UIImagePickerControllerEditedImage]; //裁剪
        originImage = [UIImage imageWithData:UIImageJPEGRepresentation(originImage, 0.01)];
        
    } else{
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString:@"public.image"])
        {
            UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            originImage = image;
        }
        
    }
    if (!originImage) {
        SWLog(@"图片有误,发送失败");
              return;
     }
    //随机字符串作为图片名称
   
       NSString *messageID = [NSString getRandomString];
      //模拟发送数据
       [self sendFileMessage:originImage
                         pid:messageID
                isExpression:@"0"
                 messageType:@"img"
                    filePath:@""];
}
 
-(void)sendFileMessage:(UIImage *)image pid:(NSString *)pid isExpression:(NSString *)isExpression messageType:(NSString *)type filePath:(NSString *)filePath{
    SWLog(@"=====SD缓存写入数据====");
    [_picCache storeImage:image forKey:pid completion:^{
        //构造消息体
        NSDictionary * info;
        info = [SWChatManage sendInfoWithSing:self.userInfoModel];
         
        CGSize size = [[SWChatManage sharedManager]imagePhotoSize:[NSString stringWithFormat:@"%.2f",image.size.width]
                                           videoFristFramesHeight:[NSString stringWithFormat:@"%.2f",image.size.height]];
        
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        [content setObject:@"SD缓存" forKey:@"content"];
        [content setObject:pid forKey:@"fileName"]; //文件名
        [content setObject:filePath forKey:@"filePath"];
        [content setObject:[NSString stringWithFormat:@"%0.2f",size.height]forKey:@"height"];
         [content setObject:[NSString stringWithFormat:@"%0.2f",size.width] forKey:@"width"];
        [content setObject:@"upload" forKey:@"state"];
        [content setObject:isExpression forKey:@"isExpression"];
        
        [[SWHXTool sharedManager]sendMessageToUser:[SWChatManage GetTouchUser]
                                       messageType:type
                                          chatType:1
                                          userInfo:info
                                           content:content
                                         messageID:pid
                                          isInsert:YES isConversation:YES isJoin:false];
        
        //   模拟发送
    }];
    
    //模拟阿里 OSS上传文件
    __block NSString *fileName = [NSString stringWithFormat:@"%@.png",pid];
    
    //模拟百分比上传中
    [self beginAmnit:0 pid:pid];
   
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//    });
 
}
- (void)beginAmnit:(NSInteger)index pid:(NSString *)pid{
  
   __block    NSInteger newIndex = index;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            newIndex++;
            if (newIndex == 100) {
//                self.model
                //模拟上传成功
                    self.touchBarBlcok(@"上传状态", @"SD缓存", pid, nil);
                
            }else{
                [SWChatManage setProgressForKey:pid press:[NSString stringWithFormat:@"%zd%%",newIndex]];
                NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[SWChatManage uploadLabeArr]];
                                        for (int i = 0; i<arr.count; i++) {
                                            SWLabel *label = arr[i];
                                            if ([label.labelID isEqualToString:pid]) {
                                                label.text =  [NSString stringWithFormat:@"%ld%%",(long)newIndex];
                                            }
                                        }
                 [self beginAmnit:newIndex pid:pid] ;
            }
        });
}
- (void)starProgress:(NSString *)pid{
    for (int index = 0; index < 101; index ++) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
              
//
//        });
    }
   
}

#pragma mark - 模拟发送位置
- (void)sendLocationMessage:(double)latitude  longitude:(double)longitude  address:(NSString *)address title:(NSString *)title mageData:(NSData *)image{
   SWLog(@"=====SD缓存写入数据====");
    __block NSString *messageID = [NSString getRandomString];
      UIImage *immm = [UIImage imageWithData:image];
       [self.picCache storeImage:immm forKey:messageID completion:^{
           //构造消息体
           NSDictionary *info;
          info = [SWChatManage sendInfoWithSing:self.userInfoModel];
           //failure successful
           NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
           [content setObject:@"SD缓存" forKey:@"content"];
           [content setObject:messageID forKey:@"fileName"];
           [content setObject:@"upload" forKey:@"state"];
           [content setObject:address forKey:@"addressTitle"];
           [content setObject:title forKey:@"addressDet"];
           [content setObject:[NSString stringWithFormat:@"%0.2f",latitude] forKey:@"lat"];
           [content setObject:[NSString stringWithFormat:@"%0.2f",longitude] forKey:@"lon"];
           
            [[SWHXTool sharedManager] sendMessageToUser:[SWChatManage GetTouchUser]
                                            messageType:@"location"
                                               chatType:1
                                               userInfo:info
                                                content:content
                                              messageID:messageID
                                               isInsert:YES
                                         isConversation:YES
                                                 isJoin:NO];
               
           //模拟位置图片上传成功
           self.touchBarBlcok(@"上传状态", @"SD缓存", messageID, nil);
                           
       }];
    
}

//发送红包
- (void)sendRedCardBack{
    
     [[SWHXTool sharedManager] sendMessageToUser:[SWChatManage GetTouchUser]
                                     messageType:@"envelope"
                                        chatType:1
                                        userInfo:[SWChatManage sendInfoWithSing:_userInfoModel] content:@{@"content":@"红包来啦"}
                                       messageID:@""
                                        isInsert:false
                                  isConversation:false
                                          isJoin:NO];
    
//  [[SWChatManage sharedManager]sendMessageToUser:[SWChatManage getUserName]
//                                                        messageType:@"envelope"
//                                                           chatType:1
//                                                           userInfo:[SWChatManage sendInfoWithSing:[SWFriendInfoModel new]]
//                                         content:@{@"content":@"红包来啦"}
//                                                          messageID:@""
//                                                           isInsert:false
//                                                     isConversation:false
//                                                             isJoin:YES
//                                                       successBlock:^(SWChatTouchModel * _Nonnull model) {
//                                    SWLog(@"红包发送成功");
//                     }];
    
}
 
@end
