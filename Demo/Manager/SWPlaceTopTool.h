//
//  SWPlaceTopTool.h
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/23.
//  Copyright © 2020 sw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWPlaceTopTool : NSObject
//获取当前账号的所有置顶会话
+(NSMutableArray *)getPlacedAtheTop;
//从置顶列表里面移除
+(void)removeFromTopArr:(NSString *)str;
//添加置顶
+(void)addFromTopARR:(NSString *)str;
//是否被置顶
+(BOOL)isPlaceAtTop:(NSString *)str;




//获取当前账号的所有草稿信息
+(NSDictionary *)getAllDraft; 
//根据name刷新草稿信息
+(void)updateDraftWithName:(NSString *)name content:(NSString *)content;
//删除一条草稿信息
+(void)deleteDraftWithName:(NSString *)name;


@end

 


NS_ASSUME_NONNULL_END
