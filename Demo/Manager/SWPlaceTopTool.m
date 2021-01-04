//
//  SWPlaceTopTool.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/23.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWPlaceTopTool.h"
 
#define kTopArrKey [NSString stringWithFormat:@"%@_topArr", [SWChatManage getUserName]]
 #define ATDraftKey [NSString stringWithFormat:@"draft_%@",[SWChatManage getUserName]]
@implementation SWPlaceTopTool


#pragma mark - 置顶数据

+(NSMutableArray *)getPlacedAtheTop
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *topArr = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:kTopArrKey]];
    return topArr;
}
+(BOOL)isPlaceAtTop:(NSString *)str
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *topArr = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:kTopArrKey]];
    return [topArr containsObject:str];
}
+(void)removeFromTopArr:(NSString *)str
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *topArr = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:kTopArrKey]];
    [topArr removeObject:str];
    [defaults setObject:topArr forKey:kTopArrKey];
}
+(void)addFromTopARR:(NSString *)str
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *topArr = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:kTopArrKey]];
    [topArr addObject:str];
    [defaults setObject:topArr forKey:kTopArrKey];
}
 





#pragma mark - 聊天草稿
//获取当前账号的所有草稿信息
+(NSDictionary *)getAllDraft
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *draftDict = [defaluts dictionaryForKey:ATDraftKey];
    [defaluts synchronize];
    if (draftDict) {
        return draftDict;
    }else
        return [NSDictionary dictionary];
}

//根据name刷新草稿信息
+(void)updateDraftWithName:(NSString *)name content:(NSString *)content
{
    if (!content) return;
    if (!name) return;
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *draftDict = [defaluts dictionaryForKey:ATDraftKey];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:draftDict];
    [dict setObject:content forKey:name];
    [defaluts setObject:dict forKey:ATDraftKey];
    [defaluts synchronize];
}


//删除一条草稿信息
+(void)deleteDraftWithName:(NSString *)name
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *draftDict = [defaluts dictionaryForKey:ATDraftKey];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:draftDict];
    [dict removeObjectForKey:name];
    [defaluts setObject:dict forKey:ATDraftKey];
    [defaluts synchronize];
}
@end
