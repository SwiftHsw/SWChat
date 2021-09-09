//
//  SWMessageModel.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/16.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWMessageModel.h"
@implementation SWMessageModel
- (void)setShouContent:(NSString *)shouContent{
     
    
  _textLayout =   [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREEN_WIDTH-140, 50)
                                                   text:  [SWChatManage setMaattiEmoMessageList:shouContent]];
    
}
 
@end
