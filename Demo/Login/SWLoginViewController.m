//
//  SWLoginViewController.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/21.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWLoginViewController.h"
#import "SWChatTabbarViewController.h"

@interface SWLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *login_acount;
@property (weak, nonatomic) IBOutlet UITextField *login_pass;

@end

@implementation SWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _login_acount.text = @"hsw1234";
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)login_rigistAction:(id)sender {
    if (kStringIsEmpty(_login_acount.text)) {
        [SVProgressHUD showErrorWithStatus:@"输入你的账号"];
        return;
    }
    [[SWHXTool sharedManager]registerWithUsername:_login_acount.text isReLogin:false didGoon:true];
    
}

- (IBAction)login_Action:(id)sender {
    if (kStringIsEmpty(_login_acount.text)) {
           [SVProgressHUD showErrorWithStatus:@"输入你的账号"];
           return;
       }
    [[SWHXTool sharedManager]loginWithUsername :_login_acount.text isReLogin:false didGoon:true];
      [[SWHXTool sharedManager] setOperationBlock:^(NSDictionary * _Nonnull info, EMError * _Nonnull error) {
          [SWChatManage setUserName:self->_login_acount.text];
          SWChatTabbarViewController *tabbar = [SWChatTabbarViewController new];
          [SWKit currentWindow].rootViewController = tabbar;
          
      }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [_login_acount resignFirstResponder];
//    [_login_pass resignFirstResponder];
       
}
@end
