//
//  SWChatSettingViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatSettingViewController.h"
#import "SWLoginViewController.h"
  

@interface SWChatSettingViewController()

@property(nonatomic, strong)UIView          *tableViewHeaderView;
@property (nonatomic,strong)UIImageView     *headImage;
@property(nonatomic, assign)NSInteger       imageHeight;
@property(nonatomic, strong)UIImageView     *headerBackView;
@property(nonatomic, strong)UIImageView     *photoImageView;
@property(nonatomic, strong)UILabel         *userNameLabel;
@property(nonatomic, copy)NSString         *textf;
@property(nonatomic, strong)UIVisualEffectView   *blurView;
@end

@implementation SWChatSettingViewController
 

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpdataUser];
    [self setNavgationBarHidden:YES animated:animated];
   
}
 
 
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor =  self.tableView.backgroundColor =  [UIColor whiteColor]; //
    [self.view addSubview:self.tableView];
    self.tableView.rowHeight = 100.f;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
 
    self.tableView.separatorColor = UIColor.clearColor;
     _imageHeight = 300;
    [self setCreateTableViewHeaderView];
}

#pragma mark - 创建头视图
- (void)setCreateTableViewHeaderView
{
    _tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _imageHeight)];
 
    _headerBackView = [[UIImageView alloc] init];
    _headerBackView.frame = CGRectMake(0, 0, SCREEN_WIDTH, _imageHeight);
    [_headerBackView sd_setImageWithURL:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/1/555d468a7f953.jpg"]];

    [_tableViewHeaderView addSubview:_headerBackView];
    _headerBackView.contentMode = UIViewContentModeScaleAspectFill;
    _headerBackView.layer.contentsRect=CGRectMake(0,0,1,0.8);
    _headerBackView.clipsToBounds = YES;
     
    _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 80) / 2, 100, 80, 80)];
    [self.tableViewHeaderView addSubview:self.photoImageView];
    _photoImageView.layer.cornerRadius = 40;
    _photoImageView.layer.masksToBounds = YES;
    _photoImageView.userInteractionEnabled= YES;
    [_photoImageView addTapGestureRecognizer:@selector(didUserssss) target:self numberTaps:1];
    // 用户名
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_photoImageView.frame) + 10, SCREEN_WIDTH, 20)];
    _userNameLabel.font = [UIFont systemFontOfSize:16];
    _userNameLabel.text = @"SWChatUI";
    _userNameLabel.textAlignment = 1;
     _userNameLabel.textColor = UIColor.blackColor;
   
    [_tableViewHeaderView addSubview:self.userNameLabel];
    ATViewBorderRadius(_photoImageView, 40, 2, [UIColor whiteColor]);
    //模糊
 
    self.tableView.tableHeaderView = _tableViewHeaderView;
    
    UIView *whithe = [[UIView alloc]initWithFrame:CGRectMake(0, _tableViewHeaderView.height-20, SCREEN_WIDTH, 20)];
         whithe.backgroundColor = [UIColor whiteColor];
          [_tableViewHeaderView addSubview:whithe];
          [UIView maskPathView:whithe rad:UIRectCornerTopLeft | UIRectCornerTopRight size:CGSizeMake(20,20)];
    
}

- (UIVisualEffectView *)blurView{
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight]];
        _blurView.frame = _headerBackView.bounds;
    }
    return _blurView;
}

- (void)setUpdataUser{
   
    self.userNameLabel.text = [SWChatManage getUserName];
   _userNameLabel.textColor = UIColor.blackColor;
     [_photoImageView sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1605946139171&di=df11437b35cd32d9d0866d2de3c561b0&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201409%2F11%2F20140911211243_3rT4u.jpeg" ]placeholderImage:kImageName(@"user")];
    [self.tableView reloadData];
  
}
- (void)didUserssss{
   
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

        UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
  
              cell.textLabel.text = @[
                              [NSString stringWithFormat:@"当前版本(%@)",GETSYSTEM],
                              @"支持一下作者的SWKit，求Star谢谢！",@"退出当前账号"][indexPath.row];
       
        return cell;

        
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        [[SWHXTool sharedManager]logout];
        [UIView currentWindow].rootViewController = [SWLoginViewController new];
    }if (indexPath.row == 1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://github.com/SwiftHsw/SWKit"]];
         
    }
}

#pragma mark - 滚动放大
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = SCREEN_WIDTH;// 图片的宽度
    CGFloat yOffset = scrollView.contentOffset.y;// 偏移的y值
    NSLog(@"%f",yOffset);
    if (yOffset < 0) {
        CGFloat totalOffset = _imageHeight + ABS(yOffset);
        CGFloat f = totalOffset / _imageHeight;
        self.headerBackView.frame = CGRectMake(- (width * f - width) / 2, yOffset, width * f, totalOffset);
 
    }
}

 

@end

 







