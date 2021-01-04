//
//  SWFuncView.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWFuncView.h"


@interface SWFuncView()<UIScrollViewDelegate>

@property (nonatomic, copy) UIScrollView * helpScrView;

@property (nonatomic, strong) UIPageControl * pageCtrl;

@end


@implementation SWFuncView


-(UIScrollView *)helpScrView{
    if (!_helpScrView) {
        _helpScrView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 210)];
        _helpScrView.pagingEnabled  =  YES ;
        _helpScrView.bounces  =  NO ;
        [_helpScrView setDelegate:self];
        _helpScrView.showsHorizontalScrollIndicator  =  NO ;
        _helpScrView.tag = 10001;
    }
    return _helpScrView;
}

-(id)initWithFrame:(CGRect)frame isGroup:(NSInteger)is
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f4f6"];
        
        _isGroup =is;
        [self creatUI];
        
    }
    return self;
}

-(void)creatUI
{
    NSMutableArray *titleArr = [[NSMutableArray alloc] initWithObjects:@"照片_nomal",@"拍摄_nomal",@"视频通话_normal",@"红包_nomal",@"位置_nomal",@"收藏_normal",@"名片_nomal", nil];
    NSMutableArray *imageArr = [[NSMutableArray alloc] initWithObjects:@"照片_select",@"拍摄_select",@"视频通话_select",@"红包_select",@"位置_select",@"收藏_select",@"名片_select", nil];
    if (_isGroup==2) {
        titleArr = [[NSMutableArray alloc] initWithObjects:@"照片_nomal",@"拍摄_nomal",@"红包_nomal",@"位置_nomal",@"收藏_normal",@"名片_nomal", nil];
        imageArr = [[NSMutableArray alloc] initWithObjects:@"照片_select",@"拍摄_select",@"红包_select",@"位置_select",@"收藏_select",@"名片_select", nil];
    }else{
//        if ([ATServiceConfigurationTool touchVoiceIsOpen]==3) {
            titleArr = [[NSMutableArray alloc] initWithObjects:@"照片_nomal",@"拍摄_nomal",@"红包_nomal",@"位置_nomal",@"收藏_normal",@"名片_nomal", nil];
            imageArr = [[NSMutableArray alloc] initWithObjects:@"照片_select",@"拍摄_select",@"红包_select",@"位置_select",@"收藏_select",@"名片_select", nil];
//        }
    }
//    NSString *mobile = [ATUserHelper shareInstance].user.userSecurityVo.mobile;
//    if ([mobile isEqualToString: auditAccount] || [mobile isEqualToString: auditAccountT]) {
//        [titleArr removeObject:@"红包_nomal"];
//        [imageArr removeObject:@"红包_select"];
//    }
    
    NSUInteger numberOfPage = titleArr.count%8 == 0? titleArr.count/8 : titleArr.count/8+1;
    //创建UIScrollView
    [self.helpScrView setContentSize:CGSizeMake(SCREEN_WIDTH * numberOfPage,210)];
    //创建UIPageControl
    _pageCtrl  = [[UIPageControl alloc] initWithFrame:CGRectMake(0,180,SCREEN_WIDTH,30)];
    _pageCtrl.numberOfPages  =  numberOfPage ;
    _pageCtrl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#8b8b8b"];
    _pageCtrl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#d6d6d6"];
    _pageCtrl.currentPage  =  0 ;
    
    [_pageCtrl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    float width = SCREEN_WIDTH/4;
    float height = 100;
    for (int page = 0; page < numberOfPage; page++) { //page页
        UIView *scview = [[UIView alloc] initWithFrame:CGRectMake(page * SCREEN_WIDTH,0, SCREEN_WIDTH, 210)];
        for (int column = 0; column < 2; column++) {
            int lincout = 4;
            for (int line = 0; line < lincout; line++) {
                int index = page*8+column*4+line;
                if (index < titleArr.count) {

                    NSString *title = [titleArr[index] componentsSeparatedByString:@"_"][0];
//                    NSLog(@"title =%@",title);
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setImage:[UIImage imageNamed:titleArr[index]] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:imageArr[index]] forState:UIControlStateHighlighted];
                    [btn setFrame:CGRectMake(line*width, height*column, width, height)];
                    [btn addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
                    [btn setTitle:title forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:0];
                    [scview addSubview:btn];
                }
            }
        }
        [_helpScrView addSubview:scview];
    }
    [self addSubview:_helpScrView];
    [self addSubview:_pageCtrl];
}
- (void)pageTurn:(UIPageControl *)sender
{
    CGSize  viewSize  =  _helpScrView .frame.size;
    CGRect  rect  =  CGRectMake (sender.currentPage * viewSize.width,0,viewSize.width,viewSize.height);
    [_helpScrView scrollRectToVisible:rect animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (scrollView.tag ==10001){
        //更新UIPageControl的当前页
        CGPoint  offset  =  scrollView .contentOffset;
        CGRect  bounds  =  scrollView .frame;
        [_pageCtrl setCurrentPage:offset.x / bounds.size.width];
    }
}
-(void)functionAction:(UIButton *)sender
{
    NSString *title = sender.titleLabel.text;
    
//    if ([title isEqualToString:@"视频通话"]) {
//        [self.delegate funcView:@"键盘消失" value:nil];
//        if ([ATGeneralFuncUtil canRecord:false]) {
//            NSArray *titleArr = @[@"语音通话",@"视频通话"];
//            if ([ATServiceConfigurationTool touchVoiceIsOpen]==1) {
//                titleArr = @[@"语音通话"];
//            }else if ([ATServiceConfigurationTool touchVoiceIsOpen]==2){
//                titleArr = @[@"视频通话"];
//            }
//            [LPActionSheet showActionSheetWithTitle:nil
//                                  cancelButtonTitle:@"取消"
//                             destructiveButtonTitle:nil
//                                  otherButtonTitles:titleArr
//                                            handler:^(LPActionSheet *actionSheet, NSInteger index) {
//                                                NSLog(@"%ld", index);
//                                                if (index>0) {
//                                                    NSInteger tag = index-1;
//                                                    NSString *title = titleArr[tag];
//                                                    if ([title isEqualToString:@"语音通话"]) {
//                                                        [self.delegate funcView:@"语音通话" value:nil];
//                                                    }else if ([title isEqualToString:@"视频通话"]){
//                                                        [self.delegate funcView:@"视频通话" value:nil];
//                                                    }
//                                                }
//
//                                            }];
//            if ([title isEqualToString:@"视频通话"]) {
//                title = [title stringByAppendingString:@"-all"];
//            }
//            [self.delegate funcView:title value:nil];
//        }else{
//            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
//
//            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                [[[UIAlertView alloc] initWithTitle:@"权限不足"
//                                            message:@"请在iphone的\"设置-隐私-麦克风\"选项中，允许抱抱圈访问你的手机麦克风"
//                                           delegate:nil
//                                  cancelButtonTitle:@"好"
//                                  otherButtonTitles:nil] show];
//            });
////            [self.delegate funcView:@"键盘消失" value:nil];
//        }
//    }else{
        [self.delegate funcView:title value:nil];
//    }
    
    
}

@end
