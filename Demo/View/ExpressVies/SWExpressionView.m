//
//  SWExpressionView.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//
#import <SWKit.h>
#import "SWExpressionView.h"
#import "SWExpressionScrollView.h"
#import "SWExpressionCollectionCell.h"
#import "SWChatManage.h"
#import "SWExpressionBtn.h"

#define HELPSCROLLVIEWHEIGHT  230

@interface SWExpressionView()<UIScrollViewDelegate,UICollectionViewDelegate,
UICollectionViewDataSource>{
    UIButton *_addBtn;
}
@property (nonatomic,strong )SWExpressionScrollView * helpScrView;

@property (nonatomic, strong) UIPageControl * pageCtrl;

@property (nonatomic,strong )SWExpressionCollectionCell  *oldCell;

@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic,strong)UICollectionView *collectView;

@property (nonatomic, strong) NSMutableDictionary *totalAllDict;

@property (nonatomic, assign) NSInteger nowSection; //当前区域

@property (nonatomic, strong) NSMutableArray *collectDataArr; //数据源

@property (nonatomic, strong) NSMutableArray *pageArr;


@end



@implementation SWExpressionView



#pragma -- lazy

-(SWExpressionScrollView *)helpScrView{
    if (!_helpScrView) {
        _helpScrView  = [[SWExpressionScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HELPSCROLLVIEWHEIGHT)];
        _helpScrView.pagingEnabled  =  YES ;
        _helpScrView.bounces  =  NO ;
        [_helpScrView setDelegate:self];
        _helpScrView.showsHorizontalScrollIndicator  =  NO ;
        _helpScrView.tag = 1000;
        _helpScrView.backgroundColor = [UIColor whiteColor];
    }
    return _helpScrView;
}
 - (UICollectionView *)collectView
 {
     if (!_collectView) {
         
         UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
         layout.itemSize = CGSizeMake(40, 40);
         layout.minimumLineSpacing = 0;
         layout.minimumInteritemSpacing = 0;
         layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
         _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(40, HELPSCROLLVIEWHEIGHT-40, SCREEN_WIDTH-95, 40)
                                            collectionViewLayout:layout];
         _collectView.showsVerticalScrollIndicator = NO;
         _collectView.showsHorizontalScrollIndicator = NO;
         _collectView.dataSource = self;
         _collectView.delegate = self;
         _collectView.backgroundColor = [UIColor whiteColor];
         
         _collectView.alwaysBounceVertical = NO;
         [_collectView registerClass:[SWExpressionCollectionCell class] forCellWithReuseIdentifier:@"expressionViewID"];
         
         UIView *last = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectView.frame), SCREEN_WIDTH, SAFEBOTTOM_HEIGHT)];
         last.backgroundColor =[UIColor whiteColor];
         [self addSubview:last];
     }
     return _collectView;
 }

-(NSMutableArray *)collectDataArr
{
    if (!_collectDataArr) {
        _collectDataArr = [NSMutableArray array];
        //如果有下载表情包，这边从数据库添加表情包
//        _emjoyDataArr = [NSMutableArray array];
//        NSArray * modelArr = [[ATFMDBTool shareDatabase] at_lookupTable:@"downloadList" dicOrModel:[ATDownLoadEmModel new] whereFormat:nil];
//        for (ATDownLoadEmModel *model in modelArr) {
//            [_collectDataArr addObject:model.emEnName];
//            [_emjoyDataArr addObject:model];
//        }
       [ _collectDataArr  insertObject:@"expression" atIndex:0]; 
//        [ _emjoyDataArr  insertObject:[ATDownLoadEmModel new] atIndex:0];
//        if (_showCount==1) {
//            _collectDataArr =[[NSMutableArray alloc] initWithObjects:@"expression",nil];
//        }
    }
    return _collectDataArr;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
        [self loadPlist];
        [self creatUI];
        [self addSubview:self.collectView];
        
    }
    return self;
}
#pragma mark  __表情键盘相关
/**
 *  得到键盘数据
 */
-(void)loadPlist
{
  _totalAllDict = [[NSMutableDictionary alloc] initWithDictionary:[SWChatManage expression]];
}

