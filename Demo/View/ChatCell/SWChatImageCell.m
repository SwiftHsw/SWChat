//
//  SWChatImageCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/17.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatImageCell.h"


@interface SWChatImageCell()

@property (nonatomic, strong) UIImageView *showImage;

@property (nonatomic, strong) SWChatTouchModel *touchModel;

@property (nonatomic, strong) SWChatButton *checkBtn;

@property (nonatomic, assign) NSInteger chooseIndex;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
 @property (nonatomic, strong) UIImageView *alphaView;

@property (nonatomic, strong) UIImageView *bubbleImageView;

@property (nonatomic, strong) UIImageView *checkImage;

@property (nonatomic, strong) UIImage *bubble;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGr;

@end

@implementation SWChatImageCell
{
    CGFloat _imageX; //图片的X
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {

        UIImageView *showimage = [[UIImageView alloc] init];
        showimage.userInteractionEnabled = YES;
        showimage.layer.masksToBounds = YES;
        showimage.layer.cornerRadius = 5.0;
        showimage.contentMode = UIViewContentModeScaleAspectFill;
        showimage.backgroundColor =[UIColor clearColor];
        [self.contentView addSubview:showimage];
        _showImage = showimage;
        
        UIImageView *checkImage = [[UIImageView alloc] init];
        checkImage.userInteractionEnabled = YES;
        checkImage.backgroundColor =[UIColor clearColor];
        checkImage.hidden = YES;
        [self.contentView addSubview:checkImage];
        _checkImage = checkImage;

        SWChatButton *Btn = [SWChatButton buttonWithType:UIButtonTypeCustom];
        [Btn addTarget:self action:@selector(checkImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:Btn];
        _checkBtn = Btn;

        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];//指定进度轮的大小
        [activity setCenter:CGPointMake(70, 70)];//指定进度轮中心点
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
        activity.hidden = YES;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(.7f, .7f);
        activity.transform = transform;
        _activityView = activity;

        UIImageView *alpha = [[UIImageView alloc] init];
        _alphaView = alpha;

        SWLabel *proe = [[SWLabel alloc] init];
        proe.textColor = [UIColor whiteColor];
        proe.font = [UIFont systemFontOfSize:15];
        proe.textAlignment = NSTextAlignmentCenter;
        _pressLab.hidden = YES;
        _pressLab = proe;
        
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.5;
        [_checkBtn addGestureRecognizer:longPressGr];
        _longPressGr = longPressGr;

    }
    return self;
}



- (void)setImageCell:(SWChatTouchModel *)touchModel touchUserModel:(SWFriendInfoModel *)userModel isShowName:(BOOL)isShow{
    
    [super setBaseCell:touchModel touchUserModel:userModel];
    
    NSString *userImToken =  [SWChatManage getUserName];
    SDImageCache *picCache = [SWChatManage getTouchCache];
    float showName = 0;
   BOOL isSend = [touchModel.fromUser isEqual:userImToken];
   if (self.showName && !isSend) {
       showName = 20;
   }
 
    float width = touchModel.cellWidth;
    float height = touchModel.cellHeight;
    float buttonW =  self.userBtn.width;
    
    _imageX = SCREEN_WIDTH - touchModel.cellWidth - 20 - buttonW;
    
    _showImage.frame = CGRectMake( isSend ? _imageX : (20+buttonW), self.userBtn.y+showName, width, height);
    
    _checkImage.frame = CGRectMake(_showImage.x, _showImage.y, _showImage.width, _showImage.height);
    UIImage *immmm;
    if (touchModel.pictImage) {
        immmm = touchModel.pictImage;
    }else{
        immmm = [picCache imageFromCacheForKey:touchModel.pid];
    }
    
    if ([touchModel.content isEqualToString:@"SD缓存"] && !immmm) {
        //上传失败，并且缓存文件丢失,存在转发情况，取fileName
        immmm = [picCache imageFromCacheForKey:[touchModel.messageInfo valueForKey:@"fileName"]];
        if (!immmm) {
            if (touchModel.filePath.length != 0) {
                //存在文件路径，根据路径加载
                NSString *file = [[touchModel.filePath componentsSeparatedByString:@"emoticon/"] lastObject];
                immmm = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",IMEmtionPath,file]];
                if (!immmm) {
                    immmm = [UIImage imageNamed:@"PhotoDownloadfailed"];
                }else{
                    touchModel.pictImage = immmm;
                    [picCache storeImage:immmm forKey:touchModel.pid completion:nil];
                }
            }else{
                immmm = [UIImage imageNamed:@"PhotoDownloadfailed"];
            }
        }
    }
    if (immmm) {
    
        //图片存在
        _checkImage.image =  _showImage.image = touchModel.pictImage  = immmm;
    
        if ([touchModel.isSuccess isEqualToString:@"upload"]) {
            if (![touchModel.fromUser isEqualToString:[SWChatManage getUserName]]) {
                    _activityView.hidden = YES;
                    [_activityView removeFromSuperview];
                //并非我发送，模拟
            }else{
//                [self imagUpload_Stata:touchModel];
            }
        }else{
                  _activityView.hidden = YES;
            }
    }else{
        
        [_pressLab removeFromSuperview];
               [_alphaView removeFromSuperview];
               weakSelf(self);
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   weakSelf.activityView.hidden = NO;
                   weakSelf.activityView.frame = CGRectMake((weakSelf.showImage.frame.size.width-20)/2, (weakSelf.showImage.frame.size.height-20)/2-15, 20, 20);
                   [weakSelf.activityView removeFromSuperview];
                   [weakSelf.showImage addSubview:weakSelf.activityView];
                   weakSelf.activityView.color = [UIColor grayColor];
                   [weakSelf.activityView startAnimating];
               });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 if ([touchModel.content containsString:@"/(null)"] && ![touchModel.content containsString:@".png"]) {
                     touchModel.content = [touchModel.content stringByReplacingOccurrencesOfString:@"(null)" withString:touchModel.pid];
                     touchModel.content = [NSString stringWithFormat:@"%@.png",touchModel.content];
                 }
            if ([touchModel.content isEqualToString:@"SD缓存"]) {
                
            }else{
                NSString *imageUrl = [touchModel.pid containsString:@"https://"] ? touchModel.pid : touchModel.content;
                [weakSelf.showImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (!error && image)
                    {
                        [weakSelf.activityView removeFromSuperview];
                        touchModel.pictImage = image;
                        
                        weakSelf.showImage.image = image;
                        weakSelf.checkImage.image = image;

                        [self.contentView addSubview:weakSelf.checkBtn];
                        weakSelf.checkBtn.showImageView = weakSelf.checkImage;
                        [picCache storeImage:image forKey:touchModel.pid completion:nil];
                    }
                }];
            }
                
             });
        
    }
  
    _checkBtn.touchModel = touchModel;
      _checkBtn.frame = _showImage.frame;
      _checkBtn.showImageView = _checkImage;
      _touchModel = touchModel;
