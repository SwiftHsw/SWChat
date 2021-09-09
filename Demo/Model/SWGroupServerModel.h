//
//  SWGroupServerModel.h
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/6.
//  Copyright © 2021 sw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWGroupServerModel : NSObject
@property (nonatomic, strong) NSString *headPic;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *imToken;
//
@property (nonatomic, strong) NSString *image;
//当前用户是否是群主
@property (nonatomic, assign) NSInteger master;
//群成员数量
@property (nonatomic, assign) NSInteger memberNumber;


//群名称
@property (nonatomic, strong) NSString *name;
//群主昵称
@property (nonatomic, strong) NSString *nickName;

//群主用户id
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *memberStr;

@property (nonatomic, strong) NSString *settingStr;

//群成员
@property (nonatomic, strong) NSArray *memberVos;
//群用户通用设置,有返回则为开启
@property (nonatomic, strong) NSArray *setting;

@property (nonatomic, strong) NSString *groupNick;
@end

NS_ASSUME_NONNULL_END
