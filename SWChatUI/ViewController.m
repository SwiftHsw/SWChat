//
//  ViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/13.
//  Copyright © 2020 sw. All rights reserved.
//

#import "ViewController.h"
#import "SWChatViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SWChatUI";
    // Do any additional setup after loading the view.
}

- (IBAction)chatAction:(id)sender {
    SWChatViewController *vc=  [SWChatViewController new];
    SWMessageModel *model = [[SWMessageModel alloc]init];
    SWFriendInfoModel *friendModel = [[SWFriendInfoModel alloc]init];
    friendModel.headPic = @"http://b369.photo.store.qq.com/psb?/V12Kb7us1atDSD/eMKZN1clARgX7Az2QjbifJI*n0LTyalMVWuYOStX*YM!/b/dHEBAAAAAAAA&bo=jgUgA4AHOAQFGSk!&rf=viewer_4";
    friendModel.imToken = [SWChatManage getUserName];
    friendModel.nickName  = @"帅的很";
    friendModel.isFriend = YES;
    
//    model.draft = @"消息草稿";
//    model.messageType = @"text";
    model.touchUser = @"shuaige";
    model.friendModel = friendModel;
    vc.messageModel = model;
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