-(void)creatUI
{
    _nowSection = 0;
    NSString *nowPlist = [self.collectDataArr firstObject];
    
    NSInteger total = [[_totalAllDict valueForKey:@"totalPage"] integerValue];
    if (_showCount==1) {
        total = 4;
    }
    [self.helpScrView setContentSize:CGSizeMake(SCREEN_WIDTH * total,HELPSCROLLVIEWHEIGHT)];
    _pageCtrl  = [[UIPageControl alloc] initWithFrame:CGRectMake(0,160,SCREEN_WIDTH,30)];
    _pageCtrl.numberOfPages  =  [[_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_page",nowPlist]] integerValue];
    _pageCtrl.currentPageIndicatorTintColor =[UIColor colorWithHexString:@"#8b8b8b"];
    
    _pageCtrl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#d6d6d6"];
    _pageCtrl.currentPage  =  0 ;
    _pageCtrl.userInteractionEnabled=false;
    NSInteger index = 0;
    _pageArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<self.collectDataArr.count; i++) {
        NSString *str = self.collectDataArr[i];
//        ATDownLoadEmModel *model = _emjoyDataArr[i];
        NSInteger numberOfPage = [[_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_page",str]] integerValue];
        float width =0;
        float height = 0;
        NSInteger coLumn = 0;
        NSInteger lineCout = 0;
        NSInteger nowTotal = 0;
        if ([str isEqualToString:@"expression"]) {
            coLumn = 4;
            lineCout = 8;
            width = SCREEN_WIDTH/lineCout;
            height = 160/coLumn;
            nowTotal = 32;
        }else{
            coLumn = 2;
            lineCout = 4;
            width = SCREEN_WIDTH/lineCout;
            height = 160/coLumn;
            nowTotal = 8;
        }
        NSArray *arr = [_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_image",str]];
        for (int page = 0; page < numberOfPage; page++) { //page页
            if (index==0 && page ==0) {
                index = page;
            }else if (index!=0 && page==0)
            {
                index = index +1;
            }else
                index = index+1;
            //创建显示的表情View
            SWExpressionCustomView *scview = [[SWExpressionCustomView alloc] initWithFrame:CGRectMake(index * SCREEN_WIDTH,0, SCREEN_WIDTH, HELPSCROLLVIEWHEIGHT)];
            scview.title = str;
            scview.count = [[_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_page",str]] integerValue];
            scview.section = i;
            scview.nowPage = page;
            for (int column = 0; column < coLumn; column++) {
                if ([str isEqualToString:@"expression"]) {
                    lineCout = column==3 ? 7:8;
                }
                for (int line = 0; line < lineCout; line++) {
                    NSInteger showIndex = page*nowTotal + column*lineCout +line;
                    
                    if (column==3 && [str isEqualToString:@"expression"]) {
                        showIndex = showIndex + 3;
                    }
                    if (page>0 && [str isEqualToString:@"expression"]) {
                        showIndex = showIndex -1;
                    }
                    if (showIndex < arr.count) {
                        SWExpressionBtn *btn = [SWExpressionBtn buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(line*width, 5+column*height, width, height)];
                        [btn addTarget:self action:@selector(smileAction:) forControlEvents:UIControlEventTouchUpInside];
                        btn.tag = showIndex;
                        [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
                        btn.section = i;
                        if ([str isEqualToString:@"expression"]) {
                            btn.isDefault = YES;
                        }else
                            btn.isDefault = NO;
//                        btn.isGif = model.isGif;
                        if (btn.isDefault) {
                            [btn setImage:[UIImage imageNamed:arr[showIndex]] forState:UIControlStateNormal];
                        }else{
//                            NSString *indexImage = [NSString stringWithFormat:@"%@/%@/%@.png",ATEmtionPath,str,arr[showIndex]];
//                            [btn setImageWithURL:[NSURL fileURLWithPath:indexImage] forState:UIControlStateNormal options:0];
                        }
                        [scview addSubview:btn];
                        
                    }
                }
            }
            if ([str isEqualToString:@"expression"]) {
                SWExpressionBtn *btn = [SWExpressionBtn buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(7*width-5, 3*height+12, width+5, height-12)];
                [btn addTarget:self action:@selector(smileAction:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = 404;
                btn.isDefault = YES;
                btn.section = i;
                [scview addSubview:btn];
                [btn setImage: [UIImage imageNamed:@"删除信息"] forState:UIControlStateNormal];
            }
            [_pageArr addObject:scview];
            _helpScrView.customView  = scview;
            [_helpScrView addSubview:scview];
        }
    }
    
    [self addSubview:_helpScrView];
    [self addSubview:_pageCtrl];
    
    float btnWidth = 40;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:[UIImage imageNamed:@"EmotionsBagAdd"] forState:UIControlStateNormal];
    [addBtn setBackgroundColor:[UIColor whiteColor]];
    [addBtn setFrame:CGRectMake(0, HELPSCROLLVIEWHEIGHT-btnWidth, btnWidth, btnWidth)];
    [addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addBtn];
    _addBtn = addBtn;

    UIButton *send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [send setFrame:CGRectMake(SCREEN_WIDTH-btnWidth-15, HELPSCROLLVIEWHEIGHT-btnWidth, btnWidth+15, btnWidth)];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [send setBackgroundColor:UIColor.purpleColor];
    [send addTarget:self action:@selector(sendSmileAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:send];
    _sendButton = send;
    
}
-(void)addBtnAction:(UIButton *)sender
{
    SWLog(@"跳转下载更多的表情包页面");
}


-(void)smileAction:(SWExpressionBtn *)btn
{
    
    NSString *path = _collectDataArr[btn.section];
    int tag = (int)btn.tag;
    NSArray *arr = [_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_title",path]];
    if (btn.section==0) {
        if (tag == 404) {//删除按钮
            [self.delegate expressionView:@"删除" value:nil image:nil isGif:false filePath:@""];
        }else
            [self.delegate expressionView:@"添加" value:arr[tag] image:nil isGif:false filePath:@""];
    }
//    else{
//        NSArray *title = [_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_title",path]];
//        NSArray *image = [_totalAllDict valueForKey:[NSString stringWithFormat:@"%@_image",path]];
//        NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@/",ATEmtionPath,path,image[tag]];
//        if (btn.isGif) {
//            filePath = [NSString stringWithFormat:@"%@/%@/gif/%@.gif",ATEmtionPath,path,image[tag]];
//        }
//        UIImage *sendimage = [UIImage imageWithContentsOfFile:filePath];
//        if (!sendimage) {
//            if (btn.isGif) {
//                [MBProgressHUD showError:@"发送的gif不存在"];
//            }else{
//                [MBProgressHUD showError:@"发送的表情不存在"];
//            }
//            return;
//        }
//        if (btn.isGif) {
//            [self.delegate expressionView:@"发送gif" value:title[tag] image:sendimage isGif:image[tag] filePath:filePath];
//        }else
//            [self.delegate expressionView:@"发送表情包" value:title[tag] image:sendimage isGif:image[tag] filePath:filePath];
//    }
    
}
-(void)sendSmileAction:(UIButton *)btn
{
     
         [self.delegate expressionView:@"发送" value:nil image:nil isGif:false filePath:@""];
   
}
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 1000 || scrollView == _helpScrView) {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.frame;
        NSInteger page = offset.x / bounds.size.width;
        SWExpressionCustomView *view = _pageArr[page];
        [_pageCtrl setCurrentPage:view.nowPage];
        _pageCtrl.numberOfPages = view.count;
        
        if (_oldCell) {
            _oldCell.backgroundColor = UIColor.whiteColor;
        }
        
        //处理滚动表情包逻辑
        NSIndexPath *selectPath = [NSIndexPath indexPathForRow:view.section inSection:0];
        SWExpressionCollectionCell *cell = (SWExpressionCollectionCell *)[_collectView cellForItemAtIndexPath:selectPath];
        cell.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
        _oldCell = cell;
        _nowSection = view.section;
        [_collectView scrollToItemAtIndexPath:selectPath atScrollPosition:0 animated:YES];
         
    }
}
 
#pragma mark - UICollectionViewDataSource //底部滚动添加的

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SWExpressionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"expressionViewID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell setCollectViewData:_collectDataArr[indexPath.row]];
    if (!_oldCell && indexPath.row==0) {
        cell.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
        
        _oldCell = cell;
    }else if ([_oldCell isEqual:cell])
    {
        cell.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
    }else
        cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
//设置行间距
- (CGFloat )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SWExpressionCollectionCell *cell = (SWExpressionCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([_oldCell isEqual:cell])return;
    if (_oldCell ) {
        _oldCell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
    _oldCell = cell;
    NSInteger index = 0;
    for (int i = 0; i<indexPath.row; i++) {
        if (indexPath.row<=_collectDataArr.count) {
            NSString *path = [NSString stringWithFormat:@"%@_page",_collectDataArr[i]];
            NSInteger count = [[_totalAllDict valueForKey:path] integerValue];
            index = index+count;
        }
    }
    [_helpScrView setContentOffset:CGPointMake(SCREEN_WIDTH*index,0) animated:NO];
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


@end
