//
//  SWChatAdressBookController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatAdressBookController.h"
#import "SWFriendListCell.h"
#import "SWFriendSortManager.h"
#import "SWChatSingViewController.h"
 
@interface SWChatAdressBookController ()<UITableViewDelegate,UITableViewDataSource>
/*排序后的出现过的拼音首字母数组*/
@property(nonatomic,strong)NSMutableArray *indexArray;
/*排序好的结果数组*/
@property(nonatomic,strong)NSMutableArray *letterResultArr;
/*总的好友个数*/
@property (nonatomic, assign) NSInteger totalCount;
@end

@implementation SWChatAdressBookController


-(void)uploadData:(NSString *)action
{
    
    if ([action isEqualToString:@"同意好友申请"]) {
        NSArray *arr = [[ATFMDBTool shareDatabase] at_lookupTable:@"friendList" dicOrModel:[SWFriendInfoModel new] whereFormat:nil];
        if (arr.count<=0) {
            [SWChatManage setFriendArr:[NSMutableDictionary dictionary]];
            [self.indexArray removeAllObjects];
            [self.letterResultArr removeAllObjects];
            [self.tableView reloadData];
            SWLog(@"好友数据列表为空");
            return;
        }
        
        dispatch_async(dispatch_queue_create(0, 0), ^{
                NSMutableArray *index = [SWFriendSortManager IndexWithArray:arr Key:@"remark"];
                NSMutableArray *letter = [SWFriendSortManager sortObjectArray:arr Key:@"remark"];
                if ([[index firstObject] isEqualToString:@"#"] && index.count>1) {
                    NSString *first = [index firstObject];
                    NSMutableArray *firstArr = [letter firstObject];
                    [index removeObject:first];
                    [letter removeObject:firstArr];
                    [index addObject:first];
                    [letter addObject:firstArr];
                }
                SWFriendInfoModel *model = [SWFriendInfoModel new];
                model.isSystem = true;
                model.nickName = [NSString stringWithFormat:@"%zd位好友",arr.count];
                model.remark = [NSString stringWithFormat:@"%zd位好友",arr.count];
                NSMutableArray *addArrr = [letter lastObject];
                [letter removeLastObject];
                [addArrr addObject:model];
                [letter addObject:addArrr];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                    [info setObject:letter forKey:@"letter"];
                    [info setObject:index forKey:@"index"];
                    [SWChatManage setFriendArr:info];
                    [self setFriendArrData:[info valueForKey:@"letter"] index:[info valueForKey:@"index"]];
                });
            });
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
  
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    self.navigationItem.rightBarButtonItem =[ UIBarButtonItem itemWithTitle:@"添加" ImageName:@"" highImageName:@"" target:self action:@selector(addFreadsAction)];
 
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self loadData];
  
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    
}
//添加好友
- (void)addFreadsAction{
      UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"发送" preferredStyle:UIAlertControllerStyleAlert];
        [alert2 addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入你要添加的好友账号" ;
        }];
         UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             UITextField *longinTextField = alert2.textFields.firstObject;
                SWHXTool *tool = [SWHXTool sharedManager];
                [tool sendFriendPost:longinTextField.text post:@"" isShow:true];
         }];
        [alert2 addAction:sure];
        [self presentViewController:alert2 animated:YES completion:^{
            
        }];
}
- (void)updateFriendArr{
     [self loadData];
}
 
-(void)loadData
{
    self.indexArray = [[NSMutableArray alloc] init];
    self.letterResultArr = [[NSMutableArray alloc] init];
    NSMutableDictionary *friendList = [SWChatManage getFriendArr];
    if (friendList.count!=0) {
        [self setFriendArrData:[friendList valueForKey:@"letter"] index:[friendList valueForKey:@"index"]];
    }else{
        SWLog(@"好友数据列表为空");
    }
    [self.tableView reloadData];
}
-(void)setFriendArrData:(NSArray *)letterArr index:(NSArray *)index
{
    if (letterArr.count==0) {
          SWLog(@"好友数据列表为空");
        return;
    }
    [self.indexArray removeAllObjects];
    [self.indexArray addObjectsFromArray:index];
    
    [self.letterResultArr removeAllObjects];
    [self.letterResultArr addObjectsFromArray:letterArr];
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate
#pragma mark 返回多少个组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexArray.count;
}
#pragma mark 返回每个组多少个cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.letterResultArr objectAtIndex:section] count];
}
#pragma mark 返回每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

//#pragma mark 返回每个group的文字
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id label = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
        [label setFont:[UIFont systemFontOfSize:14.5f]];
        [label setTextColor:[UIColor grayColor]];
        [label setBackgroundColor:[UIColor colorWithHexString:@"#f5f5f5"]];
    }
    if ([[self.indexArray objectAtIndex:section] isEqualToString:@"#"]) {
        [label setText:@"    特殊字符"];
    }else
        [label setText:[@"    " stringByAppendingString:[self.indexArray objectAtIndex:section]]];
    return label;
}
//section右侧index数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.indexArray;
}
//点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

#pragma mark - UITableView dataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SWFriendListCell";
    SWFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[SWFriendListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    NSArray *arr = _letterResultArr[indexPath.section];
    BOOL top = true;
    BOOL last = false;
    if (indexPath.section==_letterResultArr.count-1) {
        if (indexPath.row==arr.count-1) {
            last =true;
        }
    }else{
        if (indexPath.row==arr.count-1) {
            last =true;
        }
    }
    SWFriendInfoModel *model = arr[indexPath.row];
    model.isFriend=YES;
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (model.isSystem) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setFriendListCellData:model top:top last:last count:0];
    }else if (model.isDefault && indexPath.row==0)
    {
        [cell setFriendListCellData:model top:top last:last count:0];
    }else
        [cell setFriendListCellData:model top:top last:last count:_totalCount];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = _letterResultArr[indexPath.section];
    SWFriendInfoModel *model = arr[indexPath.row];
      
    if (![model.remark containsString:@"位好友"]) {
        [[SWHXTool sharedManager] gotoSingChatControllerWithLoginName:model.remark];
    }
     
}

@end