//      _longPressGr.touchModel = touchModel;
//      _longPressGr.index = _index;
      

      

}
- (void)imagUpload_Stata:(SWChatTouchModel *)touchModel{
    NSMutableArray *nowArr;
    if (![SWChatManage uploadLabeArr]) {
        nowArr = [[NSMutableArray alloc] init];
    }else
        nowArr = [[NSMutableArray alloc] initWithArray:[SWChatManage uploadLabeArr]];
    if (![nowArr containsObject:_pressLab]) {
        
        NSString *press = [SWChatManage getProgressForKey:touchModel.pid];
       if (press) {
           _pressLab.text = press;
       }else
           _pressLab.text = @"0%";
         
        [nowArr addObject:_pressLab];
        _activityView.frame = CGRectMake((_showImage.frame.size.width-20)/2, (_showImage.frame.size.height-20)/2-15, 20, 20);
        _activityView.hidden = NO;
        [_alphaView addSubview:_activityView];
        [_activityView startAnimating];
    }

    [SWChatManage setLabelArr:nowArr];
    _pressLab.labelID = touchModel.pid;
    _pressLab.frame = CGRectMake(0, (_showImage.frame.size.height-30)/2+10, _showImage.frame.size.width, 30);
    _alphaView.frame =CGRectMake(0, 0, _showImage.frame.size.width, _showImage.frame.size.height);
    [_showImage addSubview:_alphaView];
    [_alphaView addSubview:_pressLab];
    _alphaView.image = [UIImage imageNamed:@"alpha_view"];
}
//查看图片

-(void)checkImageAction:(SWChatButton *)sender
{
    if (self.menuTouchActionBlock) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuVisible:false];
        self.menuTouchActionBlock(sender.touchModel, @"查看图片", 0,_checkBtn );
    }
}
#pragma mark 长按事件
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
      if (gesture.state == UIGestureRecognizerStateBegan) {
            [[GMenuController sharedMenuController] setMenuVisible:NO];
            GMenuItem *item1 = [[GMenuItem alloc] initWithTitle:@"转发" target:self action:@selector(forwardingAction)];
            GMenuItem *item2 = [[GMenuItem alloc] initWithTitle:@"收藏" target:self action:@selector(collectionAction)];
            GMenuItem *item3 = [[GMenuItem alloc] initWithTitle:@"删除" target:self action:@selector(deleteAction)];
            GMenuItem *item4 = [[GMenuItem alloc] initWithTitle:@"编辑" target:self action:@selector(celleditAction)];
//            GMenuItem *item7 = [[GMenuItem alloc] initWithTitle:@"撤回" target:self action:@selector(withdrawAction)];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:item1];
            [arr addObject:item2];
            [arr addObject:item3];
            [arr addObject:item4];
    //        [arr addObject:item5];
//            if ([ATGeneralFuncUtil withdrawWithOldTime:gesture.touchModel.oldTime]) {
//                if ([gesture.touchModel.fromUser isEqualToString:[ATUserHelper shareInstance].user.imToken]) {
//                    [arr addObject:item7];
//                }
//            }
            
            [[GMenuController sharedMenuController] setMenuItems:arr];
            CGRect rect = _showImage.frame;
            rect.origin.x = 0;
            rect.origin.y = 0;
            [[GMenuController sharedMenuController] setTargetRect:rect inView:_showImage];
            [[GMenuController sharedMenuController] setMenuVisible:YES];
            [GMenuController sharedMenuController].menuViewContainer.hasAutoHide = YES;
//            _touchModel = gesture.touchModel;
//            _chooseIndex = gesture.index;
            
        }
    
}
#pragma mark 长按事件
-(BOOL)canBecomeFirstResponder
{
    return YES;
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
-(void)collectionAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"收藏",_chooseIndex,nil);
    }
}
-(void)celleditAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"编辑",_chooseIndex,nil);
    }
    NSLog(@"编辑");
}
-(void)forwardingAction
{
    [[GMenuController sharedMenuController] setMenuVisible:NO];
    if (self.menuTouchActionBlock) {
        self.menuTouchActionBlock(_touchModel, @"转发",_chooseIndex,nil);
    }
}

@end
