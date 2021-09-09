//
//  SWFriendPostModel.m
//  SWChatUI
//
//  Created by 黄世文 on 2021/9/7.
//  Copyright © 2021 sw. All rights reserved.
//

#import "SWFriendPostModel.h"

@implementation SWFriendPostModel
-(void)setTime:(NSString *)time
{
    _time = [time stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
}
@end
