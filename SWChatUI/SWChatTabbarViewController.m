//
//  SWChatTabbarViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWChatTabbarViewController.h"
#import "SWChatAdressBookController.h"
#import "SWChatMessageViewController.h"
#import "SWChatSettingViewController.h"

@interface SWChatTabbarViewController ()

@end

@implementation SWChatTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWChatMessageViewController *vc = [SWChatMessageViewController new];
    [self setupChildVc:vc title:@"消息" image:@""
         selectedImage:@""
           normalColor:UIColor.grayColor selectColor:UIColor.blackColor];
    
    
    SWChatAdressBookController *vc2 = [SWChatAdressBookController new];
       [self setupChildVc:vc2 title:@"通讯录" image:@""
            selectedImage:@""
              normalColor:UIColor.grayColor selectColor:UIColor.blackColor];
    
    
    SWChatSettingViewController *vc3 = [SWChatSettingViewController new];
       [self setupChildVc:vc3 title:@"设置" image:@""
            selectedImage:@""
              normalColor:UIColor.grayColor selectColor:UIColor.blackColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
